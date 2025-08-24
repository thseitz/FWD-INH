/** Types generated for queries found in "apps/api/src/app/database/queries/08_audit/events/create_audit_event.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateAuditEvent' parameters type */
export type ICreateAuditEventParams = void;

/** 'CreateAuditEvent' return type */
export interface ICreateAuditEventResult {
  description: string;
  event_category: string;
  event_type: string;
  id: string;
  occurred_at: Date | null;
  severity: string;
}

/** 'CreateAuditEvent' query type */
export interface ICreateAuditEventQuery {
  params: ICreateAuditEventParams;
  result: ICreateAuditEventResult;
}

const createAuditEventIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_audit_event()\n-- Type: Single INSERT with CASE logic\n-- Description: Create an audit event record\n-- Parameters:\n--   $1: p_event_type TEXT - Type of event\n--   $2: p_event_category VARCHAR(50) - Event category\n--   $3: p_description TEXT - Event description\n--   $4: p_risk_level VARCHAR(20) - Risk level (default 'low')\n--   $5: p_compliance_framework VARCHAR(50) - Compliance framework (default 'SOC2')\n--   $6: p_metadata JSONB - Additional metadata (default '{}')\n--   $7: p_user_id UUID - User ID (optional)\n-- Returns: Created audit event record\n-- ================================================================\n\n-- This query creates an audit event with risk level mapping\n-- Includes CASE logic for severity mapping\n\nINSERT INTO audit_events (\n    tenant_id,\n    event_type,\n    event_category,\n    severity,\n    description,\n    details,\n    source_system,\n    source_ip,\n    user_id,\n    session_id,\n    occurred_at,\n    detected_at\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    $1::TEXT,\n    $2::VARCHAR(50),\n    CASE COALESCE($4::VARCHAR(20), 'low')\n        WHEN 'critical' THEN 'critical'\n        WHEN 'high' THEN 'error'\n        WHEN 'medium' THEN 'warning'\n        WHEN 'low' THEN 'info'\n        ELSE 'info'\n    END,\n    $3::TEXT,\n    COALESCE($6::JSONB, '{}'::JSONB) || jsonb_build_object(\n        'risk_level', COALESCE($4::VARCHAR(20), 'low'),\n        'compliance_framework', COALESCE($5::VARCHAR(50), 'SOC2')\n    ),\n    COALESCE(($6::JSONB)->>'source_system', 'application'),\n    COALESCE((($6::JSONB)->>'source_ip')::inet, inet_client_addr()),\n    COALESCE(\n        $7::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    CASE \n        WHEN current_setting('app.session_id', true) IS NOT NULL \n        THEN current_setting('app.session_id', true)::UUID \n        ELSE NULL \n    END,\n    NOW(),\n    NOW()\n)\nRETURNING \n    id,\n    event_type,\n    event_category,\n    severity,\n    description,\n    occurred_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_audit_event()
 * -- Type: Single INSERT with CASE logic
 * -- Description: Create an audit event record
 * -- Parameters:
 * --   $1: p_event_type TEXT - Type of event
 * --   $2: p_event_category VARCHAR(50) - Event category
 * --   $3: p_description TEXT - Event description
 * --   $4: p_risk_level VARCHAR(20) - Risk level (default 'low')
 * --   $5: p_compliance_framework VARCHAR(50) - Compliance framework (default 'SOC2')
 * --   $6: p_metadata JSONB - Additional metadata (default '{}')
 * --   $7: p_user_id UUID - User ID (optional)
 * -- Returns: Created audit event record
 * -- ================================================================
 * 
 * -- This query creates an audit event with risk level mapping
 * -- Includes CASE logic for severity mapping
 * 
 * INSERT INTO audit_events (
 *     tenant_id,
 *     event_type,
 *     event_category,
 *     severity,
 *     description,
 *     details,
 *     source_system,
 *     source_ip,
 *     user_id,
 *     session_id,
 *     occurred_at,
 *     detected_at
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     $1::TEXT,
 *     $2::VARCHAR(50),
 *     CASE COALESCE($4::VARCHAR(20), 'low')
 *         WHEN 'critical' THEN 'critical'
 *         WHEN 'high' THEN 'error'
 *         WHEN 'medium' THEN 'warning'
 *         WHEN 'low' THEN 'info'
 *         ELSE 'info'
 *     END,
 *     $3::TEXT,
 *     COALESCE($6::JSONB, '{}'::JSONB) || jsonb_build_object(
 *         'risk_level', COALESCE($4::VARCHAR(20), 'low'),
 *         'compliance_framework', COALESCE($5::VARCHAR(50), 'SOC2')
 *     ),
 *     COALESCE(($6::JSONB)->>'source_system', 'application'),
 *     COALESCE((($6::JSONB)->>'source_ip')::inet, inet_client_addr()),
 *     COALESCE(
 *         $7::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     CASE 
 *         WHEN current_setting('app.session_id', true) IS NOT NULL 
 *         THEN current_setting('app.session_id', true)::UUID 
 *         ELSE NULL 
 *     END,
 *     NOW(),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     event_type,
 *     event_category,
 *     severity,
 *     description,
 *     occurred_at
 * ```
 */
export const createAuditEvent = new PreparedQuery<ICreateAuditEventParams,ICreateAuditEventResult>(createAuditEventIR);


