# 12 - Subscription & Payment Management

## Table of Contents
1. [Overview](#overview)
2. [Subscription Architecture](#subscription-architecture)
3. [Table Structures](#table-structures)
4. [Stored Procedures](#stored-procedures)
5. [Integration Points](#integration-points)
6. [Business Rules](#business-rules)
7. [Security Considerations](#security-considerations)

## Overview

The subscription and payment management system provides comprehensive billing, seat management, and financial tracking capabilities for the Forward Inheritance Platform. Built with flexibility in mind, it supports free plans, paid subscriptions, one-time services, and advisor-sponsored models while maintaining complete financial audit trails.

### Key Features
- **Flexible Plan Configuration**: Database-driven plan definitions with dynamic UI configuration
- **Seat-Based Subscriptions**: Support for limited and unlimited seat plans
- **Payment Processing**: Stripe integration with asynchronous webhook handling
- **Financial Tracking**: Single-entry general ledger for complete transaction history
- **Service Marketplace**: One-time service purchases separate from subscriptions
- **Multi-Payer Support**: Owner, advisor, individual, or no payment required

### Design Principles
- **Zero Payment Barrier**: Free plans with automatic assignment on FFC creation
- **Data Integrity**: Unique constraints prevent duplicate subscriptions and seat assignments
- **Audit Compliance**: Complete financial tracking with reconciliation support
- **Scalability**: Asynchronous processing for payment events
- **User Recognition**: Cached payment method details for user convenience

## Subscription Architecture

### Plan Hierarchy
```
Plans (Templates) → Subscriptions (Active) → Seat Assignments (Members)
                 ↓                        ↓
            Plan Seats              Individual Payers
         (Configuration)            (Self-upgrades)
```

### Payment Flow
```
User Action → Payment Method → Stripe API → Webhook Event
                           ↓              ↓
                        Payment         General Ledger
                        Record            Entry
```

## Table Structures

### Core Subscription Tables

#### plans
Plan templates and catalog for all subscription offerings.

**Key Fields:**
- `plan_code` (VARCHAR, UNIQUE): Human-readable plan identifier
- `plan_type` (ENUM): 'free', 'paid', 'sponsored'
- `base_price` (DECIMAL): Monthly/annual price (0.00 for free)
- `ui_config` (JSONB): Controls UI visibility for plan features
- `features` (JSONB): Feature flags and configuration

**UI Configuration Example:**
```json
{
  "hide_seat_management": true,
  "hide_billing_section": true,
  "show_unlimited_badge": true,
  "badge_text": "Unlimited Pro Members"
}
```

#### subscriptions
Active subscriptions for each Forward Family Circle (one active per FFC).

**Key Constraints:**
- UNIQUE constraint on `ffc_id` WHERE `status = 'active'`
- Prevents duplicate active subscriptions

**Key Fields:**
- `ffc_id` (UUID): Link to Forward Family Circle
- `payer_type` (ENUM): 'owner', 'advisor', 'third_party', 'none'
- `advisor_id` (UUID): Tracks advisor for sponsored plans
- `billing_amount` (DECIMAL): 0.00 for free plans

#### seat_assignments
Individual seat assignments within subscriptions.

**Key Constraints:**
- UNIQUE constraint on `(subscription_id, persona_id)` WHERE `status = 'active'`
- Prevents duplicate active assignments per persona

**Key Fields:**
- `persona_id` (UUID): Assigned family member
- `seat_type` (ENUM): 'basic', 'pro', 'enterprise'
- `invitation_id` (UUID): Links to existing invitation system
- `is_self_paid` (BOOLEAN): Tracks individual upgrades

### Payment Processing Tables

#### payment_methods
Stored payment methods with usage protection via view.

**Key Features:**
- Usage tracking via `payment_methods_with_usage` view
- Cached card details for user recognition
- Multiple payment methods per user supported
- Protection from deletion when in active use

#### payment_methods_with_usage (VIEW)
View that extends payment_methods with computed usage status.

**Key Features:**
- `is_in_use` (BOOLEAN): Computed field indicating active usage
- Checks for active subscriptions (active, trialing, past_due)
- Checks for recent successful payments (last 30 days)
- Used by sp_check_payment_method_usage and sp_delete_payment_method

#### services
One-time service catalog (e.g., Estate Capture Service).

**Key Fields:**
- `service_code` (VARCHAR, UNIQUE): 'ESTATE_CAPTURE_SERVICE'
- `price` (DECIMAL): 299.00
- `delivery_timeline` (VARCHAR): Service fulfillment timeframe

#### payments
Unified payment tracking for all transaction types.

**Key Fields:**
- `payment_type` (ENUM): 'subscription', 'service', 'seat_upgrade'
- `reference_id` (UUID): Links to subscription or service purchase
- Comprehensive Stripe reference fields

### Financial Tracking Tables

#### general_ledger
Single-entry bookkeeping system for all financial transactions.

**Transaction Categories:**
- `recurring_monthly`: Monthly subscription charges
- `recurring_annual`: Annual subscription charges
- `one_time`: Service purchases
- `refund`: Refunded transactions

**Key Fields:**
- `reconciled` (BOOLEAN): Manual reconciliation tracking
- `category` (VARCHAR): Limited to 4 transaction types
- No external accounting system integration

#### stripe_events
Asynchronous webhook event processing queue.

**Processing States:**
- `pending`: Awaiting processing
- `processing`: Currently being handled
- `processed`: Successfully completed
- `failed`: Processing failed (Stripe will retry)
- `ignored`: Unhandled event types

**Key Features:**
- Idempotent processing with unique event IDs
- No automatic retries (burden on Stripe)
- Complete payload storage for debugging

## Stored Procedures

### Subscription Management Procedures

#### sp_create_ffc_with_subscription
Creates FFC with automatic free plan assignment.

**Key Logic:**
1. Retrieves 'FAMILY_UNLIMITED_FREE' plan for tenant
2. Creates FFC using existing procedure
3. Creates subscription with $0 billing amount
4. Assigns owner with 'pro' seat type
5. Logs to audit trail

**Edge Case Handling:**
- Validates free plan exists before creation
- Prevents duplicate active subscriptions via unique constraint

#### sp_process_seat_invitation
Processes seat invitation after approval.

**Key Logic:**
1. Validates invitation is approved
2. Checks for existing active seat assignment
3. For unlimited plans, always creates assignment
4. For limited plans, validates availability
5. Updates invitation status to 'accepted'

**Edge Case Handling:**
- Prevents duplicate seat assignments
- Handles unlimited vs limited seat logic

#### sp_purchase_service
Handles one-time service purchases.

**Key Logic:**
1. Validates service exists and is active
2. Creates service purchase record
3. Creates payment record with 'pending' status
4. Links to Stripe payment intent
5. Logs to audit trail

#### sp_process_stripe_webhook
Asynchronous webhook event handler.

**Key Logic:**
1. Checks for duplicate events (idempotency)
2. Inserts or updates event record
3. Routes to appropriate handler based on event type
4. Updates processing status
5. Handles errors with status tracking

**Supported Events:**
- `payment_intent.succeeded`
- `payment_intent.failed`
- `invoice.payment_succeeded`
- Others marked as 'ignored'

### Payment Protection Procedures

#### sp_check_payment_method_usage
Verifies if payment method can be deleted using the payment_methods_with_usage view.

**Returns:**
- Boolean indicating if method is in use
- Leverages the payment_methods_with_usage view for usage determination
- Returns TRUE if payment method has active subscriptions or recent payments

#### sp_delete_payment_method
Safely deletes payment method.

**Key Logic:**
1. Calls sp_check_payment_method_usage
2. Fails if method is in active use
3. Soft deletes by setting status to 'deleted'
4. Maintains audit trail

## Integration Points

### Stripe Integration
- **Authentication**: API keys stored securely in environment
- **Webhooks**: Asynchronous processing via stripe_events table
- **Products**: Mapped via stripe_product_id fields
- **Customers**: Linked via stripe_customer_id

### Existing System Integration
- **FFC Creation**: Modified to include subscription creation
- **Invitation System**: Extended with seat_type and subscription_id
- **Audit System**: All financial operations logged
- **Multi-tenancy**: All tables include tenant_id

## Business Rules

### Free Plan Rules
1. Automatically assigned on FFC creation
2. No payment information required
3. Unlimited Pro seats included
4. UI hides billing and seat management
5. Can purchase one-time services

### Subscription Constraints
1. One active subscription per FFC
2. One active seat assignment per persona
3. Payment methods cannot be deleted if in use
4. Advisor tracking for sponsored plans
5. All transactions recorded in general ledger

### Service Purchase Rules
1. Available to all users (free or paid)
2. One-time payment via Stripe
3. No impact on subscription status
4. Separate delivery tracking
5. Full refund capability

## Security Considerations

### Data Protection
- Payment method details encrypted at rest
- Only last four digits and brand cached
- Stripe handles full card data
- PCI compliance via Stripe

### Access Control
- Tenant isolation for all operations
- User can only modify own payment methods
- FFC owners control subscription changes
- Audit trail for all financial operations

### Webhook Security
- Stripe signature verification required
- Idempotent event processing
- Failed events logged for investigation
- No sensitive data in webhook payloads

## Implementation Notes

### Performance Optimizations
- 22 specialized indexes for query performance
- Unique partial indexes for constraint enforcement
- JSONB indexes for feature queries
- Temporal indexes for financial reporting

### Migration Considerations
- Existing FFCs need subscription records created
- Default to free plan for all existing FFCs
- Preserve existing invitation system functionality
- No breaking changes to current workflows

### Monitoring Requirements
- Webhook processing latency
- Payment success rates
- Subscription activation time
- Seat utilization metrics
- General ledger reconciliation status

## Appendix: Example Queries

### Get Active Subscription for FFC
```sql
SELECT s.*, p.plan_name, p.features
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
WHERE s.ffc_id = ? 
AND s.status = 'active';
```

### Calculate Available Seats
```sql
SELECT 
  ps.seat_type,
  ps.included_quantity,
  COUNT(sa.id) as used_seats,
  CASE 
    WHEN ps.included_quantity IS NULL THEN 'unlimited'
    ELSE (ps.included_quantity - COUNT(sa.id))::TEXT
  END as available
FROM plan_seats ps
LEFT JOIN seat_assignments sa 
  ON sa.subscription_id = ?
  AND sa.seat_type = ps.seat_type
  AND sa.status = 'active'
WHERE ps.plan_id = ?
GROUP BY ps.seat_type, ps.included_quantity;
```

### Monthly Revenue Report
```sql
SELECT 
  DATE_TRUNC('month', transaction_date) as month,
  category,
  SUM(amount) as total
FROM general_ledger
WHERE tenant_id = ?
AND account_type = 'revenue'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
```

---

*Document Version: 1.0*
*Last Updated: [Current Date]*
*Related Documents: DB-architecture.md, FFC Management Procedures, Integration Documentation*