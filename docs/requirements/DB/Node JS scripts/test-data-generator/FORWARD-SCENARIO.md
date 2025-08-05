# Forward Inheritance Platform Test Scenario Generator

**Enhanced test data generator designed specifically for the Forward Inheritance Platform architecture using stored procedures.**

## 🎯 Forward Test Scenario Overview

This specialized generator creates **exactly 10 Forward Family Circles (FFCs)** with **3-5 members each**, ensuring comprehensive coverage of all **13 asset categories** across realistic family structures.

### Key Features

✅ **Stored Procedure Integration**: Uses `sp_register_user`, `sp_create_ffc`, `sp_add_ffc_member`, and `sp_create_asset`  
✅ **Database-First Architecture**: All operations through stored procedures from `architecture.md`  
✅ **Comprehensive Asset Coverage**: Every asset category appears multiple times  
✅ **Realistic Family Structures**: Multi-generational families with proper relationships  
✅ **Cultural Diversity**: 85% English, 15% Spanish families  
✅ **Wealth Distribution**: Mix of high-net-worth and mass-affluent scenarios  

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Generate the complete Forward test scenario
npm run forward-generate

# View scenario information
npm run forward-info

# Clean test data
npm run forward-clean
```

## 📊 Generated Data Structure

### Family Structure
- **10 Forward Family Circles (FFCs)**
- **35-50 total personas** (3-5 members per FFC)
- **Realistic relationships**: Parents, children, spouses, siblings
- **Mixed roles**: Owners, beneficiaries, non-beneficiaries, advisors

### Asset Portfolio
- **80-120 total assets** (8-12 per FFC)
- **All 13 categories covered multiple times**
- **Realistic values**: $100K-$50M based on wealth level  
- **Complex ownership**: 1-3 owners per asset with percentage splits
- **Granular permissions**: Read/Edit/Admin levels per family member

### Wealth Scenarios
- **30% High Net Worth**: $1M+ portfolios with complex structures
- **70% Mass Affluent**: $250K-$1M with simpler structures  
- **Realistic distributions**: Financial accounts dominant, followed by real estate

## 🏗️ Asset Categories Generated

| Category | Examples | Coverage |
|----------|----------|----------|
| **Personal Directives** | POA, Healthcare Directive, HIPAA | Every FFC |
| **Trusts** | Revocable, Irrevocable, Charitable | High NW families |  
| **Wills** | Last Will & Testament | Every FFC |
| **Personal Property** | Art, Jewelry, Collectibles | Wealth-based |
| **Operational Property** | Vehicles, Boats, Equipment | Every FFC |
| **Inventory** | Business Assets, Materials | Business owners |
| **Real Estate** | Primary, Secondary, Commercial | 90% of FFCs |
| **Life Insurance** | Term, Whole, Universal | Every FFC |
| **Financial Accounts** | Bank, Investment, Retirement | Every FFC |
| **Recurring Income** | Royalties, Rental Income | 60% of FFCs |
| **Digital Assets** | Crypto, Domains, NFTs | Modern assets |
| **Ownership Interests** | Business, Partnerships | High NW families |
| **Loans** | HEI, Interfamily, Mortgages | Mixed scenarios |

## 🔧 Technical Architecture

### Stored Procedure Integration

The generator uses the exact stored procedures defined in `architecture.md`:

```typescript
// User registration and persona creation
sp_register_user(tenant_id, email, phone, password_hash, first_name, last_name, referral_code)

// FFC creation
sp_create_ffc(tenant_id, name, description, created_by)

// Member management  
sp_add_ffc_member(ffc_id, user_id, role_name, invited_by)

// Asset creation
sp_create_asset(tenant_id, asset_category, name, description, created_by)

// Asset ownership
sp_assign_asset_to_persona(asset_id, persona_id, ownership_type, ownership_percentage, assigned_by)

// Asset valuation
sp_update_asset_value(asset_id, new_value, valuation_date, updated_by)
```

### Database Schema Compatibility

- **Multi-tenant**: Single tenant for test scenario
- **Audit trails**: All operations logged automatically  
- **Referential integrity**: Proper foreign key relationships
- **Type safety**: Uses PostgreSQL enums from schema
- **Row-level security**: Tenant isolation maintained

## 📋 Usage Examples

### Basic Scenario Generation

```bash
# Generate with default settings
npm run forward-generate

# Custom database connection
npm run forward-generate -- --db-host myhost --db-name mydb --db-user myuser

# Environment variables
DB_HOST=localhost DB_NAME=forward_test npm run forward-generate
```

### Development Workflow

```bash
# 1. Generate test scenario
npm run forward-generate

# 2. Run your application tests
npm test

# 3. Clean test data  
npm run forward-clean

# 4. Repeat as needed
npm run forward-generate
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Generate Test Data
  run: |
    cd test-data-generator
    npm install
    npm run forward-generate
  env:
    DB_HOST: ${{ secrets.TEST_DB_HOST }}
    DB_NAME: forward_test
    DB_USER: ${{ secrets.DB_USER }}
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

## 📈 Expected Output

```
✅ Forward Test Scenario Summary:
📊 Tenant: 1
👥 Personas: 42
🏠 Forward Family Circles: 10  
💰 Assets: 95
🔗 Asset Ownerships: 142
🔐 Asset Permissions: 189
👨‍👩‍👧‍👦 FFC Memberships: 42
⏱️  Execution Time: 3,247ms

📈 Scenario Statistics:
👨‍👩‍👧‍👦 Average Members per FFC: 4
💼 Average Assets per FFC: 10
💵 Estimated Total Portfolio Value: $23,750,000
🎯 Asset Coverage: All 13 categories included multiple times
```

## 🛠️ Configuration

### Database Connection

Create a `.env` file:

```env
DB_HOST=localhost
DB_PORT=5432  
DB_NAME=forward_inheritance
DB_USER=postgres
DB_PASSWORD=your_password
```

### Asset Distribution Tuning

Modify `EnhancedAssetGenerator.ts` to adjust:

- **Category percentages**: Change `getAssetDistribution()` weights
- **Value ranges**: Adjust `minValue`/`maxValue` in category generators  
- **Wealth scenarios**: Modify `determineWealthLevel()` probabilities
- **Cultural mix**: Update language distribution in `generateTenFFcsWithMembers()`

## 🧪 Testing & Validation

### Verify Asset Coverage

```sql
-- Check all categories are represented
SELECT category, COUNT(*) as count 
FROM assets 
GROUP BY category 
ORDER BY count DESC;

-- Verify FFC member counts
SELECT ffc_id, COUNT(*) as member_count
FROM ffc_personas  
GROUP BY ffc_id
ORDER BY member_count;

-- Check ownership distributions
SELECT asset_id, COUNT(*) as owner_count, SUM(ownership_percentage) as total_pct
FROM asset_ownerships
GROUP BY asset_id
HAVING SUM(ownership_percentage) != 100;
```

### Performance Benchmarks

| Metric | Target | Typical |
|--------|--------|---------|
| Generation Time | <5 seconds | ~3.2 seconds |
| Database Connections | <10 concurrent | 1 (pooled) |
| Memory Usage | <500MB | ~180MB |  
| SQL Operations | <1000 queries | ~750 queries |

## 🔍 Troubleshooting

### Common Issues

**"Stored procedure not found"**
```bash
# Ensure architecture.md stored procedures are deployed
psql -d forward_inheritance -f architecture_procedures.sql
```

**"Permission denied"**  
```bash
# Check database user permissions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO test_user;
```

**"Constraint violation"**
```bash
# Clean existing test data first
npm run forward-clean
npm run forward-generate
```

### Debug Mode

```bash
# Enable verbose logging
DEBUG=true npm run forward-generate

# Check database connections
npm run forward-generate -- --db-host localhost --db-port 5432
```

## 🚦 Integration with Forward Platform

### Test Coverage

This scenario provides comprehensive test data for:

- **User Registration Flow**: Email/phone verification  
- **FFC Management**: Creation, member invitation, role assignment
- **Asset Management**: All 13 categories with complex ownership
- **Permission System**: Asset-level read/edit/admin permissions  
- **Wealth Transfer**: Multi-generational family structures
- **Cultural Support**: Spanish-language family data

### API Testing

The generated data enables testing of all major API endpoints:

```typescript
// Family management
GET /api/ffcs              // List all FFCs
GET /api/ffcs/:id/members  // Get FFC members
POST /api/ffcs/:id/invite  // Invite new member

// Asset management  
GET /api/assets                    // List assets
GET /api/assets/category/:category // Filter by category
POST /api/assets                   // Create asset
PUT /api/assets/:id/ownership      // Update ownership

// Search and reporting
GET /api/search/assets?q=real+estate  // Asset search
GET /api/reports/wealth-summary       // Wealth reports
```

### Load Testing

Scale the scenario for performance testing:

```bash
# Generate multiple tenants (custom implementation needed)
for i in {1..10}; do
  TENANT_PREFIX="load_test_$i" npm run forward-generate
done
```

## 📚 Architecture References

- **PRD**: `docs/prd.md` - Product requirements and business rules
- **Database Schema**: `docs/architecture.md` - Complete schema definition  
- **Stored Procedures**: `docs/architecture.md` - All SP definitions
- **Asset Categories**: `docs/requirements/metadata/` - Category specifications

## 🤝 Contributing

1. **Add New Asset Category**: Extend `EnhancedAssetGenerator`
2. **Cultural Expansion**: Add new languages to `PersonaGenerator`  
3. **Wealth Scenarios**: Create new distribution patterns
4. **Performance**: Optimize stored procedure calls
5. **Testing**: Add validation queries and benchmarks

## 📄 License

Part of the Forward Inheritance Platform. See main project license.