# Database Duplication Audit Report

**Date:** August 24, 2025  
**Audit Scope:** Stored Procedures/Functions vs SQL Files  
**Database:** fwd_db (PostgreSQL 17)  

## 🎯 Executive Summary

The audit revealed significant duplication between stored procedures/functions and SQL files. You currently have **70 stored procedures/functions** and **117 SQL files**, with **38 duplicated functions** that should be removed to maintain your intended architecture of using Slonik-controlled SQL files instead of stored procedures.

## 📊 Current State Analysis

### Database Objects
- **Total Stored Routines:** 70
  - Functions: 67
  - Procedures: 3
- **Total SQL Files:** 117
- **Duplicated Functionality:** 38 items (54% of stored routines)

### Architecture Goals vs Reality
**Your Intent:** Keep only 11 complex stored procedures, move everything else to SQL files for Slonik control  
**Current Reality:** 70 stored procedures/functions with significant overlap

## 🚨 Critical Issues Identified

### 1. Exact Name Matches (3 items)
These functions exist identically in both database and SQL files:
- `current_tenant_id`
- `current_user_id` 
- `is_ffc_member`

**Impact:** Confusion over which version is being used, potential inconsistencies

### 2. Functional Duplicates (35 items)
Stored procedures with `sp_` prefix that duplicate SQL files:

| Stored Procedure | SQL File | Status |
|-----------------|----------|--------|
| `sp_add_persona_to_ffc` | `add_persona_to_ffc.sql` | ❌ Duplicate |
| `sp_append_event` | `append_event.sql` | ❌ Duplicate |
| `sp_calculate_seat_availability` | `calculate_seat_availability.sql` | ❌ Duplicate |
| `sp_cancel_subscription` | `cancel_subscription.sql` | ❌ Duplicate |
| `sp_check_payment_method_usage` | `check_payment_method_usage.sql` | ❌ Duplicate |
| `sp_clear_session_context` | `clear_session_context.sql` | ❌ Duplicate |
| `sp_configure_builder_io` | `configure_builder_io.sql` | ❌ Duplicate |
| `sp_configure_quiltt_integration` | `configure_quiltt_integration.sql` | ❌ Duplicate |
| ... | ... | *[30 more items]* |

### 3. Call Wrapper Files (10 items)
SQL files that only call stored procedures (potentially unnecessary):
- `call_sp_create_asset.sql` → calls `sp_create_asset`
- `call_sp_create_ffc_with_subscription.sql` → calls `sp_create_ffc_with_subscription`
- `call_sp_process_stripe_webhook.sql` → calls `sp_process_stripe_webhook`
- *[7 more similar wrappers]*

## ✅ Correctly Architected Items

### Database-Only Stored Procedures (32 items)
These stored procedures have no SQL file equivalents and represent your intended complex business logic:

**Core 11 Complex Procedures (Your Original Intent):**
- `sp_create_ffc_with_subscription` - Complex FFC creation with subscription setup
- `sp_process_seat_invitation` - Multi-step invitation processing 
- `sp_process_stripe_webhook` - Webhook event handling with state management
- `sp_purchase_service` - Payment processing with multiple validations
- `sp_handle_subscription_created` - Subscription lifecycle management
- `sp_handle_subscription_updated` - Subscription modification handling
- `sp_handle_subscription_deleted` - Subscription cleanup
- `sp_transition_subscription_plan` - Plan change orchestration

**Additional Complex Procedures (May be candidates for SQL file conversion):**
- `sp_create_user_from_cognito` - User creation from external auth
- `sp_sync_quiltt_data` - External API synchronization
- `sp_sync_real_estate_data` - Real estate API integration
- `sp_rebuild_projection` - Event sourcing projection rebuild
- `sp_refresh_builder_content` - Builder.io content refresh
- *[19 more items]*

### SQL-Only Files (69 items)
These SQL files have no stored procedure duplicates and represent your intended Slonik-controlled queries:
- Asset management queries (15 files)
- User and persona operations (12 files)  
- Integration health checks (8 files)
- Audit and compliance queries (10 files)
- *[24 more categories]*

## 💡 Cleanup Recommendations

### Phase 1: Remove Exact Duplicates (High Priority)
**Impact:** Immediate - eliminates confusion
```sql
-- Remove these 3 functions that exactly duplicate SQL files
DROP FUNCTION current_tenant_id();
DROP FUNCTION current_user_id(); 
DROP FUNCTION is_ffc_member();
```

### Phase 2: Remove Functional Duplicates (High Priority)
**Impact:** Major cleanup - removes 35 stored procedures
```sql
-- Remove all sp_* functions that have equivalent SQL files
DROP FUNCTION sp_add_persona_to_ffc();
DROP FUNCTION sp_append_event();
DROP FUNCTION sp_calculate_seat_availability();
-- ... [32 more DROP statements]
```

### Phase 3: Review Call Wrappers (Medium Priority)
**Decision needed:** Keep or remove the 10 `call_sp_*.sql` files
- **Keep if:** You want SQL file interface to stored procedures
- **Remove if:** You prefer direct stored procedure calls

### Phase 4: Validate Core Procedures (Low Priority)
**Review needed:** Confirm these 11 procedures should remain as stored procedures:
1. `sp_create_ffc_with_subscription`
2. `sp_process_seat_invitation`
3. `sp_process_stripe_webhook`
4. `sp_purchase_service`
5. `sp_handle_subscription_*` (4 procedures)
6. `sp_transition_subscription_plan`

## 📈 Expected Outcomes

### Before Cleanup
- **Database:** 70 stored routines + 117 SQL files = 187 database objects
- **Duplication:** 38 overlapping functions (20% waste)
- **Architecture:** Inconsistent (stored procedures vs SQL files)

### After Cleanup  
- **Database:** ~32 stored procedures + 117 SQL files = 149 database objects
- **Duplication:** 0 overlapping functions
- **Architecture:** Clean separation (complex procedures vs simple SQL)
- **Reduction:** 38 fewer stored procedures (54% cleanup)

## 🔧 Implementation Plan

### Step 1: Backup Current State
```bash
# Backup current database schema
docker exec fwd-inh-database pg_dump -U postgres -s fwd_db > schema_backup.sql
```

### Step 2: Generate Cleanup Scripts
```bash
# Use the provided audit script to generate DROP statements
node scripts/audit-database-duplicates.js > cleanup_plan.sql
```

### Step 3: Test SQL Files
```bash
# Ensure all SQL files work before removing stored procedures
node scripts/build-database.js
```

### Step 4: Execute Cleanup
```bash
# Apply the cleanup (run DROP statements)
# Test thoroughly after each phase
```

## ⚠️ Risk Assessment

### Low Risk
- Removing exact duplicates (`current_tenant_id`, etc.)
- These functions are simple and SQL equivalents are tested

### Medium Risk  
- Removing functional duplicates (`sp_*` functions)
- Ensure all application code uses SQL files, not stored procedures

### High Risk
- Modifying call wrapper files
- These may be used by external integrations

## 🎯 Success Criteria

1. **Functional:** All 117 SQL files pass testing (currently ✅ 117/117)
2. **Architectural:** Only intended complex stored procedures remain (~11)
3. **Performance:** No degradation in query execution times
4. **Consistency:** Clear separation between stored procedures and SQL files

## 📋 Next Steps

1. **Review this report** and confirm cleanup approach
2. **Generate cleanup script** with specific DROP statements  
3. **Execute Phase 1** (exact duplicates) in development
4. **Test thoroughly** after each cleanup phase
5. **Update documentation** to reflect clean architecture

---

**Audit completed by:** Database Build Script  
**Tools used:** PostgreSQL system catalogs, file system analysis  
**Validation:** All 117 SQL files tested and passing