# Quiltt Integration Architecture

## Overview

This document defines the complete architecture for integrating Quiltt banking connectivity into the Forward Inheritance Platform. The design focuses on the normal user flow: one user connecting their personal bank accounts to their primary persona.

## User Flow

### Standard Banking Connection Flow

1. **User Authentication**: User logs into Forward Inheritance Platform
2. **Asset Creation Intent**: User navigates to "Add Financial Asset"
3. **Connection Method Selection**: User chooses "Connect Bank Account" vs "Manual Entry"
4. **Quiltt Session Creation**: Backend creates temporary Quiltt session token
5. **Bank Authentication**: User redirected to Quiltt UI, authenticates with bank
6. **Account Selection**: User selects which accounts to share (e.g., 3 accounts)
7. **Webhook Processing**: Quiltt sends webhook with connection details
8. **Asset Creation**: Backend creates 3 financial account assets
9. **Data Synchronization**: Account balances and details populated from Quiltt

## Database Architecture

### Core Tables

#### quiltt_integrations
```sql
-- One record per persona's banking connection
CREATE TABLE quiltt_integrations (
    id UUID PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    persona_id UUID NOT NULL,              -- WHO owns the connected accounts
    
    -- Quiltt identifiers
    quiltt_user_id TEXT NOT NULL,          -- Quiltt's profile ID (same as our persona_id)
    quiltt_connection_id TEXT NOT NULL,    -- Quiltt connection ID after auth
    
    -- Token management
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Sync configuration
    sync_accounts BOOLEAN DEFAULT TRUE,
    sync_transactions BOOLEAN DEFAULT TRUE,
    sync_investments BOOLEAN DEFAULT TRUE,
    
    -- Status tracking
    connection_status integration_status_enum DEFAULT 'connected',
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_status sync_status_enum DEFAULT 'completed',
    
    CONSTRAINT unique_quiltt_persona UNIQUE (tenant_id, persona_id)
);
```

#### quiltt_sessions
```sql
-- Temporary session tokens for UI connector
CREATE TABLE quiltt_sessions (
    id UUID PRIMARY KEY,
    persona_id UUID NOT NULL,
    session_token TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT unique_active_session UNIQUE (persona_id) WHERE NOT is_used
);
```

#### financial_accounts (enhanced)
```sql
-- Links Quiltt accounts to our assets
ALTER TABLE financial_accounts ADD (
    quiltt_integration_id UUID REFERENCES quiltt_integrations(id),
    quiltt_account_id TEXT,                -- External account ID from Quiltt
    is_quiltt_connected BOOLEAN DEFAULT FALSE,
    last_quiltt_sync_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT unique_quiltt_account UNIQUE (quiltt_account_id)
);
```

### Data Relationships

```
User (authentication)
  ↓ 1:1 (normal case)
Persona (business entity + asset owner)
  ↓ 1:1
Quiltt Integration (bank connection)
  ↓ 1:many
Financial Account Assets (individual bank accounts)
  ↓ 1:1
Asset-Persona Ownership (100% ownership)
```

## API Implementation

### Backend Services

#### QuilttIntegrationService

```typescript
export class QuilttIntegrationService {
  
  // Step 1: Create session for banking connection UI
  async createBankingSession(userId: string): Promise<QuilttSessionResponse> {
    // Get user's primary persona
    const persona = await this.getActivePesonaForUser(userId);
    
    // Create Quiltt session using persona ID as external user ID
    const quilttResponse = await this.quilttApiClient.createSession({
      userId: persona.id,        // Use our persona ID
      userUUID: persona.id,
      metadata: {
        tenantId: persona.tenantId,
        personaName: `${persona.firstName} ${persona.lastName}`
      }
    });
    
    // Store session temporarily
    await this.db.query(sql`
      INSERT INTO quiltt_sessions (persona_id, session_token, expires_at)
      VALUES (${persona.id}, ${quilttResponse.token}, ${quilttResponse.expiresAt})
    `);
    
    return {
      sessionToken: quilttResponse.token,
      personaId: persona.id,
      expiresAt: quilttResponse.expiresAt
    };
  }
  
  // Step 2: Handle successful bank connection webhook
  async handleConnectionWebhook(webhookData: QuilttWebhookEvent): Promise<void> {
    const { userId: quilttUserId, connectionId, accounts } = webhookData;
    
    // Find the persona (quilttUserId = our persona.id)
    const persona = await this.db.queryOne(sql`
      SELECT * FROM personas WHERE id = ${quilttUserId}
    `);
    
    // Create or update integration record
    const integration = await this.db.queryOne(sql`
      INSERT INTO quiltt_integrations (
        tenant_id, persona_id, quiltt_user_id, quiltt_connection_id, 
        connection_status, sync_status
      ) VALUES (
        ${persona.tenantId}, ${persona.id}, ${quilttUserId}, ${connectionId},
        'connected', 'completed'
      )
      ON CONFLICT (tenant_id, persona_id) 
      DO UPDATE SET 
        quiltt_connection_id = ${connectionId},
        connection_status = 'connected',
        last_sync_at = NOW()
      RETURNING *
    `);
    
    // Create financial assets for each connected account
    for (const account of accounts) {
      await this.createFinancialAssetFromQuiltt(integration.id, persona, account);
    }
    
    // Mark session as used
    await this.db.query(sql`
      UPDATE quiltt_sessions 
      SET is_used = TRUE, used_at = NOW()
      WHERE persona_id = ${persona.id} AND NOT is_used
    `);
  }
  
  // Step 3: Create financial asset from Quiltt account data
  private async createFinancialAssetFromQuiltt(
    integrationId: string,
    persona: Persona,
    quilttAccount: QuilttAccount
  ): Promise<void> {
    
    // Get FFC for this persona
    const ffc = await this.db.queryOne(sql`
      SELECT ffc_id FROM ffc_personas WHERE persona_id = ${persona.id}
    `);
    
    // Create base asset
    const asset = await this.db.queryOne(sql`
      INSERT INTO assets (
        tenant_id, ffc_id, category_id, 
        asset_name, asset_description, status
      ) VALUES (
        ${persona.tenantId}, ${ffc.ffc_id}, 'financial_account',
        ${quilttAccount.institutionName} || ' ' || ${quilttAccount.displayName},
        'Connected via Quiltt banking integration',
        'active'
      )
      RETURNING *
    `);
    
    // Create financial account details
    await this.db.query(sql`
      INSERT INTO financial_accounts (
        asset_id, institution_name, account_type, account_number_last_four,
        current_balance, balance_as_of_date,
        quiltt_integration_id, quiltt_account_id, is_quiltt_connected,
        last_quiltt_sync_at
      ) VALUES (
        ${asset.id}, ${quilttAccount.institutionName}, ${quilttAccount.accountType},
        ${quilttAccount.accountNumber?.slice(-4) || null},
        ${quilttAccount.currentBalance}, NOW(),
        ${integrationId}, ${quilttAccount.id}, TRUE,
        NOW()
      )
    `);
    
    // Create 100% ownership for the persona
    await this.db.query(sql`
      INSERT INTO asset_persona (
        tenant_id, asset_id, persona_id, 
        ownership_type, ownership_percentage
      ) VALUES (
        ${persona.tenantId}, ${asset.id}, ${persona.id},
        'owner', 100.00
      )
    `);
  }
  
  // Step 4: Sync account data (scheduled job)
  async syncAccountData(integrationId: string): Promise<void> {
    const integration = await this.db.queryOne(sql`
      SELECT * FROM quiltt_integrations WHERE id = ${integrationId}
    `);
    
    // Get updated account data from Quiltt
    const accounts = await this.quilttApiClient.getAccounts(integration.quiltt_user_id);
    
    // Update our financial accounts
    for (const account of accounts) {
      await this.db.query(sql`
        UPDATE financial_accounts 
        SET 
          current_balance = ${account.currentBalance},
          available_balance = ${account.availableBalance},
          balance_as_of_date = NOW(),
          last_quiltt_sync_at = NOW()
        WHERE quiltt_account_id = ${account.id}
      `);
    }
    
    // Update integration sync status
    await this.db.query(sql`
      UPDATE quiltt_integrations 
      SET last_sync_at = NOW(), sync_status = 'completed'
      WHERE id = ${integrationId}
    `);
  }
}
```

### Frontend Integration

#### React Component for Banking Connection

```typescript
export function BankingConnectionFlow() {
  const [sessionToken, setSessionToken] = useState<string>();
  const [isConnecting, setIsConnecting] = useState(false);
  
  const handleConnectBank = async () => {
    setIsConnecting(true);
    
    try {
      // Get Quiltt session token
      const response = await assetService.createBankingSession();
      setSessionToken(response.sessionToken);
      
      // Initialize Quiltt connector
      const connector = new QuilttConnector({
        token: response.sessionToken,
        onSuccess: (data) => {
          console.log('Banking connection successful:', data);
          setIsConnecting(false);
          // Refresh assets list to show new accounts
          window.location.reload();
        },
        onError: (error) => {
          console.error('Banking connection failed:', error);
          setIsConnecting(false);
        }
      });
      
      connector.launch();
      
    } catch (error) {
      console.error('Failed to create banking session:', error);
      setIsConnecting(false);
    }
  };
  
  return (
    <div className="banking-connection">
      <h3>Connect Your Bank Accounts</h3>
      <p>Securely connect your bank accounts to automatically track balances and transactions.</p>
      
      <Button 
        onClick={handleConnectBank}
        disabled={isConnecting}
        className="w-full"
      >
        {isConnecting ? 'Connecting...' : 'Connect Bank Account'}
      </Button>
    </div>
  );
}
```

## Security Considerations

### Data Protection
- All Quiltt tokens encrypted at rest using AWS KMS
- Session tokens expire quickly (15 minutes max)
- Only account metadata stored, no credentials
- Webhook signatures verified using HMAC

### Access Control
- Quiltt integration tied to specific persona
- Asset ownership automatically assigned to connecting persona
- Standard RBAC applies to viewing/editing financial assets

### Privacy
- Bank credentials never stored in our system
- Account numbers masked (last 4 digits only)
- PII handling follows existing platform standards

## Monitoring & Observability

### Key Metrics
- Banking connection success/failure rates
- Account sync frequency and success rates
- Session token usage and expiration
- Webhook processing latency

### Alerting
- Failed webhook processing
- Sync failures for multiple accounts
- Expired or invalid tokens
- Unusual account access patterns

## Error Handling

### Connection Failures
- Graceful fallback to manual asset entry
- Clear error messages for users
- Retry mechanisms for temporary failures
- Admin dashboard for connection status

### Data Sync Issues
- Exponential backoff for API calls
- Dead letter queue for failed webhooks
- Manual sync triggers for administrators
- Account status indicators in UI

## Testing Strategy

### Unit Tests
- Service layer methods
- Data transformation logic
- Error handling scenarios

### Integration Tests
- Webhook processing end-to-end
- Database consistency checks
- Quiltt API integration

### E2E Tests
- Complete user banking connection flow
- Asset creation and ownership verification
- Data sync accuracy

This architecture provides a robust, secure, and scalable foundation for Quiltt banking integration while maintaining the simplicity of the normal user flow.