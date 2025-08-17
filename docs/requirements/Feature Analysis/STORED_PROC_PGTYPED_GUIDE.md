# Using pgTyped with Stored Procedures Guide

## Overview
pgTyped can work with stored procedures, but they need wrapper SQL files that CALL or SELECT FROM the procedures.

## File Structure
```
0_SQL_Convert/
├── Regular Queries (Direct SQL)
│   ├── get_user.sql
│   ├── update_asset.sql
│   └── ...
├── Stored Procedure Calls
│   ├── call_create_user_from_cognito.sql
│   ├── call_process_stripe_webhook.sql
│   ├── call_search_assets.sql
│   └── ...
```

## pgTyped Configuration
```json
{
  "transforms": [
    {
      "mode": "sql",
      "include": "**/*.sql",
      "emitTemplate": "{{dir}}/{{name}}.queries.ts"
    }
  ],
  "srcDir": "./src/sql/",
  "failOnError": false,
  "camelCaseColumnNames": true,
  "dbUrl": "postgres://user:pass@localhost/db"
}
```

## SQL File Annotations for pgTyped

### For Procedures (CALL):
```sql
-- @name ProcessStripeWebhook
-- @param {string} event_id
-- @param {string} event_type
-- @param {Json} payload
CALL sp_process_stripe_webhook($1, $2, $3);
```

### For Functions (SELECT FROM):
```sql
-- @name SearchAssets
-- @param {string} [search_term] - Optional param
-- @param {string} [category_id]
-- @returns {Asset[]} - Array of assets
SELECT * FROM sp_search_assets($1, $2, $3, $4, $5);
```

## Generated TypeScript Types

pgTyped will generate:

```typescript
// call_process_stripe_webhook.queries.ts
export interface IProcessStripeWebhookParams {
  event_id: string;
  event_type: string;
  payload: Json;
}

export interface IProcessStripeWebhookResult {
  // void for procedures
}

export const processStripeWebhook = sql<
  IProcessStripeWebhookParams,
  IProcessStripeWebhookResult
>`CALL sp_process_stripe_webhook($1, $2, $3)`;
```

## Using with Slonik

```typescript
import { sql } from 'slonik';
import { processStripeWebhook } from './call_process_stripe_webhook.queries';

async function handleWebhook(pool: DatabasePool, event: StripeEvent) {
  // Option 1: Direct call with Slonik
  await pool.query(sql`
    CALL sp_process_stripe_webhook(
      ${event.id},
      ${event.type},
      ${sql.json(event.data)}
    )
  `);

  // Option 2: Using pgTyped generated query
  await pool.query(processStripeWebhook({
    event_id: event.id,
    event_type: event.type,
    payload: event.data
  }));
}
```

## Key Differences

### Regular Queries (Converted):
- SQL logic in the file
- pgTyped analyzes the actual SQL
- Full type safety on inputs and outputs
- Can see the logic in version control

### Stored Procedure Calls:
- SQL logic remains in database
- pgTyped only types the CALL interface
- Type safety on parameters only
- Need database introspection for return types
- Logic not visible in version control

## Limitations with Stored Procedures

1. **Return Types**: 
   - Procedures with OUT parameters need special handling
   - Complex return types may not be fully typed

2. **Debugging**:
   - Can't see procedure logic in application code
   - Need database access to debug

3. **Testing**:
   - Can't unit test without database
   - Need full database for integration tests

## Recommendations

1. **For the 12 Complex Procedures**: Create CALL wrapper files
2. **Document Return Types**: Add clear comments about what each procedure returns
3. **Consider Future Migration**: Even complex procedures could eventually be converted
4. **Type Safety First**: Use pgTyped annotations extensively

## Example Service Layer

```typescript
class UserService {
  constructor(private pool: DatabasePool) {}

  // Converted query - full visibility
  async updateProfile(userId: string, data: ProfileUpdate) {
    return this.pool.query(updateUserProfile({
      user_id: userId,
      first_name: data.firstName,
      last_name: data.lastName
    }));
  }

  // Stored procedure - black box
  async createFromCognito(cognitoData: CognitoUser) {
    return this.pool.query(sql`
      CALL sp_create_user_from_cognito(
        ${cognitoData.sub},
        ${cognitoData.email},
        ${cognitoData.given_name},
        ${cognitoData.family_name},
        ${null}
      )
    `);
  }
}
```

## Migration Path

Eventually, even complex stored procedures could be converted:

1. **Phase 1**: Use CALL wrappers (current)
2. **Phase 2**: Add observability/logging to procedures
3. **Phase 3**: Gradually move logic to service layer
4. **Phase 4**: Convert to pure SQL queries

This approach maintains type safety while keeping complex logic in the database where needed.