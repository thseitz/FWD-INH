# Forward Inheritance Test Data Generator

**Step-by-step guide to connect to your database and run the Forward test scenario generator.**

## 📋 Prerequisites

- **Node.js** (v18 or higher)
- **PostgreSQL** database with Forward Inheritance schema deployed
- **Database credentials** with appropriate permissions

## 🚀 Step-by-Step Setup

### Step 1: Navigate to Generator Directory

```bash
cd "C:\Users\bob\github-thseitz\fwd-inh\docs\requirements\DB\Node JS scripts\test-data-generator"
```

### Step 2: Install Dependencies

```bash
# Install all required packages
npm install
```

This will install:
- `@faker-js/faker` - For generating realistic test data
- `pg` - PostgreSQL client for Node.js
- `commander` - CLI framework
- `chalk` - Terminal colors
- `ora` - Loading spinners
- `typescript` - TypeScript compiler

### Step 3: Database Connection Setup

#### Option A: Environment Variables (Recommended)

Create a `.env` file in the generator directory:

```bash
# Create .env file
touch .env
```

Add your database connection details:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fwd_db
DB_USER=postgres
DB_PASSWORD=your_password_here
```

#### Option B: Command Line Parameters

You can also specify database connection details directly in the command:

```bash
npm run forward-generate -- --db-host localhost --db-port 5432 --db-name fwd_db --db-user postgres --db-password your_password
```

### Step 4: Verify Database Schema

Before running the generator, ensure your database has the Forward Inheritance schema deployed:

```bash
# Connect to your database and verify key tables exist
psql -h localhost -p 5432 -U postgres -d fwd_db -c "\dt"
```

You should see tables like:
- `tenants`
- `users` 
- `personas`
- `fwd_family_circles`
- `assets`
- `asset_ownerships`
- `asset_permissions`

### Step 5: Verify Stored Procedures

Check that the required stored procedures are deployed:

```bash
psql -h localhost -p 5432 -U postgres -d fwd_db -c "\df+ sp_*"
```

Required stored procedures:
- `sp_register_user`
- `sp_create_ffc` 
- `sp_add_ffc_member`
- `sp_create_asset`
- `sp_assign_asset_to_persona`
- `sp_update_asset_value`

## 🎯 Running the Forward Test Scenario

### Quick Start

```bash
# Generate the complete Forward test scenario (10 FFCs, all asset categories)
npm run forward-generate
```

### Detailed Commands

```bash
# View information about what will be generated
npm run forward-info

# Generate with custom database connection
npm run forward-generate -- --db-host myhost --db-name mydb --db-user myuser --db-password mypass

# Clean existing test data before generating new
npm run forward-clean
npm run forward-generate

# Generate with environment variables
DB_HOST=localhost DB_NAME=forward_test npm run forward-generate
```

## 📊 Expected Output

When successful, you'll see output like this:

```bash
🚀 Forward Inheritance Platform Test Scenario
   📋 Generating 10 FFCs with 3-5 members each
   💰 Ensuring all 13 asset categories are covered multiple times
   🔧 Using stored procedures from architecture.md

✅ Forward Test Scenario Summary:
📊 Tenant: 1
👥 Personas: 37-43
🏠 Forward Family Circles: 10
💰 Assets: 100-107
🔗 Asset Ownerships: 200-280
🔐 Asset Permissions: 280-300
👨‍👩‍👧‍👦 FFC Memberships: 37-43
⏱️  Execution Time: 300-400ms

📈 Scenario Statistics:
👨‍👩‍👧‍👦 Average Members per FFC: 3-5 (as specified)
💼 Average Assets per FFC: 8-12
💵 Estimated Total Portfolio Value: $25-30M
🎯 Asset Coverage: All 13 categories included multiple times
🔐 Permission Coverage: Comprehensive read/edit/admin permissions across all family members
```

## 🔧 Database Connection Troubleshooting

### Common Connection Issues

#### Issue 1: Connection Refused
```bash
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solutions:**
```bash
# Check if PostgreSQL is running
pg_ctl status

# Start PostgreSQL if not running
pg_ctl start

# Verify PostgreSQL is listening on port 5432
netstat -an | findstr 5432
```

#### Issue 2: Authentication Failed
```bash
Error: password authentication failed for user "postgres"
```

**Solutions:**
```bash
# Reset PostgreSQL password
psql -U postgres -c "ALTER USER postgres PASSWORD 'newpassword';"

# Check pg_hba.conf authentication method
# Look for: local all postgres trust
```

#### Issue 3: Database Does Not Exist
```bash
Error: database "fwd_db" does not exist
```

**Solutions:**
```bash
# Create the database
createdb -U postgres fwd_db

# Or via psql
psql -U postgres -c "CREATE DATABASE fwd_db;"
```

#### Issue 4: Permission Denied
```bash
Error: permission denied for schema public
```

**Solutions:**
```bash
# Grant necessary permissions
psql -U postgres -d fwd_db -c "GRANT ALL PRIVILEGES ON SCHEMA public TO your_user;"
psql -U postgres -d fwd_db -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;"
psql -U postgres -d fwd_db -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO your_user;"
```

### Connection Testing

Test your database connection before running the generator:

```bash
# Test basic connection
psql -h localhost -p 5432 -U postgres -d fwd_db -c "SELECT version();"

# Test stored procedures exist
psql -h localhost -p 5432 -U postgres -d fwd_db -c "SELECT proname FROM pg_proc WHERE proname LIKE 'sp_%';"

# Test write permissions
psql -h localhost -p 5432 -U postgres -d fwd_db -c "CREATE TEMP TABLE test_table (id int); DROP TABLE test_table;"
```

## 🗄️ Database Schema Deployment

If you need to deploy the Forward Inheritance schema:

### Step 1: Deploy Base Schema
```bash
# Deploy the Forward Inheritance schema SQL files in order:
psql -h localhost -p 5432 -U postgres -d fwd_db -f "docs/requirements/DB/sql scripts/1_ SQL_create_ fwd_db.sql"
psql -h localhost -p 5432 -U postgres -d fwd_db -f "docs/requirements/DB/sql scripts/2_SQL_create_schema_structure.sql"
psql -h localhost -p 5432 -U postgres -d fwd_db -f "docs/requirements/DB/sql scripts/3_SQL_create_schema_relationships.sql"
```

### Step 2: Deploy Stored Procedures
```bash  
# Deploy all stored procedures
psql -h localhost -p 5432 -U postgres -d fwd_db -f "docs/requirements/DB/sql scripts/4_SQL_create_procs.sql"
```

### Step 3: Verify Deployment
```bash
# Check tables (should see asset_permissions among others)
psql -h localhost -p 5432 -U postgres -d fwd_db -c "\dt"

# Check stored procedures
psql -h localhost -p 5432 -U postgres -d fwd_db -c "\df sp_*"

# Check enums
psql -h localhost -p 5432 -U postgres -d fwd_db -c "\dT+"
```

## 📝 Script Options and Configuration

### Available Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `npm run forward-generate` | Generate complete test scenario | `npm run forward-generate` |
| `npm run forward-clean` | Clean all test data | `npm run forward-clean` |
| `npm run forward-info` | Show scenario information | `npm run forward-info` |
| `npm run build` | Compile TypeScript | `npm run build` |

### Command Line Options

| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `--db-host` | Database host | `localhost` | `--db-host myserver.com` |
| `--db-port` | Database port | `5432` | `--db-port 5433` |
| `--db-name` | Database name | `fwd_db` | `--db-name test_db` |
| `--db-user` | Database user | `postgres` | `--db-user myuser` |
| `--db-password` | Database password | `password` | `--db-password mypass` |
| `--confirm` | Skip confirmation (clean command) | `false` | `--confirm` |

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `DB_HOST` | Database host | `DB_HOST=localhost` |
| `DB_PORT` | Database port | `DB_PORT=5432` |
| `DB_NAME` | Database name | `DB_NAME=forward_test` |
| `DB_USER` | Database user | `DB_USER=postgres` |
| `DB_PASSWORD` | Database password | `DB_PASSWORD=mypassword` |
| `DEBUG` | Enable debug output | `DEBUG=true` |

## 🧪 Verifying Generated Data

After running the generator, verify the data was created correctly:

### Check Family Circles
```sql
-- Count FFCs
SELECT COUNT(*) FROM fwd_family_circles;

-- View FFC details
SELECT id, name, description FROM fwd_family_circles LIMIT 5;
```

### Check Members
```sql
-- Count total personas
SELECT COUNT(*) FROM personas;

-- Members per FFC
SELECT ffc_id, COUNT(*) as member_count 
FROM ffc_personas 
GROUP BY ffc_id 
ORDER BY member_count;
```

### Check Assets
```sql
-- Count assets by category
SELECT category, COUNT(*) as count 
FROM assets 
GROUP BY category 
ORDER BY count DESC;

-- Total estimated value
SELECT SUM(estimated_value) as total_value FROM assets;
```

### Check Ownership
```sql
-- Verify ownership percentages add up to 100%
SELECT asset_id, SUM(ownership_percentage) as total_pct
FROM asset_ownerships
GROUP BY asset_id
HAVING SUM(ownership_percentage) != 100;
```

### Check Asset Permissions
```sql
-- Count total asset permissions
SELECT COUNT(*) FROM asset_permissions;

-- Permissions by level
SELECT permission_level, COUNT(*) as count 
FROM asset_permissions 
GROUP BY permission_level 
ORDER BY count DESC;

-- Verify all permissions have valid tenant_id
SELECT COUNT(*) FROM asset_permissions WHERE tenant_id IS NULL;

-- Check permissions per asset
SELECT asset_id, COUNT(*) as permission_count
FROM asset_permissions
GROUP BY asset_id
ORDER BY permission_count DESC;
```

## 🚨 Troubleshooting

### Generator Fails to Start

1. **Check Node.js version:**
   ```bash
   node --version  # Should be v18+
   ```

2. **Reinstall dependencies:**
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **Compile TypeScript:**
   ```bash
   npm run build
   ```

### Stored Procedure Errors

If you get "function does not exist" errors:

1. **Verify procedures are deployed:**
   ```bash
   psql -d fwd_db -c "\df+ sp_register_user"
   ```

2. **Check procedure signatures match:**
   - Compare the calls in `StoredProcTestDataGenerator.ts` with your deployed procedures
   - Ensure parameter types and counts match exactly

### Performance Issues

If generation is slow:

1. **Check database connections:**
   ```bash
   # Monitor active connections
   psql -d fwd_db -c "SELECT count(*) FROM pg_stat_activity;"
   ```

2. **Increase connection pool:**
   - Edit `StoredProcTestDataGenerator.ts` and adjust Pool configuration

3. **Check for missing indexes:**
   ```sql
   -- Add indexes if missing
   CREATE INDEX CONCURRENTLY idx_assets_tenant_category ON assets(tenant_id, category);
   CREATE INDEX CONCURRENTLY idx_personas_tenant ON personas(tenant_id);
   ```

## 📞 Support

For issues:

1. **Check the logs** - Error messages usually indicate the specific problem
2. **Verify database connectivity** - Test connection with `psql` first  
3. **Confirm schema deployment** - Ensure all tables and procedures exist
4. **Review permissions** - Make sure your user can read/write all required tables

## 🎯 What's Generated

The Forward test scenario creates:

### Core Data
- **1 Tenant** - "Forward Test Tenant" (ID: 1)
- **10 Forward Family Circles** - Each with unique bilingual names and descriptions
- **37-43 Personas** - Culturally diverse with realistic names, contact details, and bilingual support (English/Spanish)
- **100-107 Assets** - Comprehensive coverage across all 13 categories with realistic values

### Asset Categories (All 13 Covered)
1. **Personal Directives** - Power of Attorney, Healthcare directives, HIPAA authorizations
2. **Trusts** - Revocable, Irrevocable, Charitable trusts with proper legal structure
3. **Wills** - Last Will & Testament documents with executors
4. **Personal Property** - Art, Jewelry, Collectibles, Antiques
5. **Operational Property** - Vehicles, Boats, Equipment, Machinery
6. **Inventory** - Business assets, Raw materials, Finished goods
7. **Real Estate** - Primary homes, Secondary properties, Commercial real estate
8. **Life Insurance** - Term, Whole life, Universal policies with proper cash values
9. **Financial Accounts** - Bank, Investment, Retirement accounts
10. **Recurring Income** - Royalties, Rental income, Pensions
11. **Digital Assets** - Cryptocurrency, Domain names, NFTs, Digital media
12. **Ownership Interests** - Business equity, Partnership stakes, LLC interests
13. **Loans** - Home equity, Interfamily loans, Mortgages (handled as positive liability amounts)

### Advanced Features
- **Complex Ownership Structures** - 1-3 owners per asset with proper percentage distributions totaling 100%
- **Hybrid Permission System** - Combines RBAC roles with direct asset-level permissions
- **Granular Asset Permissions** - Read/Edit/Admin access levels for specific assets per family member
- **Family-Friendly Security** - Intuitive "who can see what" permission model
- **Realistic Wealth Distribution** - $25-30M total portfolios across High Net Worth and Mass Affluent scenarios
- **Multi-Generational Structures** - Parents, children, spouses, and advisors with appropriate relationships
- **Bilingual Support** - Spanish and English family names, descriptions, and cultural diversity

### Database Validation
- **Error-Free Generation** - All constraint validations pass
- **Foreign Key Integrity** - Proper relationships between all entities  
- **Permission Consistency** - Asset permissions properly linked to tenants, assets, and personas
- **Data Quality** - Realistic names, addresses, values, and relationships

This provides comprehensive test data for all Forward Inheritance Platform functionality including the complete hybrid permission system!