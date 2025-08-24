# Forward Inheritance Platform - Docker Configuration Setup
# Winston (Architect) - Phase 0 Docker environment
# Creates Docker Compose and Dockerfiles for complete local development

Write-Host "🐳 Creating Docker Configuration for Phase 0..." -ForegroundColor Green
Write-Host "📋 Setting up PostgreSQL with your existing SQL scripts" -ForegroundColor Yellow

# Ensure we're in the FWD-INH repository root
if (!(Test-Path "docs/prd.md")) {
    Write-Host "❌ Error: Not in FWD-INH repository root. Please run from repository root directory." -ForegroundColor Red
    exit 1
}

# Check if NX was initialized
if (!(Test-Path "apps")) {
    Write-Host "❌ Error: NX workspace not initialized. Run previous setup scripts first." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Creating Docker Compose Configuration ===" -ForegroundColor Cyan

# Main docker-compose.yml for Phase 0
$dockerCompose = @"
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: fwd-postgres
    environment:
      POSTGRES_DB: fwd_inh
      POSTGRES_USER: fwd_user
      POSTGRES_PASSWORD: FGt!3reGTdt5BG!
      POSTGRES_INITDB_ARGS: '--encoding=UTF8 --locale=C'
    ports:
      - "15432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      # Mount your existing SQL scripts for initialization (relative to current directory)
      - ./docs/requirements/DB/sql scripts/1_SQL_create_fwd_db.sql:/docker-entrypoint-initdb.d/01-create-db.sql:ro
      - ./docs/requirements/DB/sql scripts/2_SQL_create_schema_structure.sql:/docker-entrypoint-initdb.d/02-schema-structure.sql:ro
      - ./docs/requirements/DB/sql scripts/3_SQL_create_schema_relationships.sql:/docker-entrypoint-initdb.d/03-schema-relationships.sql:ro
      - ./docs/requirements/DB/sql scripts/4_SQL_create_procs.sql:/docker-entrypoint-initdb.d/04-procedures.sql:ro
      - ./docs/requirements/DB/sql scripts/5_SQL_mcp_writer_role_RLS_bypass.sql:/docker-entrypoint-initdb.d/05-mcp-writer-role.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U fwd_user -d fwd_inh"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - fwd-network

  # Phase 0: API will run via nx serve (not containerized yet)
  # Uncomment for Phase 1A when moving to containers
  # api:
  #   build:
  #     context: .
  #     dockerfile: .docker/api/Dockerfile
  #   container_name: fwd-api
  #   ports:
  #     - "3333:3333"
  #   environment:
  #     - NODE_ENV=development
  #     - DATABASE_URL=postgresql://fwd_user:FGt!3reGTdt5BG!@postgres:5432/fwd_inh
  #     - JWT_SECRET=phase0_local_secret
  #   depends_on:
  #     postgres:
  #       condition: service_healthy
  #   volumes:
  #     - ./apps/api:/app/apps/api
  #     - ./packages:/app/packages
  #   networks:
  #     - fwd-network

  # Phase 0: Frontend will run via nx serve (not containerized yet)  
  # Uncomment for Phase 1A when moving to containers
  # frontend:
  #   build:
  #     context: .
  #     dockerfile: .docker/frontend/Dockerfile
  #   container_name: fwd-frontend
  #   ports:
  #     - "4200:4200"
  #   environment:
  #     - VITE_API_URL=http://localhost:3333/api
  #   volumes:
  #     - ./apps/frontend:/app/apps/frontend
  #     - ./packages:/app/packages
  #   networks:
  #     - fwd-network

volumes:
  postgres_data:
    driver: local

networks:
  fwd-network:
    driver: bridge
"@

$dockerCompose | Out-File -FilePath "docker-compose.yml" -Encoding UTF8
Write-Host "✅ Created: docker-compose.yml" -ForegroundColor Green

Write-Host "`n=== Creating Development Docker Compose Override ===" -ForegroundColor Cyan

# docker-compose.override.yml for development-specific settings
$dockerComposeOverride = @"
version: '3.8'

services:
  postgres:
    # Development-specific PostgreSQL settings
    environment:
      POSTGRES_DB: fwd_inh
      POSTGRES_USER: fwd_user  
      POSTGRES_PASSWORD: FGt!3reGTdt5BG!
      # Enable detailed logging for development
      POSTGRES_LOG_STATEMENT: all
      POSTGRES_LOG_DURATION: "on"
    volumes:
      # Additional development volumes
      - ./database/seeds:/docker-entrypoint-initdb.d/seeds:ro
    # Expose on all interfaces for development
    ports:
      - "0.0.0.0:5432:5432"
"@

$dockerComposeOverride | Out-File -FilePath "docker-compose.override.yml" -Encoding UTF8
Write-Host "✅ Created: docker-compose.override.yml" -ForegroundColor Green

Write-Host "`n=== Creating Docker Configurations ===" -ForegroundColor Cyan

# PostgreSQL Dockerfile for custom configuration
$postgresDockerfile = @"
FROM postgres:15-alpine

# Install additional PostgreSQL extensions if needed
RUN apk add --no-cache postgresql-contrib

# Copy custom PostgreSQL configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Set custom entrypoint if needed
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

EXPOSE 5432

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
"@

$postgresDockerfile | Out-File -FilePath ".docker/postgres/Dockerfile" -Encoding UTF8
Write-Host "✅ Created: .docker/postgres/Dockerfile" -ForegroundColor Green

# API Dockerfile (for Phase 1A)
$apiDockerfile = @"
# Phase 1A: NestJS API Dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY nx.json ./
COPY tsconfig.base.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the API application
RUN npx nx build api

FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

# Copy built application
COPY --from=builder --chown=nestjs:nodejs /app/dist/apps/api ./
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules

USER nestjs

EXPOSE 3333

CMD ["node", "main.js"]
"@

$apiDockerfile | Out-File -FilePath ".docker/api/Dockerfile" -Encoding UTF8
Write-Host "✅ Created: .docker/api/Dockerfile" -ForegroundColor Green

# Frontend Dockerfile (for Phase 1A) 
$frontendDockerfile = @"
# Phase 1A: React Frontend Dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package*.json ./
COPY nx.json ./
COPY tsconfig.base.json ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the frontend application
RUN npx nx build frontend

FROM nginx:alpine AS runner
WORKDIR /app

# Copy built assets
COPY --from=builder /app/dist/apps/frontend /usr/share/nginx/html

# Copy nginx configuration
COPY .docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
"@

$frontendDockerfile | Out-File -FilePath ".docker/frontend/Dockerfile" -Encoding UTF8
Write-Host "✅ Created: .docker/frontend/Dockerfile" -ForegroundColor Green

# Nginx configuration for frontend
$nginxConfig = @"
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle React Router (SPA)
    location / {
        try_files `$uri `$uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}
"@

$nginxConfig | Out-File -FilePath ".docker/frontend/nginx.conf" -Encoding UTF8
Write-Host "✅ Created: .docker/frontend/nginx.conf" -ForegroundColor Green

Write-Host "`n=== Creating Database Initialization Scripts ===" -ForegroundColor Cyan

# Create database seed script for development data
$seedScript = @"
-- Development seed data for Phase 0
-- This file will be executed after the main SQL scripts

-- Insert test user (Phase 0 local development)
INSERT INTO users (user_id, cognito_sub, email, email_verified, created_at) 
VALUES (
    'test-user-uuid-12345678901234567890',
    'local_test_user',
    'test@forwardinheritance.com',
    true,
    NOW()
) ON CONFLICT (cognito_sub) DO NOTHING;

-- Insert test persona for the user
INSERT INTO persona (persona_id, user_id, first_name, last_name, date_of_birth, created_at)
VALUES (
    'test-persona-uuid-12345678901234567890',
    'test-user-uuid-12345678901234567890',
    'Test',
    'User',
    '1980-01-01',
    NOW()
) ON CONFLICT (persona_id) DO NOTHING;

-- Create test FFC
INSERT INTO ffc (ffc_id, ffc_name, description, created_by, created_at)
VALUES (
    'test-ffc-uuid-12345678901234567890',
    'Test Family Circle',
    'Development test family circle',
    'test-user-uuid-12345678901234567890',
    NOW()
) ON CONFLICT (ffc_id) DO NOTHING;

-- Add persona to FFC
INSERT INTO ffc_membership (ffc_id, persona_id, role, status, created_at)
VALUES (
    'test-ffc-uuid-12345678901234567890',
    'test-persona-uuid-12345678901234567890',
    'owner'::role_type_enum,
    'active'::status_enum,
    NOW()
) ON CONFLICT (ffc_id, persona_id) DO NOTHING;

COMMIT;
"@

$seedScript | Out-File -FilePath "database/seeds/01-test-data.sql" -Encoding UTF8
Write-Host "✅ Created: database/seeds/01-test-data.sql" -ForegroundColor Green

Write-Host "`n=== Creating Docker Helper Scripts ===" -ForegroundColor Cyan

# Database reset script
$dbResetScript = @"
# Database Reset Script for Phase 0
# Completely resets the PostgreSQL database with fresh schema

Write-Host "🔄 Resetting PostgreSQL Database..." -ForegroundColor Yellow

# Stop and remove existing container
docker-compose down postgres
docker volume rm fwd-inh_postgres_data -f

Write-Host "✅ Database container and volume removed" -ForegroundColor Green

# Start fresh PostgreSQL container
docker-compose up postgres -d

Write-Host "✅ Fresh PostgreSQL container started" -ForegroundColor Green
Write-Host "⏳ Waiting for database initialization..." -ForegroundColor Yellow

# Wait for database to be ready
Start-Sleep -Seconds 10

# Check if database is ready
docker-compose exec postgres pg_isready -U fwd_user -d fwd_inh

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ Database is ready!" -ForegroundColor Green
    Write-Host "📊 Checking tables..." -ForegroundColor Yellow
    docker-compose exec postgres psql -U fwd_user -d fwd_inh -c "\dt"
} else {
    Write-Host "❌ Database not ready. Check logs:" -ForegroundColor Red
    docker-compose logs postgres
}
"@

$dbResetScript | Out-File -FilePath "scripts/dev/reset-db.ps1" -Encoding UTF8
Write-Host "✅ Created: scripts/dev/reset-db.ps1" -ForegroundColor Green

# Development environment checker
$devCheckScript = @"
# Development Environment Health Check
Write-Host "🔍 Forward Inheritance Platform - Environment Check" -ForegroundColor Green

Write-Host "`n=== Docker Status ===" -ForegroundColor Cyan
docker --version
docker-compose --version

Write-Host "`n=== Container Status ===" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n=== Database Connection Test ===" -ForegroundColor Cyan
Write-Host "Testing connection on port 15432 (external)..." -ForegroundColor White
docker-compose exec postgres pg_isready -U fwd_user -d fwd_inh

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ Database connection successful (Port: 15432 → 5432)" -ForegroundColor Green
    
    Write-Host "`n=== Database Tables Check ===" -ForegroundColor Cyan
    docker-compose exec postgres psql -U fwd_user -d fwd_inh -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';"
    
    Write-Host "`n=== Sample Query Test ===" -ForegroundColor Cyan
    docker-compose exec postgres psql -U fwd_user -d fwd_inh -c "SELECT * FROM users LIMIT 1;"
} else {
    Write-Host "❌ Database connection failed" -ForegroundColor Red
    Write-Host "Checking logs..." -ForegroundColor Yellow
    docker-compose logs postgres
}

Write-Host "`n=== NX Workspace Status ===" -ForegroundColor Cyan
npx nx show projects

Write-Host "`n=== Environment Files ===" -ForegroundColor Cyan
if (Test-Path ".env") {
    Write-Host "✅ .env file exists" -ForegroundColor Green
} else {
    Write-Host "⚠️  .env file missing - copy from .env.example" -ForegroundColor Yellow
}

Write-Host "`n🎯 Phase 0 Environment Status Complete!" -ForegroundColor Green
"@

$devCheckScript | Out-File -FilePath "scripts/dev/health-check.ps1" -Encoding UTF8
Write-Host "✅ Created: scripts/dev/health-check.ps1" -ForegroundColor Green

# Create main README with complete setup instructions
$mainReadme = @"
# Forward Inheritance Platform - Phase 0

A comprehensive family-first inheritance and wealth transfer SaaS platform built with NX monorepo, React frontend, NestJS backend, and PostgreSQL database.

## 🏗️ Architecture Overview

- **Frontend**: React 18 + TypeScript + Tailwind CSS + shadcn/ui
- **Backend**: NestJS + TypeScript + Slonik + pgTyped  
- **Database**: PostgreSQL 15 with comprehensive schema (70+ tables)
- **Monorepo**: NX workspace with integrated tooling
- **Infrastructure**: Pulumi for AWS deployment (Phase 1A+)

## 📁 Repository Structure

\`\`\`
fwd-inh-app/
├── apps/
│   ├── frontend/          # React SPA application
│   └── api/              # NestJS backend API
├── packages/
│   └── shared/           # Shared TypeScript types & utilities
├── infra/
│   └── pulumi/           # Infrastructure as Code (Phase 1A+)
├── database/             # Database scripts and seeds
├── tests/               # E2E and integration tests
└── scripts/             # Development and deployment scripts
\`\`\`

## 🚀 Quick Start

### Prerequisites
- Node.js 18.17.0+
- npm 9.0.0+
- Docker Desktop
- Git

### 1. Clone and Setup
\`\`\`bash
# Clone this repository
git clone <repository-url> fwd-inh-app
cd fwd-inh-app

# Copy environment template
cp .env.example .env

# Install dependencies (already done if you ran setup scripts)
npm install
\`\`\`

### 2. Start Database
\`\`\`bash
# Start PostgreSQL with complete schema
npm run docker:up

# Wait for initialization (30-60 seconds)
# Check status
npm run dev:check
\`\`\`

### 3. Start Development Servers
\`\`\`bash
# Terminal 1: Start backend API
npm run dev:backend

# Terminal 2: Start frontend app
npm run dev:frontend
\`\`\`

### 4. Verify Setup
- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:3333/api
- **PostgreSQL**: localhost:15432 (mapped from internal 5432)

## 🛠️ Development Commands

### Core Development
\`\`\`bash
npm run dev:frontend      # Start React development server
npm run dev:backend       # Start NestJS development server  
npm run dev:db           # Start PostgreSQL only
npm run dev:full         # Start all services with Docker
\`\`\`

### Database Management
\`\`\`bash
npm run pgtyped          # Generate TypeScript types from SQL
npm run db:types         # Same as pgtyped
npm run db:types:watch   # Generate types in watch mode
npm run db:migrate       # Run database migrations
./scripts/dev/reset-db.ps1    # Reset database completely
./scripts/dev/health-check.ps1 # Check environment health
\`\`\`

### Database Structure (Following architecture.md)
\`\`\`
apps/api/src/app/database/
├── queries/             # SQL queries organized by category
│   ├── Authentication/ # User, login, auth queries (5 files)
│   ├── Assets/         # Asset management queries (15 files)  
│   ├── Subscriptions/  # Payment, billing queries (20 files)
│   ├── Contacts/       # Contact management queries (6 files)
│   ├── Audit/          # Audit trail queries (5 files)
│   ├── EventSourcing/  # Event sourcing queries (6 files)
│   ├── Integrations/   # Third-party API queries (30+ files)
│   └── Wrappers/       # Stored procedure wrappers (10 files)
├── types/              # pgTyped generated TypeScript types
├── migrations/         # Database schema migrations
└── client/             # Slonik connection configuration
\`\`\`

### Build and Test
\`\`\`bash
npm run build:frontend   # Build React app for production
npm run build:backend    # Build NestJS app for production
npm run test:unit        # Run unit tests
npm run test:e2e         # Run end-to-end tests  
npm run lint             # Run ESLint across workspace
npm run typecheck        # Run TypeScript checks
\`\`\`

### Docker Management
\`\`\`bash
npm run docker:build     # Build Docker images
npm run docker:up        # Start all containers
npm run docker:down      # Stop all containers
\`\`\`

## 📊 Database Schema

The PostgreSQL database includes:
- **70+ tables** for comprehensive asset management
- **14 asset categories** (Real Estate, Financial, Digital, etc.)
- **Complete stored procedures** for all operations
- **Row-level security** policies
- **Event sourcing** architecture
- **Audit trails** for SOC 2 compliance

Key tables:
- \`users\` & \`persona\` - User management
- \`ffc\` & \`ffc_membership\` - Family Circle management
- \`assets\` & category-specific tables - Asset management
- \`subscription\` & \`payment\` - Billing management

## 🧪 Testing Strategy

### Unit Tests
- **Frontend**: Vitest + React Testing Library
- **Backend**: Jest + Supertest
- **Shared**: Jest for utilities

### Integration Tests
- Database operations with test containers
- API endpoint testing
- External service mocking

### E2E Tests
- **Playwright** for complete user journeys
- Multi-browser testing
- Visual regression testing

## 🔧 Development Tools

### Code Quality
- **ESLint** with TypeScript and React rules
- **Prettier** for consistent formatting  
- **Husky** for pre-commit hooks
- **lint-staged** for staged file linting

### Type Safety
- **TypeScript** in strict mode across all projects
- **pgTyped** for database query type generation
- **Zod** for runtime validation schemas
- **Shared types** across frontend/backend

### Database Tools
- **Slonik** for type-safe PostgreSQL queries
- **pgTyped** for automatic TypeScript generation
- **Database migrations** with versioning
- **Seed scripts** for development data

## 📈 Phase Progression

### Phase 0: Local Development (Current)
✅ Complete local environment with Docker  
✅ All dependencies installed and configured  
✅ Database schema with all stored procedures  
✅ Basic authentication and FFC creation  
✅ Asset management foundation  

### Phase 1A: AWS Infrastructure (Next)
- AWS Cognito authentication
- RDS PostgreSQL deployment
- ECS containerized API
- S3 asset storage
- CloudFront CDN

### Phase 1B: Marketing & Features  
- Builder.io CMS integration
- Enhanced security features
- Complete asset management
- Payment processing with Stripe

## 🔒 Security Considerations

### Phase 0 Security
- Local JWT-based authentication
- Environment variable management
- Input validation with class-validator
- SQL injection prevention with Slonik

### Production Security (Phase 1A+)
- AWS Cognito multi-factor authentication
- Row-level security policies
- Encrypted data at rest and in transit
- SOC 2 compliance framework

## 🚨 Troubleshooting

### Common Issues

**Database Connection Failed**
\`\`\`bash
# Check if PostgreSQL container is running
docker-compose ps

# Reset database completely
./scripts/dev/reset-db.ps1

# Check logs
docker-compose logs postgres
\`\`\`

**Frontend Not Loading**
\`\`\`bash
# Clear NX cache
npx nx reset

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Check port conflicts
netstat -an | findstr :4200
\`\`\`

**TypeScript Errors**
\`\`\`bash
# Regenerate database types
npm run pgtyped

# Run type checking
npm run typecheck

# Clear TypeScript cache
rm -rf dist/ .nx/
\`\`\`

## 📚 Documentation

- [Architecture Documentation](./docs/architecture.md)
- [API Documentation](./docs/api/)
- [Database Schema](./docs/database/)
- [Deployment Guide](./docs/deployment/)

## 🤝 Contributing

1. Follow the established code style and conventions
2. Write tests for new features
3. Update documentation as needed  
4. Use conventional commit messages
5. Ensure all checks pass before submitting

## 📄 License

Forward Inheritance Platform - Proprietary Software

---

**Winston 🏗️ - Holistic System Architect**  
*Generated with comprehensive Phase 0 specifications*
"@

$mainReadme | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "✅ Created: README.md" -ForegroundColor Green

Write-Host "`n🎉 Docker Setup Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Yellow
Write-Host "   • Docker Compose configuration: ✅" -ForegroundColor Green
Write-Host "   • PostgreSQL container setup: ✅" -ForegroundColor Green
Write-Host "   • Development scripts: ✅" -ForegroundColor Green
Write-Host "   • Database seed data: ✅" -ForegroundColor Green
Write-Host "   • Complete README: ✅" -ForegroundColor Green

Write-Host "`n🚀 Ready to Start Development!" -ForegroundColor Green
Write-Host "Run these commands in order:" -ForegroundColor Yellow
Write-Host "1. copy .env.example .env" -ForegroundColor Cyan
Write-Host "2. npm run docker:up" -ForegroundColor Cyan  
Write-Host "3. npm run dev:backend" -ForegroundColor Cyan
Write-Host "4. npm run dev:frontend" -ForegroundColor Cyan
Write-Host "5. Open http://localhost:4200" -ForegroundColor Cyan

Write-Host "`n🔍 Use './scripts/dev/health-check.ps1' to verify everything is working!" -ForegroundColor Yellow