# Forward Inheritance Platform

A comprehensive SaaS platform for multi-generational estate planning, built with modern technologies and NX monorepo architecture.

## 🏗️ Architecture Overview

**Technology Stack:**
- **Monorepo**: NX Workspace
- **Backend**: NestJS API with PostgreSQL 17
- **Frontend**: React with Vite
- **Database**: PostgreSQL 17 with comprehensive stored procedures
- **Containerization**: Docker with Docker Compose
- **Testing**: Comprehensive database testing suite

## 📁 Project Structure

```
fwd-inh/
├── apps/                           # NX Applications
│   ├── api/                        # NestJS Backend API
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── database/       # Database Layer
│   │   │   │   │   ├── migrations/ # SQL Migration Files (4 files)
│   │   │   │   │   ├── queries/    # Organized SQL Queries (12 categories)
│   │   │   │   │   ├── testing/    # Database Testing Suite
│   │   │   │   │   └── types/      # TypeScript Database Types
│   │   │   │   └── *.ts           # NestJS Controllers & Services
│   │   │   └── main.ts
│   │   ├── Dockerfile             # Backend Container
│   │   └── project.json           # NX Project Configuration
│   └── web/                       # React Frontend
│       ├── src/
│       ├── Dockerfile             # Frontend Container
│       └── project.json
├── database/
│   └── Dockerfile                 # PostgreSQL Container Config
├── scripts/                       # Build & Utility Scripts
│   ├── build-database.js         # Complete DB Build Script
│   ├── build-database-types.js   # TypeScript Type Generation
│   └── generate-sql-checksums.js # SQL Integrity Validation
├── docs/                         # Comprehensive Documentation
│   ├── requirements/             # Product & Technical Requirements
│   ├── architecture.md          # System Architecture
│   └── prd.md                   # Product Requirements Document
├── docker-compose.yml           # Multi-container Orchestration
├── nx.json                      # NX Workspace Configuration
├── package.json                 # Root Dependencies
└── tsconfig.base.json          # TypeScript Base Configuration
```

## 🚀 Getting Started

### Prerequisites
- Node.js 20+
- Docker & Docker Compose
- Git

### 1. Installation
```bash
git clone <repository-url>
cd fwd-inh
npm install
```

### 2. Environment Setup
Create `.env.local` in project root:
```env
# PostgreSQL Configuration
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGPASSWORD=FGt!3reGTdt5BG!
PGDATABASE=fwd_db
PGSSLMODE=disable

# API Configuration
API_PORT=3003
API_HOST=localhost
CORS_ORIGIN=http://localhost:4200

# JWT Configuration
JWT_SECRET=dev-jwt-secret-change-in-production
JWT_EXPIRES_IN=24h
SESSION_SECRET=dev-session-secret-change-in-production
```

### 3. Start Development Environment
```bash
# Start all containers (database, backend, frontend)
docker-compose up -d

# Check container status
docker ps
```

## 🛠️ Available Scripts

### Database Operations
```bash
# Complete database build (migrations + test data + validation)
node scripts/build-database.js

# Generate TypeScript types from database schema
node scripts/build-database-types.js

# Validate SQL file integrity
node scripts/generate-sql-checksums.js

# Database testing only
cd apps/api/src/app/database/testing
npm run test:1:populate      # Populate test data
npm run test:2:procedures    # Test stored procedures
npm run test:3:sql-files     # Test SQL queries
npm run test:suite           # Run complete test suite
```

### NX Development Commands
```bash
# Build applications
npx nx build api              # Build backend
npx nx build web              # Build frontend
npx nx build --all            # Build all projects

# Serve applications
npx nx serve api              # Start backend development server
npx nx serve web              # Start frontend development server

# Run tests
npx nx test api               # Run backend tests
npx nx test web               # Run frontend tests

# Lint and format
npx nx lint api               # Lint backend
npx nx lint web               # Lint frontend
```

### Docker Operations
```bash
# Container management
docker-compose up -d          # Start all services
docker-compose down           # Stop all services
docker-compose logs -f        # Follow logs

# Individual services
docker-compose up database    # Start database only
docker-compose restart backend # Restart backend service
```

## 🗄️ Database Architecture

### Migration Files (4 Sequential Files)
1. **001_create_database.sql** - Database, extensions, schemas
2. **002_create_schema.sql** - Tables, types, constraints, seed data
3. **003_create_relationships.sql** - Foreign keys, constraints
4. **004_create_procedures.sql** - Stored procedures, functions, triggers

### Database Features
- **64 Tables** with comprehensive relationships
- **11 Complex Stored Procedures** for business logic
- **117 SQL Queries** organized by domain
- **Comprehensive Testing** with 100% pass rate
- **Type Safety** with auto-generated TypeScript types

### Testing Suite Statistics
- ✅ **11/11 Stored Procedures** tested and passing
- ✅ **117/117 SQL Queries** tested and passing
- 📊 **Test Coverage**: SELECT (60), INSERT (23), UPDATE (28), DELETE (2), CALL (4)
- 🚀 **Automated Test Data**: 10 users, 10 personas, 28 assets, 6 FFCs

## 🔧 Development Workflow

### 1. Database Changes
1. Update migration files in `apps/api/src/app/database/migrations/`
2. Run `node scripts/build-database.js` to validate changes
3. Generate types: `node scripts/build-database-types.js`

### 2. API Development
1. Use NX: `npx nx serve api`
2. API available at `http://localhost:3001/api`
3. Database queries in `apps/api/src/app/database/queries/`

### 3. Frontend Development
1. Use NX: `npx nx serve web`  
2. Frontend available at `http://localhost:4200`
3. Auto-proxy to API backend

### 4. Testing
```bash
# Database testing
node scripts/build-database.js

# Application testing
npx nx test api
npx nx test web
```

## 📊 Key Features

- **Multi-tenant SaaS Architecture**
- **Estate Planning & Asset Management**
- **Forward Family Circles (FFCs)**
- **Integration with Quiltt, Builder.io, HEI APIs**
- **Comprehensive Audit & Security**
- **Multi-language Support**
- **Subscription & Payment Management**

## 🐳 Container Architecture

**4-Container Setup:**
- **Database**: PostgreSQL 17 with custom configuration
- **Backend**: NestJS API with auto-migration
- **Frontend**: React SPA with Nginx
- **Redis**: Session & caching store

**Networking**: All containers on `fwd-network` with health checks

## 📈 Performance & Monitoring

- Database query testing with execution time tracking
- Container health checks for all services  
- SQL checksum validation for integrity
- Comprehensive logging and audit trails

## 🔒 Security Features

- Row-Level Security (RLS) policies
- JWT authentication with secure sessions
- PII detection and masking
- Audit logging for all operations
- Environment-based configuration

## 📚 Documentation

Comprehensive documentation available in `/docs/`:
- Architecture specifications
- Database schema reference  
- API documentation
- Feature analysis and requirements
- Integration guides

---

**Development Status**: Phase 0 Complete - Production Ready Database & API
**Next Phase**: Frontend UI implementation with Builder.io integration