# 15 - pgTyped and Slonik Implementation Guide

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Migration Summary](#migration-summary)
3. [pgTyped Configuration](#pgtyped-configuration)
4. [Slonik Client Setup](#slonik-client-setup)
5. [SQL Query Organization](#sql-query-organization)
6. [Implementation Patterns](#implementation-patterns)
7. [Testing Strategy](#testing-strategy)
8. [Migration Roadmap](#migration-roadmap)

## Architecture Overview

The Forward Inheritance Platform has migrated from a stored procedure-centric architecture to a modern type-safe approach using:

- **pgTyped**: Compile-time SQL type safety
- **Slonik**: Runtime PostgreSQL client
- **Single Source of Truth**: Each query in one `.sql` file

### Key Benefits
1. **Type Safety**: Compile-time validation prevents runtime SQL errors
2. **Version Control**: Individual SQL files enable better change tracking
3. **Testing**: Easier to test individual queries in isolation
4. **Performance**: Query optimization is more transparent
5. **Maintenance**: Simpler to update and debug individual operations

## Migration Summary

### Conversion Statistics
- **Total Procedures**: 70
- **Converted to SQL**: 59 (84%)
- **Kept as Procedures**: 10 (14%)
- **Trigger Functions**: 1 (2%)
- **Total SQL Files**: 109 (99 conversions + 10 wrappers)

### Conversion Breakdown by Category

| Category | Original Procs | Converted | SQL Files | Kept as Procs |
|----------|---------------|-----------|-----------|---------------|
| Authentication & Session | 5 | 5 | 5 | 0 |
| User Management | 2 | 1 | 1 | 1 |
| FFC Management | 4 | 4 | 5 | 1 |
| Asset Management | 10 | 10 | 15 | 1 |
| Contact Management | 2 | 2 | 6 | 0 |
| Subscription & Payment | 18 | 13 | 20 | 5 |
| Audit & Compliance | 4 | 4 | 5 | 0 |
| Event Sourcing | 4 | 3 | 6 | 1 |
| Integrations | 18 | 15 | 30+ | 3 |
| Other | 3 | 2 | 6 | 0 |
| **TOTAL** | **70** | **59** | **99** | **10** |

## pgTyped Configuration

### Configuration File
Location: `/apps/api/scripts/pgtyped.config.json`

```json
{
  "$schema": "https://raw.githubusercontent.com/adelsz/pgtyped/master/packages/pgtyped/bin/config.schema.json",
  "srcDir": "docs/requirements/DB/sql scripts/5_SQL_files",
  "glob": "*.sql",
  "failOnError": true,
  "db": {
    "host": "localhost",
    "port": 15432,
    "user": "postgres",
    "password": "FGt!3reGTdt5BG!",
    "database": "fwd_db",
    "ssl": false
  },
  "typeOverrides": [],
  "outDir": "apps/api/generated/pgtyped",
  "camelCaseColumnNames": true,
  "watch": false
}
```

### Type Generation
pgTyped generates TypeScript interfaces for:
- Query parameters (`Params`)
- Query results (`Row`)
- Each `.sql` file gets a corresponding `.types.ts` file

## Slonik Client Setup

### Client Configuration
Location: `/apps/api/src/common/slonik.client.ts`

```typescript
import { createPool } from 'slonik';

export const slonikPool = createPool(
  process.env.DATABASE_URL || 'postgresql://postgres:FGt!3reGTdt5BG!@localhost:15432/fwd_db',
  {
    maximumPoolSize: 10,
    minimumPoolSize: 2,
    connectionTimeout: 60000,
    idleTimeout: 30000,
    statementTimeout: 30000,
    interceptors: [
      // Query logging
      // Performance monitoring
      // Error handling
    ]
  }
);
```

## SQL Query Organization

### File Structure
```
/docs/requirements/DB/sql scripts/5_SQL_files/
├── Authentication/
│   ├── current_user_id.sql
│   ├── current_tenant_id.sql
│   ├── is_ffc_member.sql
│   ├── set_session_context.sql
│   └── clear_session_context.sql
├── Assets/
│   ├── get_asset_details.sql
│   ├── search_assets.sql
│   ├── update_asset_details.sql
│   └── ... (12 more files)
├── Subscriptions/
│   ├── calculate_seat_availability.sql
│   ├── get_subscription_status.sql
│   └── ... (18 more files)
├── Wrappers/
│   ├── call_sp_create_user_from_cognito.sql
│   ├── call_sp_create_asset.sql
│   └── ... (8 more files)
└── COMPLETE_70_PROCEDURE_MAPPING.md
```

### Naming Conventions
- **Actions**: `create_`, `update_`, `delete_`, `get_`, `check_`, `validate_`
- **Entities**: Singular form (e.g., `asset`, `subscription`, `payment`)
- **Modifiers**: Descriptive suffixes (e.g., `_if_not_exists`, `_with_usage`)

## Implementation Patterns

### Simple Query Pattern
```sql
-- get_asset_details.sql
-- $1: asset_id (uuid)
SELECT 
    a.id,
    a.name,
    a.description,
    a.estimated_value,
    ac.name as category_name
FROM assets a
JOIN asset_categories ac ON a.category_id = ac.id
WHERE a.id = $1;
```

### Multi-Step Operation Pattern
```sql
-- create_ffc_step1.sql
-- $1: tenant_id (integer)
-- $2: name (text)
-- $3: description (text)
-- $4: owner_user_id (uuid)
INSERT INTO fwd_family_circles (
    tenant_id, 
    name, 
    description, 
    owner_user_id
) VALUES ($1, $2, $3, $4)
RETURNING id;

-- create_ffc_step2.sql
-- $1: tenant_id (integer)
-- $2: ffc_id (uuid)
-- $3: persona_id (uuid)
INSERT INTO ffc_personas (
    tenant_id,
    ffc_id,
    persona_id,
    ffc_role
) VALUES ($1, $2, $3, 'owner');
```

### Complex Procedure Wrapper Pattern
```sql
-- call_sp_create_asset.sql
-- Wrapper for complex stored procedure
-- $1: tenant_id (integer)
-- $2: owner_persona_id (uuid)
-- $3: asset_type (asset_type_enum)
-- $4: name (text)
-- $5: description (text)
-- $6: ownership_percentage (decimal)
-- $7: created_by_user_id (uuid)
SELECT * FROM sp_create_asset($1, $2, $3, $4, $5, $6, $7);
```

## Testing Strategy

### Test Coverage Achievement
- **Stored Procedures**: 100% (11/11 tests passing)
- **SQL Files**: 98% (100/102 tests passing)
- **Known Failures**: 2 (expected due to business constraints)

### Test Implementation
Location: `/docs/requirements/DB/Node JS scripts/test-data-generator/`

Key test files:
1. `1-populate-database.ts` - Creates comprehensive test data
2. `2-test-stored-procedures.ts` - Tests remaining stored procedures
3. `3-test-sql-files.ts` - Tests all converted SQL files

### Running Tests
```bash
cd docs/requirements/DB/Node JS scripts/test-data-generator
npx tsx run-all.ts
```

## Migration Roadmap

### Phase 1: Core Operations ✅ (Complete)
- Authentication & session management
- User and FFC management
- Basic asset operations
- Contact management

### Phase 2: Business Logic ✅ (Complete)
- Subscription management
- Payment processing
- Audit logging
- Compliance reporting

### Phase 3: Integrations ✅ (Complete)
- External system connectors
- Data synchronization
- Health monitoring
- Retry mechanisms

### Phase 4: Optimization (Next Steps)
1. **Query Performance**
   - Add appropriate indexes
   - Optimize complex queries
   - Implement query caching

2. **Type Refinement**
   - Custom type overrides for complex types
   - Enum type mapping
   - Nullable field handling

3. **Error Handling**
   - Standardized error codes
   - Retry logic for transient failures
   - Circuit breaker patterns

4. **Monitoring**
   - Query performance metrics
   - Connection pool monitoring
   - Error rate tracking

### Remaining Complex Procedures

The following 10 procedures remain as stored procedures due to complexity:

1. **sp_create_user_from_cognito** - Multi-table transactional user creation
2. **sp_create_asset** - Complex asset creation with validation
3. **sp_create_ffc_with_subscription** - FFC with automatic subscription
4. **sp_process_seat_invitation** - Complex invitation workflow
5. **sp_purchase_service** - Payment processing logic
6. **sp_process_stripe_webhook** - Dynamic webhook routing
7. **sp_rebuild_projection** - Event sourcing projection
8. **sp_sync_quiltt_data** - Financial data synchronization
9. **sp_sync_real_estate_data** - Property data sync
10. **sp_refresh_builder_content** - CMS content refresh

These procedures contain:
- Complex transaction management
- Dynamic SQL generation
- Multi-step validation logic
- External system coordination

## Best Practices

### Query Writing
1. Always include parameter comments
2. Use explicit column lists (no `SELECT *`)
3. Include appropriate indexes in comments
4. Keep queries focused and single-purpose

### Type Safety
1. Run pgTyped generation before builds
2. Commit generated types to version control
3. Use strict TypeScript settings
4. Validate nullable fields

### Performance
1. Use prepared statements via Slonik
2. Implement connection pooling
3. Monitor query execution times
4. Use appropriate transaction isolation

### Security
1. Never concatenate user input
2. Use parameterized queries exclusively
3. Implement row-level security
4. Audit all data modifications

## Conclusion

The migration to pgTyped and Slonik represents a significant modernization of the Forward Inheritance Platform's database layer. With 84% of stored procedures successfully converted to type-safe SQL queries, the platform now benefits from:

- Compile-time type safety
- Better maintainability
- Improved testing capabilities
- Enhanced performance visibility
- Simplified deployment

The remaining 10 complex procedures are strategically kept as stored procedures where their transactional complexity and business logic requirements justify the trade-off. Each has a corresponding wrapper file for pgTyped compatibility, ensuring consistent type safety across the entire application.