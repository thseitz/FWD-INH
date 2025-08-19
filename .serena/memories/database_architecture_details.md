# Database Architecture Details

## Overview
PostgreSQL 14+ database with 70+ tables and 69 stored procedures implementing a multi-tenant SaaS architecture for estate planning and wealth management.

## Key Design Principles

### Multi-Tenancy
- **Tenant Isolation**: All tables have `tenant_id` for data segregation
- **Row-Level Security**: RLS policies enforce tenant boundaries
- **Cross-Tenant Queries**: Prevented at database level

### Security Architecture
- **AWS Cognito Integration**: External auth with local user mapping
- **Dual Identity System**: Users (auth) vs Personas (business entities)
- **Audit Everything**: Comprehensive audit_log table for SOC 2 compliance
- **PII Protection**: Masking capabilities for sensitive data

### Database-First Approach
- **Stored Procedures Only**: No direct table access from application
- **Type Safety**: pgtyped generates TypeScript types from SQL
- **Performance**: Optimized queries at database level
- **Security**: SQL injection prevention through procedures

## Core Tables Structure

### Identity Management
- **tenants**: Multi-tenant root (white-label partners)
- **users**: Authentication entities (Cognito mapping)
- **personas**: Business entities (actual people)
- **fwd_family_circles**: Family groupings for collaboration
- **ffc_memberships**: Links personas to family circles

### Asset Management
- **assets**: Base asset table (13 types supported)
- **asset_ownerships**: Ownership percentages
- **asset_permissions**: View/edit permissions
- **asset_valuations**: Historical value tracking
- **asset_categories**: Asset classification

### Asset Type Tables
- **asset_bank_accounts**: Banking details
- **asset_investment_accounts**: Investment portfolios
- **asset_real_estate**: Property information
- **asset_vehicles**: Vehicle details
- **asset_businesses**: Business interests
- **asset_life_insurance**: Insurance policies
- **asset_personal_property**: Personal items
- **asset_debts**: Liabilities
- **asset_cryptocurrencies**: Digital currencies
- **asset_retirement_accounts**: 401k, IRA, etc.
- **asset_collectibles**: Art, antiques
- **asset_intellectual_property**: Patents, copyrights
- **asset_misc**: Other assets

### Subscription & Payments
- **subscription_plans**: Plan definitions
- **plan_features**: Feature flags per plan
- **subscriptions**: Active subscriptions
- **subscription_seats**: User seat assignments
- **payment_methods**: Stored payment methods
- **payment_transactions**: Transaction history
- **invoices**: Billing records
- **stripe_webhook_events**: Webhook processing queue
- **general_ledger**: Single-entry accounting

### Security & Compliance
- **audit_log**: Complete audit trail
- **security_questions**: Account recovery
- **password_history**: Password rotation tracking
- **mfa_settings**: Multi-factor auth config
- **user_sessions**: Active session management
- **api_keys**: API access management

## Key Stored Procedures

### User Management
- `sp_register_user`: New user registration
- `sp_authenticate_user`: Login validation
- `sp_create_persona`: Create business entity
- `sp_link_user_persona`: Connect user to persona

### Family Circles
- `sp_create_ffc`: Create family circle
- `sp_add_ffc_member`: Add family member
- `sp_update_ffc_member_role`: Change permissions
- `sp_get_ffc_hierarchy`: View family structure

### Asset Operations
- `sp_create_asset`: Add new asset
- `sp_assign_asset_to_persona`: Set ownership
- `sp_update_asset_value`: Record valuation
- `sp_get_persona_assets`: List owned assets
- `sp_calculate_net_worth`: Total calculations

### Subscription Management
- `sp_create_subscription`: New subscription
- `sp_assign_free_plan`: Auto-assign free tier
- `sp_upgrade_subscription`: Plan changes
- `sp_process_payment`: Payment handling
- `sp_calculate_usage`: Usage tracking

## Performance Optimizations

### Indexes
- Primary keys: B-tree indexes
- Foreign keys: Indexed for joins
- Search fields: GIN indexes for full-text
- Tenant isolation: Composite indexes with tenant_id
- Temporal queries: BRIN indexes on timestamps

### Views
- `v_active_subscriptions`: Current subscriptions
- `v_payment_summary`: Payment analytics
- `v_asset_summary`: Asset overview
- `v_family_hierarchy`: Family relationships

## Data Integrity

### Constraints
- Foreign key relationships enforced
- Check constraints for business rules
- Unique constraints for natural keys
- NOT NULL for required fields
- Default values for timestamps

### Triggers
- Audit log triggers on all tables
- Updated_at timestamp maintenance
- Subscription seat management
- Usage tracking calculations

## Backup & Recovery
- Point-in-time recovery enabled
- Daily automated backups
- Cross-region replication
- 30-day retention policy