# Forward Inheritance Platform - Complete Directory Structure Creation
# Winston (Architect) - Based on architecture.md specifications
# Creates all directories and initial configuration files

Write-Host "🏗️  Creating Complete Directory Structure..." -ForegroundColor Green
Write-Host "📋 Following architecture.md repository structure specifications" -ForegroundColor Yellow

# Ensure we're in the FWD-INH repository root
if (!(Test-Path "docs/prd.md")) {
    Write-Host "❌ Error: Not in FWD-INH repository root. Please run from repository root directory." -ForegroundColor Red
    exit 1
}

# Check if NX was initialized (apps directory should exist after NX setup)
if (!(Test-Path "apps")) {
    Write-Host "❌ Error: NX workspace not initialized. Run setup-phase0-monorepo.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Creating Frontend Directory Structure ===" -ForegroundColor Cyan

# Frontend app structure (apps/frontend/)
$frontendDirs = @(
    "apps/frontend/src/app/components/ui",
    "apps/frontend/src/app/components/forms",
    "apps/frontend/src/app/components/layout",
    "apps/frontend/src/app/components/charts",
    "apps/frontend/src/app/components/cards",
    "apps/frontend/src/app/pages/auth",
    "apps/frontend/src/app/pages/dashboard",
    "apps/frontend/src/app/pages/ffc",
    "apps/frontend/src/app/pages/assets",
    "apps/frontend/src/app/pages/reports",
    "apps/frontend/src/app/pages/settings",
    "apps/frontend/src/app/hooks",
    "apps/frontend/src/app/services/api",
    "apps/frontend/src/app/services/auth",
    "apps/frontend/src/app/store/slices",
    "apps/frontend/src/app/utils",
    "apps/frontend/src/app/types",
    "apps/frontend/src/app/constants",
    "apps/frontend/src/assets/images",
    "apps/frontend/src/assets/icons",
    "apps/frontend/src/assets/fonts",
    "apps/frontend/src/styles/components",
    "apps/frontend/src/styles/globals"
)

foreach ($dir in $frontendDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "✅ Created: $dir" -ForegroundColor Green
}

Write-Host "`n=== Creating Backend Directory Structure ===" -ForegroundColor Cyan

# Backend API structure (apps/api/) - Following architecture.md specifications
$backendDirs = @(
    "apps/api/src/app/modules/auth",
    "apps/api/src/app/modules/users",
    "apps/api/src/app/modules/ffc",
    "apps/api/src/app/modules/assets",
    "apps/api/src/app/modules/subscription",
    "apps/api/src/app/modules/integration",
    "apps/api/src/app/database/queries/Authentication",
    "apps/api/src/app/database/queries/Assets", 
    "apps/api/src/app/database/queries/Subscriptions",
    "apps/api/src/app/database/queries/Contacts",
    "apps/api/src/app/database/queries/Audit",
    "apps/api/src/app/database/queries/EventSourcing",
    "apps/api/src/app/database/queries/Integrations",
    "apps/api/src/app/database/queries/Wrappers",
    "apps/api/src/app/database/types",
    "apps/api/src/app/database/migrations",
    "apps/api/src/app/database/client",
    "apps/api/src/app/guards",
    "apps/api/src/app/interceptors",
    "apps/api/src/app/decorators",
    "apps/api/src/app/pipes",
    "apps/api/src/app/filters",
    "apps/api/src/app/middleware",
    "apps/api/src/app/utils",
    "apps/api/src/app/types",
    "apps/api/src/app/constants",
    "apps/api/src/app/config",
    "apps/api/src/app/services/external",
    "apps/api/src/app/services/internal"
)

foreach ($dir in $backendDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "✅ Created: $dir" -ForegroundColor Green
}

Write-Host "`n=== Creating Shared Library Structure ===" -ForegroundColor Cyan

# Shared library structure (packages/shared/)
$sharedDirs = @(
    "packages/shared/src/lib/types/api",
    "packages/shared/src/lib/types/database",
    "packages/shared/src/lib/types/ui",
    "packages/shared/src/lib/schemas/auth",
    "packages/shared/src/lib/schemas/assets",
    "packages/shared/src/lib/schemas/ffc",
    "packages/shared/src/lib/utils/validation",
    "packages/shared/src/lib/utils/formatting",
    "packages/shared/src/lib/constants"
)

foreach ($dir in $sharedDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "✅ Created: $dir" -ForegroundColor Green
}

Write-Host "`n=== Creating Infrastructure Directory Structure ===" -ForegroundColor Cyan

# Infrastructure structure following architecture.md
$infraDirs = @(
    "infra/pulumi/00-account-foundation",
    "infra/pulumi/10-network-dev-open", 
    "infra/pulumi/20-data-dev",
    "infra/pulumi/30-ecr-ecs-api",
    "infra/pulumi/40-frontend-amplify",
    "infra/pulumi/50-auth-cognito",
    "infra/pulumi/55-api-gateway",
    "infra/pulumi/60-queues-workers",
    "infra/pulumi/70-step-functions-doc-pipeline",
    "infra/pulumi/80-network-harden",
    "infra/pulumi/90-cloudfront",
    "infra/pulumi/95-observability",
    "infra/pulumi/99-cicd"
)

foreach ($dir in $infraDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "✅ Created: $dir" -ForegroundColor Green
}

Write-Host "`n=== Creating Database and Testing Structure ===" -ForegroundColor Cyan

# Database, testing, and development structure
$otherDirs = @(
    "database/migrations",
    "database/seeds",
    "database/schemas",
    "scripts/dev",
    "scripts/build",
    "scripts/deploy",
    "docs/api",
    "docs/deployment",
    "tests/e2e/specs",
    "tests/e2e/fixtures",
    "tests/integration",
    "tests/unit",
    ".github/workflows",
    ".docker/postgres",
    ".docker/api",
    ".docker/frontend"
)

foreach ($dir in $otherDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "✅ Created: $dir" -ForegroundColor Green
}

Write-Host "`n=== Copying SQL Files to Database Structure ===" -ForegroundColor Cyan

# Copy SQL files from docs/requirements/DB/sql scripts/5_SQL_files/ to apps/api/src/app/database/queries/
$sqlSourceDir = "docs/requirements/DB/sql scripts/5_SQL_files"
$sqlTargetDir = "apps/api/src/app/database/queries"

if (Test-Path $sqlSourceDir) {
    Write-Host "Copying SQL files from $sqlSourceDir to $sqlTargetDir..." -ForegroundColor Yellow
    
    # Get all .sql files recursively from source directory
    $sqlFiles = Get-ChildItem -Path $sqlSourceDir -Filter "*.sql" -Recurse
    
    foreach ($file in $sqlFiles) {
        # Determine category based on file name patterns (following architecture.md organization)
        $category = "Integrations"  # Default category
        
        if ($file.Name -match "auth|login|user|cognito") { $category = "Authentication" }
        elseif ($file.Name -match "asset|real_estate|financial|digital") { $category = "Assets" }
        elseif ($file.Name -match "subscription|payment|stripe|billing") { $category = "Subscriptions" }
        elseif ($file.Name -match "contact|email|phone|address") { $category = "Contacts" }
        elseif ($file.Name -match "audit|log_") { $category = "Audit" }
        elseif ($file.Name -match "event|append_event|replay") { $category = "EventSourcing" }
        elseif ($file.Name -match "sp_|call_sp_") { $category = "Wrappers" }
        elseif ($file.Name -match "quiltt|builder|hei|real_estate") { $category = "Integrations" }
        
        $targetPath = "$sqlTargetDir/$category"
        
        # Ensure target directory exists
        if (!(Test-Path $targetPath)) {
            New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
        }
        
        # Copy file to appropriate category folder
        $targetFile = "$targetPath/$($file.Name)"
        Copy-Item -Path $file.FullName -Destination $targetFile -Force
        Write-Host "✅ Copied: $($file.Name) → $category/" -ForegroundColor Green
    }
    
    Write-Host "✅ SQL files organized by category in database/queries structure" -ForegroundColor Green
} else {
    Write-Host "⚠️  SQL files directory not found: $sqlSourceDir" -ForegroundColor Yellow
    Write-Host "   SQL files will need to be organized manually" -ForegroundColor Yellow
}

# Copy main schema files to migrations directory
$schemaFiles = @(
    @{src="docs/requirements/DB/sql scripts/1_SQL_create_fwd_db.sql"; dest="apps/api/src/app/database/migrations/001_create_database.sql"},
    @{src="docs/requirements/DB/sql scripts/2_SQL_create_schema_structure.sql"; dest="apps/api/src/app/database/migrations/002_create_schema.sql"},
    @{src="docs/requirements/DB/sql scripts/3_SQL_create_schema_relationships.sql"; dest="apps/api/src/app/database/migrations/003_create_relationships.sql"},
    @{src="docs/requirements/DB/sql scripts/4_SQL_create_procs.sql"; dest="apps/api/src/app/database/migrations/004_create_procedures.sql"},
    @{src="docs/requirements/DB/sql scripts/5_SQL_mcp_writer_role_RLS_bypass.sql"; dest="apps/api/src/app/database/migrations/005_mcp_writer_role.sql"}
)

Write-Host "`nCopying schema files to migrations..." -ForegroundColor Yellow
foreach ($schema in $schemaFiles) {
    if (Test-Path $schema.src) {
        # Ensure migrations directory exists
        $migrationsDir = Split-Path $schema.dest -Parent
        if (!(Test-Path $migrationsDir)) {
            New-Item -ItemType Directory -Force -Path $migrationsDir | Out-Null
        }
        
        Copy-Item -Path $schema.src -Destination $schema.dest -Force
        $fileName = Split-Path $schema.dest -Leaf
        Write-Host "✅ Copied: $fileName" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Not found: $($schema.src)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Creating Configuration Files ===" -ForegroundColor Cyan

# Create Tailwind config for frontend
$tailwindConfig = @"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './apps/frontend/src/**/*.{js,ts,jsx,tsx,html}',
    './packages/shared/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          900: '#1e3a8a',
        },
        secondary: {
          50: '#f9fafb',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          900: '#111827',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
};
"@
$tailwindConfig | Out-File -FilePath "tailwind.config.js" -Encoding UTF8

# Create PostCSS config
$postcssConfig = @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
"@
$postcssConfig | Out-File -FilePath "postcss.config.js" -Encoding UTF8

# Create pgTyped configuration following architecture.md specifications
$pgTypedConfig = @"
{
  "transforms": [
    {
      "mode": "sql",
      "include": "apps/api/src/app/database/queries/**/*.sql",
      "emitTemplate": "apps/api/src/app/database/types/{{name}}.types.ts"
    }
  ],
  "srcDir": "./apps/api/src/app/database/queries",
  "failOnError": false,
  "camelCaseColumnNames": true,
  "db": {
    "host": "localhost",
    "port": 15432,
    "dbName": "fwd_inh", 
    "user": "fwd_user",
    "password": "FGt!3reGTdt5BG!"
  }
}
"@
$pgTypedConfig | Out-File -FilePath "pgtyped.config.json" -Encoding UTF8

# Create environment template
$envTemplate = @"
# Database Configuration
DATABASE_URL=postgresql://fwd_user:FGt!3reGTdt5BG!@localhost:15432/fwd_inh

# JWT Configuration  
JWT_SECRET=your_jwt_secret_here_phase0_local
JWT_EXPIRES_IN=24h

# API Configuration
API_PORT=3333
API_PREFIX=api
CORS_ORIGIN=http://localhost:4200

# Frontend Configuration
VITE_API_URL=http://localhost:3333/api

# AWS Configuration (Phase 1A+)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# External Services (Phase 1B+)
STRIPE_SECRET_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
QUILTT_API_KEY=
BUILDER_IO_PUBLIC_KEY=
BUILDER_IO_PRIVATE_KEY=

# Development
NODE_ENV=development
LOG_LEVEL=debug
"@
$envTemplate | Out-File -FilePath ".env.example" -Encoding UTF8

# Update package.json scripts
Write-Host "Updating package.json with development scripts..." -ForegroundColor Yellow

$packageJsonPath = "package.json"
if (Test-Path $packageJsonPath) {
    $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
    
    # Add development scripts
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "dev:frontend" -Value "nx serve frontend" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "dev:backend" -Value "nx serve api" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "dev:db" -Value "docker-compose up postgres" -Force  
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "dev:full" -Value "docker-compose up" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "build:frontend" -Value "nx build frontend" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "build:backend" -Value "nx build api" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "test:e2e" -Value "nx e2e frontend-e2e" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "test:unit" -Value "nx test" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "lint" -Value "nx lint" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "typecheck" -Value "nx run-many --target=typecheck" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "pgtyped" -Value "pgtyped -c pgtyped.config.json" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "db:types" -Value "pgtyped -c pgtyped.config.json" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "db:types:watch" -Value "pgtyped -w -c pgtyped.config.json" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "db:migrate" -Value "node scripts/migrate.js" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "docker:build" -Value "docker-compose build" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "docker:up" -Value "docker-compose up -d" -Force
    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name "docker:down" -Value "docker-compose down" -Force
    
    $packageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath $packageJsonPath -Encoding UTF8
}

# Create basic README files for each major directory
$readmeContent = @"
# Forward Inheritance Platform - Phase 0

This directory is part of the Forward Inheritance Platform monorepo structure.

## Architecture
- NX Monorepo with React frontend and NestJS backend
- PostgreSQL database with pgTyped + Slonik
- Pulumi infrastructure as code
- Phase 0: Local development with Docker

## Getting Started
1. Run \`npm run docker:up\` to start PostgreSQL
2. Run \`npm run dev:backend\` to start API server
3. Run \`npm run dev:frontend\` to start React app

See the main README.md for complete setup instructions.
"@

$readmeDirs = @("apps/frontend", "apps/api", "packages/shared", "infra", "database", "tests")
foreach ($dir in $readmeDirs) {
    $readmeContent | Out-File -FilePath "$dir/README.md" -Encoding UTF8
    Write-Host "✅ Created: $dir/README.md" -ForegroundColor Green
}

Write-Host "`n=== Creating Git Configuration ===" -ForegroundColor Cyan

# Create comprehensive .gitignore (append to existing if it exists)
$gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
.nx/
tmp/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Database
*.db
*.sqlite

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# ESLint cache
.eslintcache

# Prettier cache
.prettierrc

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
.docker/data/

# Pulumi
infra/pulumi/Pulumi.*.yaml

# Generated types
*.generated.ts
*.queries.ts

# Test results
test-results/
playwright-report/
"@
# Append to existing .gitignore or create new one
if (Test-Path ".gitignore") {
    Write-Host "⚠️  .gitignore exists - appending Phase 0 specific entries..." -ForegroundColor Yellow
    "`n# === Phase 0 Monorepo Additions ===" | Out-File -FilePath ".gitignore" -Append -Encoding UTF8
    $gitignoreContent | Out-File -FilePath ".gitignore" -Append -Encoding UTF8
} else {
    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
}
Write-Host "✅ Updated .gitignore with Phase 0 entries" -ForegroundColor Green

# Create Slonik database client configuration
Write-Host "Creating Slonik database client configuration..." -ForegroundColor Yellow

$slonikConfig = @"
import { createPool, DatabasePool, sql } from 'slonik';
import { createFieldNameTransformationInterceptor } from 'slonik';

export class DatabaseClient {
  private pool: DatabasePool;

  async connect(): Promise<void> {
    this.pool = await createPool(
      process.env.DATABASE_URL || 'postgresql://fwd_user:FGt!3reGTdt5BG!@localhost:15432/fwd_inh',
      {
        interceptors: [
          createFieldNameTransformationInterceptor({
            format: 'CAMEL_CASE'
          })
        ],
        maximumPoolSize: 10
      }
    );
  }

  getPool(): DatabasePool {
    return this.pool;
  }

  async disconnect(): Promise<void> {
    await this.pool.end();
  }

  // Helper method for tenant context
  async withTenantContext<T>(tenantId: string, callback: (connection: DatabasePool) => Promise<T>): Promise<T> {
    return this.pool.connect(async (connection) => {
      await connection.query(sql\`SELECT set_config('app.current_tenant_id', \${tenantId}, true)\`);
      return callback(connection);
    });
  }
}

export const databaseClient = new DatabaseClient();
"@

$slonikConfig | Out-File -FilePath "apps/api/src/app/database/client/database-client.ts" -Encoding UTF8
Write-Host "✅ Created: apps/api/src/app/database/client/database-client.ts" -ForegroundColor Green

# Create a sample SQL query file with pgTyped integration
$sampleQuery = @"
/* @name GetUserById */
SELECT 
    u.user_id,
    u.email,
    u.email_verified,
    u.created_at,
    p.persona_id,
    p.first_name,
    p.last_name
FROM users u
LEFT JOIN persona p ON u.user_id = p.user_id
WHERE u.user_id = :userId;

/* @name GetFFCsForUser */
SELECT 
    f.ffc_id,
    f.ffc_name,
    f.description,
    fm.role,
    fm.status
FROM ffc f
INNER JOIN ffc_membership fm ON f.ffc_id = fm.ffc_id
INNER JOIN persona p ON fm.persona_id = p.persona_id
WHERE p.user_id = :userId
AND fm.status = 'active';
"@

$sampleQuery | Out-File -FilePath "apps/api/src/app/database/queries/Authentication/user-queries.sql" -Encoding UTF8
Write-Host "✅ Created sample pgTyped query: apps/api/src/app/database/queries/Authentication/user-queries.sql" -ForegroundColor Green

Write-Host "`n✅ Directory Structure Creation Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Yellow
Write-Host "   • Frontend structure: ✅" -ForegroundColor Green
Write-Host "   • Backend structure: ✅" -ForegroundColor Green  
Write-Host "   • Shared library: ✅" -ForegroundColor Green
Write-Host "   • Infrastructure: ✅" -ForegroundColor Green
Write-Host "   • Database & Testing: ✅" -ForegroundColor Green
Write-Host "   • Configuration files: ✅" -ForegroundColor Green

Write-Host "`n🐳 Next: Run './create-docker-setup.ps1' to create Docker configuration" -ForegroundColor Yellow
Write-Host "🚀 Then: Run 'npm run docker:up' to start PostgreSQL" -ForegroundColor Yellow