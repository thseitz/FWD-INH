# 05 - Contact Management Procedures

## Table of Contents
1. [Overview](#overview)
2. [Email Management](#email-management)
3. [Phone Management](#phone-management)
4. [Usage Patterns](#usage-patterns)
5. [Data Integrity](#data-integrity)
6. [Security Considerations](#security-considerations)

## Overview

The contact management procedures handle the association of email addresses and phone numbers with personas in the Forward Inheritance Platform. These procedures work with the normalized contact information architecture that eliminates data duplication while maintaining flexibility for multiple usage contexts.

### Architecture Benefits
- **Single Source of Truth**: One record per unique email/phone
- **Multiple Usage Contexts**: Same contact info can be used for different purposes
- **Privacy Controls**: Separate personal vs business contact information
- **Audit Trail**: Complete history of contact information changes

## Email Management

### sp_add_email_to_persona
Associates an email address with a persona, creating the email record if needed.

```sql
CREATE OR REPLACE PROCEDURE sp_add_email_to_persona(
    p_persona_id UUID,
    p_email TEXT,
    p_email_type email_type_enum,
    p_usage_type email_usage_type_enum,
    p_is_primary BOOLEAN
)
LANGUAGE plpgsql AS $$
DECLARE
    v_email_id UUID;
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant ID from persona
    SELECT p.tenant_id INTO v_tenant_id
    FROM personas p
    WHERE p.id = p_persona_id;
    
    -- Insert or get existing email
    INSERT INTO email_address (
        tenant_id,
        email_address,
        email_type,
        is_verified,
        created_by
    ) VALUES (
        v_tenant_id,
        LOWER(TRIM(p_email)),
        p_email_type,
        FALSE,
        current_user_id()
    )
    ON CONFLICT (tenant_id, email_address) 
    DO UPDATE SET
        updated_at = NOW()
    RETURNING id INTO v_email_id;
    
    -- Create usage record
    INSERT INTO usage_email (
        tenant_id,
        entity_type,
        entity_id,
        email_id,
        usage_type,
        is_primary
    ) VALUES (
        v_tenant_id,
        'persona',
        p_persona_id,
        v_email_id,
        p_usage_type,
        p_is_primary
    )
    ON CONFLICT (entity_type, entity_id, email_id, usage_type)
    DO UPDATE SET
        is_primary = EXCLUDED.is_primary,
        updated_at = NOW();
    
    -- If marking as primary, unset other primary emails for this persona
    IF p_is_primary THEN
        UPDATE usage_email
        SET is_primary = FALSE
        WHERE entity_type = 'persona'
        AND entity_id = p_persona_id
        AND email_id != v_email_id
        AND usage_type = p_usage_type;
    END IF;
END;
$$;
```

**Parameters:**
- `p_persona_id`: UUID of the persona to associate the email with
- `p_email`: Email address to add (automatically normalized to lowercase)
- `p_email_type`: Type of email (personal, work, other)
- `p_usage_type`: Usage context (primary, billing, notifications, recovery, marketing)
- `p_is_primary`: Whether this should be the primary email for this usage type

**Features:**
- Automatically normalizes email to lowercase
- Creates email record if it doesn't exist
- Handles duplicate associations gracefully
- Manages primary email designation
- Maintains audit trail

**Usage Example:**
```sql
-- Add primary personal email
CALL sp_add_email_to_persona(
    'persona-uuid-123',
    'john.smith@example.com',
    'personal',
    'primary',
    TRUE
);

-- Add work email for notifications
CALL sp_add_email_to_persona(
    'persona-uuid-123',
    'jsmith@company.com',
    'work',
    'notifications',
    FALSE
);
```

## Phone Management

### sp_add_phone_to_persona
Associates a phone number with a persona, creating the phone record if needed.

```sql
CREATE OR REPLACE PROCEDURE sp_add_phone_to_persona(
    p_persona_id UUID,
    p_phone TEXT,
    p_phone_type phone_type_enum,
    p_usage_type phone_usage_type_enum,
    p_is_primary BOOLEAN
)
LANGUAGE plpgsql AS $$
DECLARE
    v_phone_id UUID;
    v_tenant_id INTEGER;
    v_normalized_phone TEXT;
BEGIN
    -- Get tenant ID from persona
    SELECT p.tenant_id INTO v_tenant_id
    FROM personas p
    WHERE p.id = p_persona_id;
    
    -- Normalize phone number (remove non-digits, except + for country code)
    v_normalized_phone := REGEXP_REPLACE(p_phone, '[^0-9+]', '', 'g');
    
    -- Insert or get existing phone
    INSERT INTO phone_number (
        tenant_id,
        phone_number,
        phone_type,
        is_verified,
        created_by
    ) VALUES (
        v_tenant_id,
        v_normalized_phone,
        p_phone_type,
        FALSE,
        current_user_id()
    )
    ON CONFLICT (tenant_id, phone_number) 
    DO UPDATE SET
        updated_at = NOW()
    RETURNING id INTO v_phone_id;
    
    -- Create usage record
    INSERT INTO usage_phone (
        tenant_id,
        entity_type,
        entity_id,
        phone_id,
        usage_type,
        is_primary
    ) VALUES (
        v_tenant_id,
        'persona',
        p_persona_id,
        v_phone_id,
        p_usage_type,
        p_is_primary
    )
    ON CONFLICT (entity_type, entity_id, phone_id, usage_type)
    DO UPDATE SET
        is_primary = EXCLUDED.is_primary,
        updated_at = NOW();
    
    -- If marking as primary, unset other primary phones for this persona
    IF p_is_primary THEN
        UPDATE usage_phone
        SET is_primary = FALSE
        WHERE entity_type = 'persona'
        AND entity_id = p_persona_id
        AND phone_id != v_phone_id
        AND usage_type = p_usage_type;
    END IF;
END;
$$;
```

**Parameters:**
- `p_persona_id`: UUID of the persona to associate the phone with
- `p_phone`: Phone number to add (automatically normalized)
- `p_phone_type`: Type of phone (mobile, home, work, fax, other)
- `p_usage_type`: Usage context (primary, sms_notifications, two_factor, emergency, business)
- `p_is_primary`: Whether this should be the primary phone for this usage type

**Features:**
- Automatically normalizes phone numbers
- Creates phone record if it doesn't exist
- Handles duplicate associations gracefully
- Manages primary phone designation
- Supports international formats

**Usage Example:**
```sql
-- Add primary mobile phone
CALL sp_add_phone_to_persona(
    'persona-uuid-123',
    '+1 (555) 123-4567',
    'mobile',
    'primary',
    TRUE
);

-- Add phone for two-factor authentication
CALL sp_add_phone_to_persona(
    'persona-uuid-123',
    '555-987-6543',
    'mobile',
    'two_factor',
    TRUE
);
```

## Usage Patterns

### Multiple Contact Points
A single persona can have multiple emails and phones for different purposes:

```sql
-- Personal email for primary contact
CALL sp_add_email_to_persona('persona-id', 'personal@email.com', 'personal', 'primary', TRUE);

-- Work email for business matters
CALL sp_add_email_to_persona('persona-id', 'work@company.com', 'work', 'business', TRUE);

-- Separate email for billing
CALL sp_add_email_to_persona('persona-id', 'billing@email.com', 'personal', 'billing', TRUE);
```

### Contact Sharing
The same contact information can be shared across multiple personas:

```sql
-- Family members sharing a home phone
CALL sp_add_phone_to_persona('persona-spouse-1', '555-HOME-NUM', 'home', 'primary', FALSE);
CALL sp_add_phone_to_persona('persona-spouse-2', '555-HOME-NUM', 'home', 'primary', FALSE);
```

### Contact Updates
When contact information changes, the normalized structure ensures updates cascade:

```sql
-- Update email verification status
UPDATE email_address 
SET is_verified = TRUE, 
    verified_at = NOW()
WHERE email_address = 'user@example.com';

-- All personas using this email automatically see the verified status
```

## Data Integrity

### Normalization Rules
1. **Email Addresses**: 
   - Converted to lowercase
   - Trimmed of whitespace
   - Validated against email format

2. **Phone Numbers**:
   - Non-numeric characters removed (except +)
   - Country codes preserved
   - Consistent formatting applied

### Constraint Enforcement
```sql
-- Unique email per tenant
ALTER TABLE email_address 
ADD CONSTRAINT uk_email_tenant UNIQUE (tenant_id, email_address);

-- Unique phone per tenant
ALTER TABLE phone_number 
ADD CONSTRAINT uk_phone_tenant UNIQUE (tenant_id, phone_number);

-- Unique usage per entity
ALTER TABLE usage_email 
ADD CONSTRAINT uk_email_usage UNIQUE (entity_type, entity_id, email_id, usage_type);

ALTER TABLE usage_phone 
ADD CONSTRAINT uk_phone_usage UNIQUE (entity_type, entity_id, phone_id, usage_type);
```

### Validation Rules
- Email format validation using CHECK constraint
- Phone number minimum/maximum length validation
- Enum constraints for types and usage contexts

## Security Considerations

### Privacy Protection
1. **Tenant Isolation**: Contact info strictly isolated by tenant
2. **Access Control**: RLS policies control who can view contact information
3. **PII Handling**: Contact info marked as PII for compliance
4. **Audit Trail**: All changes logged for compliance

### Verification Workflow
```sql
-- Email verification process
UPDATE email_address
SET verification_code = generate_verification_code(),
    verification_sent_at = NOW()
WHERE id = v_email_id;

-- Phone verification via SMS
UPDATE phone_number
SET verification_code = generate_sms_code(),
    verification_sent_at = NOW()
WHERE id = v_phone_id;
```

### Data Masking
For sensitive operations, contact info can be masked:
```sql
-- Masked email: j***@example.com
SELECT 
    SUBSTRING(email_address FROM 1 FOR 1) || 
    '***@' || 
    SPLIT_PART(email_address, '@', 2) as masked_email
FROM email_address;

-- Masked phone: ***-***-4567
SELECT 
    '***-***-' || 
    SUBSTRING(phone_number FROM LENGTH(phone_number) - 3) as masked_phone
FROM phone_number;
```

### Compliance Features
1. **GDPR Right to Erasure**: Soft delete with retention period
2. **Data Portability**: Export all contact info for a persona
3. **Consent Tracking**: Track consent for different usage types
4. **Audit Logging**: Complete history of all changes

## Performance Optimization

### Indexes
```sql
-- Email lookups
CREATE INDEX idx_email_address ON email_address(email_address);
CREATE INDEX idx_email_tenant ON email_address(tenant_id);

-- Phone lookups
CREATE INDEX idx_phone_number ON phone_number(phone_number);
CREATE INDEX idx_phone_tenant ON phone_number(tenant_id);

-- Usage queries
CREATE INDEX idx_usage_email_entity ON usage_email(entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity ON usage_phone(entity_type, entity_id);
```

### Query Optimization
1. Use prepared statements for repeated operations
2. Batch insert multiple contacts in a transaction
3. Consider partial indexes for verified contacts only
4. Use materialized views for contact summary reports

## Error Handling

### Common Scenarios
1. **Invalid Email Format**: Caught by CHECK constraint
2. **Invalid Phone Format**: Normalized or rejected
3. **Duplicate Primary**: Automatically resolved by unsetting others
4. **Missing Persona**: Foreign key violation
5. **Cross-Tenant Access**: Prevented by RLS policies

### Error Messages
```sql
-- Provide meaningful error messages
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Contact already exists for this usage type';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Persona not found';
    WHEN check_violation THEN
        RAISE EXCEPTION 'Invalid email or phone format';
```

## Best Practices

1. **Always Normalize**: Let procedures handle formatting
2. **Use Appropriate Types**: Choose correct email_type and usage_type
3. **Manage Primary Flags**: Only one primary per usage type
4. **Verify Before Trust**: Implement verification workflows
5. **Audit Everything**: Log all contact changes
6. **Respect Privacy**: Mask contact info in logs and displays
7. **Handle International**: Support country codes and formats

---

*This documentation covers the contact management system within the Forward Inheritance Platform, providing flexible, normalized contact information management with strong privacy controls and compliance features.*