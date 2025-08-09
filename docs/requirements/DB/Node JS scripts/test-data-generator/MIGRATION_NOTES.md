# Node.js Test Data Generator - Migration Notes

## Changes Required for Updated SQL Schema

### Summary
The test data generator has been updated to work with the new stored procedures implemented after Robin's feedback. Key changes include AWS Cognito integration, updated stored procedure signatures, and proper user_id handling.

## Major Changes

### 1. User Registration - AWS Cognito Integration
**Old:** `sp_register_user` with password management
**New:** `sp_create_user_from_cognito` without passwords

```typescript
// Old signature
sp_register_user(tenant_id, email, phone, password_hash, password_salt, first_name, last_name)

// New signature  
sp_create_user_from_cognito(tenant_id, cognito_user_id, cognito_username, email, phone, first_name, last_name, email_verified, phone_verified, country_code)
```

**Changes Made:**
- Removed password generation
- Added Cognito user ID simulation
- Added verified flags (set to true for testing)
- Added country code parameter

### 2. FFC Member Management
**Old:** `sp_add_ffc_member`
**New:** `sp_add_persona_to_ffc`

```typescript
// Old signature
sp_add_ffc_member(tenant_id, ffc_id, persona_id, role)

// New signature
sp_add_persona_to_ffc(tenant_id, ffc_id, persona_id, role, added_by_user_id)
```

**Changes Made:**
- Function name change
- Added `added_by` user_id parameter for audit trail
- Requires fetching user_id from personas table

### 3. Asset Creation
**Old:** Used category codes directly
**New:** Uses asset_type_enum and owner_persona_id

```typescript
// Old signature
sp_create_asset(tenant_id, ffc_id, category_code, name, description, value, created_by)

// New signature
sp_create_asset(tenant_id, ffc_id, owner_persona_id, asset_type, name, description, ownership_percentage, created_by_user_id)
```

**Changes Made:**
- Added asset type mapping to enum values
- Changed from category_code to asset_type enum
- Added owner_persona_id (the persona who owns the asset)
- Added ownership_percentage parameter
- created_by now requires user_id not persona_id

### 4. Asset Ownership Assignment
**Old:** Included tenant_id
**New:** Removed tenant_id, simplified

```typescript
// Old signature
sp_assign_asset_to_persona(tenant_id, asset_id, persona_id, ownership_type, percentage, is_primary, assigned_by)

// New signature
sp_assign_asset_to_persona(asset_id, persona_id, ownership_type, percentage, is_primary, assigned_by_user_id)
```

**Changes Made:**
- Removed tenant_id parameter
- assigned_by now requires user_id

### 5. Asset Value Updates
**Old:** Simple value update
**New:** Includes valuation method

```typescript
// Old signature
sp_update_asset_value(asset_id, value, date, updated_by)

// New signature
sp_update_asset_value(asset_id, value, valuation_date, valuation_method, updated_by_user_id)
```

**Changes Made:**
- Added valuation_method parameter
- updated_by now requires user_id

## Asset Type Enum Mapping

```typescript
const assetTypeMap = {
  'personal_directives': 'directive',
  'trust': 'trust',
  'will': 'will',
  'personal_property': 'personal_property',
  'operational_property': 'vehicle',
  'inventory': 'inventory',
  'real_estate': 'real_estate',
  'life_insurance': 'life_insurance',
  'financial_accounts': 'bank_account',
  'recurring_income': 'recurring_income',
  'digital_assets': 'digital_asset',
  'ownership_interests': 'business_interest',
  'loans': 'loan'
};
```

## Common Pattern: Persona ID to User ID

Many stored procedures now require user_id instead of persona_id for audit trail purposes. Common pattern:

```typescript
// Get user_id from persona
const userResult = await client.query(
  `SELECT user_id FROM personas WHERE id = $1`,
  [personaId]
);
const userId = userResult.rows[0]?.user_id;
```

## Testing Recommendations

1. **Database Setup:**
   - Run scripts in order: 1 → 2 → 3 → 4
   - Ensure all 46 stored procedures are created
   - Verify RLS policies are in place

2. **Test Data Generation:**
   - Start with small batches (1-2 FFCs)
   - Verify Cognito IDs are unique
   - Check audit_log table for proper tracking

3. **Validation:**
   - Confirm asset ownership percentages sum to 100%
   - Verify all personas have associated users
   - Check FFC membership roles are correct

## Environment Variables

Add these to `.env` for testing:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fwd_db
DB_USER=postgres
DB_PASSWORD=your_password

# Test Configuration
TEST_TENANT_ID=1
COGNITO_USER_POOL_ID=test-pool-id
GENERATE_COGNITO_IDS=true
```

## Error Handling

Common errors and solutions:

1. **"function sp_register_user does not exist"**
   - Solution: Update to use sp_create_user_from_cognito

2. **"column owner_id does not exist"**
   - Solution: Use owner_user_id for FFCs, owner_persona_id for assets

3. **"asset_type invalid input value"**
   - Solution: Ensure asset_type matches enum values in database

4. **"user_id cannot be null"**
   - Solution: Fetch user_id from personas table before calling SP

## Next Steps

1. Update API endpoints to match new stored procedure signatures
2. Implement proper Cognito integration for production
3. Add error recovery for partial data generation
4. Implement batch processing for large datasets
5. Add comprehensive logging for debugging