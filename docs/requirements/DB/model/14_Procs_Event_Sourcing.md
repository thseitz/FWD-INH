# 11 - Event Sourcing Procedures

## Table of Contents
1. [Overview](#overview)
2. [Event Store Management](#event-store-management)
3. [Event Replay and Reconstruction](#event-replay-and-reconstruction)
4. [Snapshot Management](#snapshot-management)
5. [Projection Rebuilding](#projection-rebuilding)
6. [Implementation Patterns](#implementation-patterns)
7. [Performance Considerations](#performance-considerations)
8. [Best Practices](#best-practices)

## Overview

The event sourcing operations have been mostly converted from stored procedures to individual SQL queries, with one complex procedure retained for projection rebuilding. These operations enable capturing all changes as immutable events, reconstructing state from events, and maintaining eventual consistency across the system.

### Migration Status
- **Converted to SQL**: 3 of 4 procedures (75%)
- **Kept as Procedure**: 1 (sp_rebuild_projection - complex dynamic SQL)
- **Total SQL Files**: 6

### Core Concepts
- **Event Store**: Immutable log of all domain events
- **Aggregates**: Domain entities rebuilt from events
- **Snapshots**: Point-in-time state captures for performance
- **Projections**: Read models built from event streams

### Benefits
- **Complete Audit Trail**: Every change is captured
- **Time Travel**: Reconstruct state at any point in time
- **Event Replay**: Rebuild state from events
- **Debugging**: Complete history for troubleshooting
- **CQRS Support**: Separate read and write models

## Event Store Management

### Event Append Operations (Converted from sp_append_event)

**append_event.sql**
Appends a new event to the event store.

```sql
-- Appends event to store
-- $1: tenant_id (integer)
-- $2: aggregate_id (uuid)
-- $3: aggregate_type (text)
-- $4: event_type (text)
-- $5: event_data (jsonb)
-- $6: user_id (uuid)
-- $7: metadata (jsonb)
-- $8: version (integer)
INSERT INTO event_store (
    tenant_id,
    aggregate_id,
    aggregate_type,
    event_type,
    event_data,
    metadata,
    version,
    user_id,
    created_at
) VALUES (
    $1, $2, $3, $4, $5, 
    $7 || jsonb_build_object('timestamp', NOW(), 'user_id', $6),
    $8, $6, NOW()
)
RETURNING id;
```

**get_next_event_version.sql**
```sql
-- Gets next version number for aggregate
-- $1: aggregate_id (uuid)
SELECT COALESCE(MAX(version), 0) + 1 as next_version
FROM event_store
WHERE aggregate_id = $1;
```

**Original sp_append_event (Now Converted):**
```sql
-- This procedure has been converted to two SQL files:
-- 1. get_next_event_version.sql - Get version number
-- 2. append_event.sql - Insert event
CREATE OR REPLACE PROCEDURE sp_append_event(
    p_tenant_id INTEGER,
    p_aggregate_id UUID,
    p_aggregate_type TEXT,
    p_event_type TEXT,
    p_event_data JSONB,
    p_user_id UUID,
    p_metadata JSONB,
    OUT p_event_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_version INTEGER;
    v_event_id UUID;
BEGIN
    -- Generate event ID
    v_event_id := gen_random_uuid();
    
    -- Get next version number for this aggregate
    SELECT COALESCE(MAX(version), 0) + 1 INTO v_version
    FROM event_store
    WHERE aggregate_id = p_aggregate_id;
    
    -- Insert event
    INSERT INTO event_store (
        id,
        tenant_id,
        aggregate_id,
        aggregate_type,
        event_type,
        event_data,
        metadata,
        version,
        user_id,
        created_at
    ) VALUES (
        v_event_id,
        p_tenant_id,
        p_aggregate_id,
        p_aggregate_type,
        p_event_type,
        p_event_data,
        p_metadata || jsonb_build_object(
            'timestamp', NOW(),
            'user_id', p_user_id,
            'correlation_id', current_setting('app.correlation_id', true)
        ),
        v_version,
        p_user_id,
        NOW()
    );
    
    -- Return event ID
    p_event_id := v_event_id;
    
    -- Publish event for subscribers
    PERFORM pg_notify(
        'domain_events',
        json_build_object(
            'event_id', v_event_id,
            'aggregate_id', p_aggregate_id,
            'event_type', p_event_type,
            'version', v_version
        )::text
    );
END;
$$;
```

**Parameters:**
- `p_tenant_id`: Tenant identifier for multi-tenant isolation
- `p_aggregate_id`: UUID of the aggregate (entity) this event relates to
- `p_aggregate_type`: Type of aggregate (e.g., 'asset', 'ffc', 'persona')
- `p_event_type`: Type of event (e.g., 'AssetCreated', 'OwnershipTransferred')
- `p_event_data`: JSON payload containing event-specific data
- `p_user_id`: User who triggered the event
- `p_metadata`: Additional metadata (correlation IDs, source, etc.)
- `p_event_id`: (OUT) Generated UUID for the event

**Usage Example:**
```sql
-- Record asset creation event
CALL sp_append_event(
    1,                                          -- Tenant ID
    'asset-uuid-123',                          -- Aggregate ID
    'asset',                                   -- Aggregate type
    'AssetCreated',                            -- Event type
    jsonb_build_object(
        'name', 'Family Home',
        'value', 500000,
        'category', 'real_estate'
    ),                                          -- Event data
    'user-uuid-456',                           -- User ID
    jsonb_build_object('source', 'web_app'),   -- Metadata
    NULL                                        -- OUT parameter
);
```

## Event Replay and Reconstruction

### sp_replay_events
Replays events for an aggregate within a version range.

```sql
CREATE OR REPLACE FUNCTION sp_replay_events(
    p_aggregate_id UUID,
    p_from_version INTEGER DEFAULT 1,
    p_to_version INTEGER DEFAULT NULL
)
RETURNS TABLE(
    event_id UUID,
    version INTEGER,
    event_type TEXT,
    event_data JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.version,
        e.event_type,
        e.event_data,
        e.metadata,
        e.created_at
    FROM event_store e
    WHERE e.aggregate_id = p_aggregate_id
    AND e.version >= COALESCE(p_from_version, 1)
    AND e.version <= COALESCE(p_to_version, 2147483647)
    ORDER BY e.version;
END;
$$ LANGUAGE plpgsql;
```

**Parameters:**
- `p_aggregate_id`: UUID of the aggregate to replay events for
- `p_from_version`: Starting version (inclusive), defaults to 1
- `p_to_version`: Ending version (inclusive), defaults to latest

**Returns:**
- Complete event stream for reconstruction

**Usage Example:**
```sql
-- Replay all events for an asset
SELECT * FROM sp_replay_events('asset-uuid-123');

-- Replay events from version 5 to 10
SELECT * FROM sp_replay_events('asset-uuid-123', 5, 10);

-- Rebuild aggregate state from events
WITH events AS (
    SELECT * FROM sp_replay_events('asset-uuid-123')
)
SELECT 
    aggregate_id,
    jsonb_agg(event_data ORDER BY version) as state_history
FROM events
GROUP BY aggregate_id;
```

## Snapshot Management

### sp_create_snapshot
Creates a snapshot of an aggregate's current state.

```sql
CREATE OR REPLACE PROCEDURE sp_create_snapshot(
    p_aggregate_id UUID,
    p_aggregate_type TEXT,
    p_version INTEGER,
    p_state JSONB
)
LANGUAGE plpgsql AS $$
DECLARE
    v_snapshot_id UUID;
BEGIN
    -- Generate snapshot ID
    v_snapshot_id := gen_random_uuid();
    
    -- Insert snapshot
    INSERT INTO event_snapshots (
        id,
        aggregate_id,
        aggregate_type,
        version,
        state,
        created_at
    ) VALUES (
        v_snapshot_id,
        p_aggregate_id,
        p_aggregate_type,
        p_version,
        p_state,
        NOW()
    )
    ON CONFLICT (aggregate_id, version) 
    DO UPDATE SET
        state = EXCLUDED.state,
        created_at = NOW();
    
    -- Clean up old snapshots (keep last 3)
    DELETE FROM event_snapshots
    WHERE aggregate_id = p_aggregate_id
    AND version < (
        SELECT version 
        FROM event_snapshots 
        WHERE aggregate_id = p_aggregate_id
        ORDER BY version DESC
        LIMIT 1 OFFSET 2
    );
END;
$$;
```

**Parameters:**
- `p_aggregate_id`: UUID of the aggregate
- `p_aggregate_type`: Type of aggregate
- `p_version`: Version number this snapshot represents
- `p_state`: Complete state as JSON

**Features:**
- Automatic cleanup of old snapshots
- Idempotent (can recreate same version)
- Optimizes event replay performance

**Usage Example:**
```sql
-- Create snapshot after every 100 events
DO $$
DECLARE
    v_current_version INTEGER;
    v_state JSONB;
BEGIN
    -- Get current version
    SELECT MAX(version) INTO v_current_version
    FROM event_store
    WHERE aggregate_id = 'asset-uuid-123';
    
    -- Build current state
    SELECT jsonb_agg(event_data) INTO v_state
    FROM sp_replay_events('asset-uuid-123');
    
    -- Create snapshot if at interval
    IF v_current_version % 100 = 0 THEN
        CALL sp_create_snapshot(
            'asset-uuid-123',
            'asset',
            v_current_version,
            v_state
        );
    END IF;
END $$;
```

## Projection Rebuilding

### sp_rebuild_projection
Rebuilds a read model projection from events.

```sql
CREATE OR REPLACE PROCEDURE sp_rebuild_projection(
    p_projection_name TEXT,
    p_aggregate_type TEXT DEFAULT NULL,
    p_aggregate_id UUID DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_event RECORD;
    v_handler_sql TEXT;
BEGIN
    -- Clear existing projection data
    IF p_aggregate_id IS NOT NULL THEN
        EXECUTE format(
            'DELETE FROM %I WHERE aggregate_id = $1',
            p_projection_name || '_projection'
        ) USING p_aggregate_id;
    ELSIF p_aggregate_type IS NOT NULL THEN
        EXECUTE format(
            'DELETE FROM %I WHERE aggregate_type = $1',
            p_projection_name || '_projection'
        ) USING p_aggregate_type;
    ELSE
        EXECUTE format('TRUNCATE TABLE %I', p_projection_name || '_projection');
    END IF;
    
    -- Replay events and rebuild projection
    FOR v_event IN 
        SELECT * FROM event_store e
        WHERE (p_aggregate_id IS NULL OR e.aggregate_id = p_aggregate_id)
        AND (p_aggregate_type IS NULL OR e.aggregate_type = p_aggregate_type)
        ORDER BY e.created_at, e.version
    LOOP
        -- Get handler for this event type
        SELECT handler_sql INTO v_handler_sql
        FROM projection_handlers
        WHERE projection_name = p_projection_name
        AND event_type = v_event.event_type;
        
        -- Execute handler if found
        IF v_handler_sql IS NOT NULL THEN
            EXECUTE v_handler_sql USING v_event;
        END IF;
    END LOOP;
    
    -- Update projection metadata
    INSERT INTO projection_status (
        projection_name,
        last_rebuilt_at,
        last_event_position
    ) VALUES (
        p_projection_name,
        NOW(),
        (SELECT MAX(id) FROM event_store)
    )
    ON CONFLICT (projection_name) 
    DO UPDATE SET
        last_rebuilt_at = NOW(),
        last_event_position = EXCLUDED.last_event_position;
END;
$$;
```

**Parameters:**
- `p_projection_name`: Name of the projection to rebuild
- `p_aggregate_type`: Optional filter by aggregate type
- `p_aggregate_id`: Optional filter by specific aggregate

**Features:**
- Selective rebuilding (single aggregate or type)
- Complete rebuilding (entire projection)
- Handler-based event processing
- Progress tracking

**Usage Example:**
```sql
-- Rebuild entire asset summary projection
CALL sp_rebuild_projection('asset_summary');

-- Rebuild projection for specific asset
CALL sp_rebuild_projection('asset_summary', 'asset', 'asset-uuid-123');

-- Rebuild all projections for asset type
CALL sp_rebuild_projection('asset_summary', 'asset');
```

## Implementation Patterns

### Event Handler Registration
```sql
-- Register projection handlers
INSERT INTO projection_handlers (projection_name, event_type, handler_sql) VALUES
('asset_summary', 'AssetCreated', 
 'INSERT INTO asset_summary_projection (aggregate_id, name, value) 
  VALUES ($1.aggregate_id, $1.event_data->>''name'', $1.event_data->>''value'')'),
('asset_summary', 'AssetValueUpdated',
 'UPDATE asset_summary_projection 
  SET value = $1.event_data->>''new_value'' 
  WHERE aggregate_id = $1.aggregate_id');
```

### Optimistic Concurrency Control
```sql
-- Check version before appending event
CREATE OR REPLACE FUNCTION append_event_with_version_check(
    p_aggregate_id UUID,
    p_expected_version INTEGER,
    p_event_data JSONB
) RETURNS VOID AS $$
DECLARE
    v_current_version INTEGER;
BEGIN
    SELECT MAX(version) INTO v_current_version
    FROM event_store
    WHERE aggregate_id = p_aggregate_id;
    
    IF v_current_version != p_expected_version THEN
        RAISE EXCEPTION 'Concurrency conflict: expected version %, got %',
            p_expected_version, v_current_version;
    END IF;
    
    -- Proceed with event append
    CALL sp_append_event(...);
END;
$$ LANGUAGE plpgsql;
```

### Event Sourcing with Snapshots
```sql
-- Efficient state reconstruction using snapshots
CREATE OR REPLACE FUNCTION get_aggregate_state(p_aggregate_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_snapshot RECORD;
    v_state JSONB;
BEGIN
    -- Get latest snapshot
    SELECT * INTO v_snapshot
    FROM event_snapshots
    WHERE aggregate_id = p_aggregate_id
    ORDER BY version DESC
    LIMIT 1;
    
    IF v_snapshot IS NOT NULL THEN
        -- Start with snapshot state
        v_state := v_snapshot.state;
        
        -- Apply events since snapshot
        FOR v_event IN 
            SELECT * FROM sp_replay_events(
                p_aggregate_id, 
                v_snapshot.version + 1
            )
        LOOP
            v_state := apply_event_to_state(v_state, v_event);
        END LOOP;
    ELSE
        -- No snapshot, replay all events
        SELECT jsonb_agg(event_data) INTO v_state
        FROM sp_replay_events(p_aggregate_id);
    END IF;
    
    RETURN v_state;
END;
$$ LANGUAGE plpgsql;
```

## Performance Considerations

### Indexing Strategy
```sql
-- Event store indexes
CREATE INDEX idx_event_store_aggregate ON event_store(aggregate_id, version);
CREATE INDEX idx_event_store_type ON event_store(aggregate_type, created_at);
CREATE INDEX idx_event_store_tenant ON event_store(tenant_id);

-- Snapshot indexes
CREATE UNIQUE INDEX idx_snapshots_aggregate_version 
ON event_snapshots(aggregate_id, version);

-- Projection status
CREATE UNIQUE INDEX idx_projection_status_name 
ON projection_status(projection_name);
```

### Partitioning Strategy
```sql
-- Partition event store by date for better performance
CREATE TABLE event_store (
    -- columns
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE event_store_2024_01 
PARTITION OF event_store 
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### Archival Strategy
```sql
-- Archive old events to cold storage
CREATE OR REPLACE PROCEDURE archive_old_events(p_days_old INTEGER)
AS $$
BEGIN
    -- Move to archive table
    INSERT INTO event_store_archive
    SELECT * FROM event_store
    WHERE created_at < NOW() - INTERVAL '%s days', p_days_old;
    
    -- Delete from main store
    DELETE FROM event_store
    WHERE created_at < NOW() - INTERVAL '%s days', p_days_old;
END;
$$ LANGUAGE plpgsql;
```

## Best Practices

### Event Design
1. **Immutability**: Never update or delete events
2. **Self-Contained**: Events should contain all necessary data
3. **Past Tense**: Name events in past tense (AssetCreated, not CreateAsset)
4. **Versioning**: Include schema version in events for evolution
5. **Correlation**: Include correlation IDs for tracing

### Projection Design
1. **Eventually Consistent**: Accept eventual consistency
2. **Idempotent Handlers**: Handlers should be idempotent
3. **Separate Concerns**: One projection per read model
4. **Rebuild Capability**: Always be able to rebuild from events

### Snapshot Strategy
1. **Frequency**: Balance between performance and storage
2. **Cleanup**: Remove old snapshots to save space
3. **Validation**: Verify snapshot integrity periodically
4. **Versioning**: Handle schema evolution in snapshots

### Error Handling
```sql
-- Robust error handling in event processing
BEGIN
    -- Process event
    CALL process_event(v_event);
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't stop processing
        INSERT INTO event_processing_errors (
            event_id,
            error_message,
            error_detail,
            occurred_at
        ) VALUES (
            v_event.id,
            SQLERRM,
            SQLSTATE,
            NOW()
        );
END;
```

### Monitoring
1. **Event Lag**: Monitor delay between event creation and processing
2. **Projection Lag**: Track how far behind projections are
3. **Error Rate**: Monitor failed event processing
4. **Storage Growth**: Track event store size growth

---

*This documentation covers the event sourcing system within the Forward Inheritance Platform, providing a robust foundation for event-driven architecture with complete audit trails, state reconstruction, and CQRS support.*