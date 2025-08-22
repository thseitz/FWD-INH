# Phase 0: Complete NPM Package Setup Guide

## Prerequisites

Before starting, ensure you have:
- **Node.js**: Version 18.17.0 or higher
- **npm**: Version 9.0.0 or higher  
- **Git**: Latest version
- **Docker**: Docker Desktop installed and running
- **PostgreSQL**: Optional (will use Docker container)

## Quick Start Commands

```bash
# Verify prerequisites
node --version    # Should be 18.17.0+
npm --version     # Should be 9.0.0+
docker --version  # Should be installed
```

---

## Step 1: Global Development Tools

Install these tools globally on your machine:

```bash
# Essential global tools
npm install -g @nx/cli@latest
npm install -g @pgtyped/cli@latest
npm install -g @pulumi/cli@latest
npm install -g typescript@latest
npm install -g ts-node@latest

# Optional but recommended global tools
npm install -g @nestjs/cli@latest
npm install -g vite@latest
npm install -g docker-compose
npm install -g playwright@latest
```

---

## Step 2: Create NX Monorepo Workspace

```bash
# Create workspace
npx create-nx-workspace@latest fwd-inh --preset=empty --packageManager=npm
cd fwd-inh

# Install NX plugins
npm install -D @nx/react@latest
npm install -D @nx/node@latest  
npm install -D @nx/vite@latest
npm install -D @nx/playwright@latest
npm install -D @nx/docker@latest
npm install -D @nx/jest@latest
npm install -D @nx/eslint@latest
```

---

## Step 3: Frontend Application Dependencies

### Generate React Application
```bash
# Generate frontend app
nx generate @nx/react:application frontend --bundler=vite --style=css --routing=true --unitTestRunner=vitest --e2eTestRunner=playwright
```

### Core Frontend Dependencies
```bash
# React and TypeScript
npm install react@^18.2.0
npm install react-dom@^18.2.0
npm install @types/react@^18.2.0
npm install @types/react-dom@^18.2.0

# Routing
npm install react-router-dom@^6.20.0
npm install @types/react-router-dom@latest

# Build Tools
npm install -D vite@^5.0.0
npm install -D @vitejs/plugin-react@latest
npm install -D @types/node@latest
```

### UI and Styling Dependencies
```bash
# Tailwind CSS
npm install -D tailwindcss@^3.4.0
npm install -D postcss@latest
npm install -D autoprefixer@latest
npm install -D @tailwindcss/forms@latest
npm install -D @tailwindcss/typography@latest
npm install -D @tailwindcss/aspect-ratio@latest

# shadcn/ui and Radix Dependencies
npm install @radix-ui/react-alert-dialog@latest
npm install @radix-ui/react-avatar@latest  
npm install @radix-ui/react-button@latest
npm install @radix-ui/react-card@latest
npm install @radix-ui/react-checkbox@latest
npm install @radix-ui/react-dialog@latest
npm install @radix-ui/react-dropdown-menu@latest
npm install @radix-ui/react-form@latest
npm install @radix-ui/react-input@latest
npm install @radix-ui/react-label@latest
npm install @radix-ui/react-navigation-menu@latest
npm install @radix-ui/react-popover@latest
npm install @radix-ui/react-progress@latest
npm install @radix-ui/react-scroll-area@latest
npm install @radix-ui/react-select@latest
npm install @radix-ui/react-separator@latest
npm install @radix-ui/react-sheet@latest
npm install @radix-ui/react-switch@latest
npm install @radix-ui/react-table@latest
npm install @radix-ui/react-tabs@latest
npm install @radix-ui/react-textarea@latest
npm install @radix-ui/react-toast@latest
npm install @radix-ui/react-tooltip@latest

# UI Utilities
npm install class-variance-authority@latest
npm install clsx@latest
npm install tailwind-merge@latest
npm install lucide-react@latest
```

### State Management and Data Fetching
```bash
# React Query for server state
npm install @tanstack/react-query@^5.0.0
npm install @tanstack/react-query-devtools@^5.0.0

# Client-side state management
npm install zustand@^4.4.0

# HTTP client
npm install axios@^1.6.0
npm install @types/axios@latest
```

### Forms and Validation
```bash
# Form handling
npm install react-hook-form@^7.48.0
npm install @hookform/resolvers@^3.3.0

# Validation
npm install zod@^3.22.0
```

### Builder.io Integration
```bash
# Builder.io CMS
npm install @builder.io/react@latest
npm install @builder.io/sdk@latest
```

### Charts and Data Visualization
```bash
# Financial charts
npm install recharts@^2.8.0
npm install @types/recharts@latest

# Date handling
npm install date-fns@^2.30.0
```

---

## Step 4: Backend Application Dependencies

### Generate NestJS Application
```bash
# Generate backend app
nx generate @nx/node:application api --framework=nestjs
```

### Core NestJS Dependencies
```bash
# NestJS framework
npm install @nestjs/common@^10.0.0
npm install @nestjs/core@^10.0.0
npm install @nestjs/platform-express@^10.0.0
npm install @nestjs/platform-fastify@^10.0.0

# Configuration and environment
npm install @nestjs/config@^3.1.0
npm install @nestjs/serve-static@^4.0.0

# Validation and transformation
npm install class-validator@^0.14.0
npm install class-transformer@^0.5.0
```

### Authentication and Security
```bash
# JWT and Passport
npm install @nestjs/jwt@^10.2.0
npm install @nestjs/passport@^10.0.0
npm install passport@^0.6.0
npm install passport-jwt@^4.0.0
npm install passport-local@^1.0.0
npm install @types/passport-jwt@latest
npm install @types/passport-local@latest

# Password hashing
npm install bcrypt@^5.1.0
npm install argon2@^0.31.0
npm install @types/bcrypt@latest

# Security utilities
npm install uuid@^9.0.0
npm install @types/uuid@latest
```

### Database Dependencies (pgTyped + Slonik)
```bash
# Slonik PostgreSQL client
npm install slonik@^37.0.0
npm install @slonik/typegen@latest
npm install @slonik/interceptor-preset@latest

# pgTyped for type generation
npm install pgtyped@^2.3.0
npm install @pgtyped/cli@^2.3.0
npm install @pgtyped/runtime@^2.3.0

# PostgreSQL driver
npm install pg@^8.11.0
npm install @types/pg@latest
```

### AWS SDK Dependencies
```bash
# AWS Core SDK
npm install @aws-sdk/client-s3@^3.0.0
npm install @aws-sdk/client-cognito-identity-provider@^3.0.0
npm install @aws-sdk/client-ses@^3.0.0
npm install @aws-sdk/client-step-functions@^3.0.0
npm install @aws-sdk/client-rds@^3.0.0
npm install @aws-sdk/client-cloudfront@^3.0.0

# AWS utilities
npm install @aws-sdk/util-retry@^3.0.0
npm install @aws-sdk/credential-provider-node@^3.0.0
```

### External API Integrations
```bash
# HTTP client for external APIs
npm install axios@^1.6.0
npm install node-fetch@^3.3.0
npm install @types/node-fetch@latest

# Webhook and API utilities
npm install express-rate-limit@^7.1.0
npm install helmet@^7.1.0
npm install cors@^2.8.5
npm install @types/cors@latest
```

---

## Step 5: Shared Library Dependencies

### Generate Shared Library
```bash
# Generate shared package
nx generate @nx/js:library shared --buildable=true
```

### Shared Dependencies
```bash
# Shared validation schemas
npm install zod@^3.22.0

# Utility libraries
npm install lodash@^4.17.21
npm install @types/lodash@latest
npm install date-fns@^2.30.0
```

---

## Step 6: Testing Dependencies

### Playwright E2E Testing
```bash
# Playwright setup
nx generate @nx/playwright:configuration --project=frontend-e2e

# Playwright dependencies
npm install -D @playwright/test@latest
npm install -D playwright@latest
```

### Unit Testing Dependencies
```bash
# Vitest for frontend
npm install -D vitest@^1.0.0
npm install -D @vitest/ui@^1.0.0
npm install -D jsdom@^23.0.0

# React Testing Library
npm install -D @testing-library/react@^14.0.0
npm install -D @testing-library/jest-dom@^6.0.0
npm install -D @testing-library/user-event@^14.0.0

# Backend testing
npm install -D supertest@^6.3.0
npm install -D @types/supertest@latest

# Jest for NestJS
npm install -D jest@^29.0.0
npm install -D @nestjs/testing@^10.0.0
npm install -D @types/jest@latest
```

---

## Step 7: Development Tools and Linting

### ESLint and Prettier
```bash
# ESLint setup
npm install -D eslint@^8.0.0
npm install -D @typescript-eslint/eslint-plugin@^6.0.0
npm install -D @typescript-eslint/parser@^6.0.0
npm install -D eslint-plugin-react@^7.33.0
npm install -D eslint-plugin-react-hooks@^4.6.0

# Prettier
npm install -D prettier@^3.0.0
npm install -D eslint-config-prettier@^9.0.0
npm install -D eslint-plugin-prettier@^5.0.0
```

### TypeScript Configuration
```bash
# TypeScript
npm install -D typescript@^5.3.0
npm install -D ts-node@^10.9.0
npm install -D tsconfig-paths@^4.2.0

# Type utilities
npm install type-fest@^4.0.0
```

---

## Step 8: Infrastructure and DevOps

### Docker and Containerization
```bash
# Docker utilities (if needed in project)
npm install -D dockerode@^4.0.0
npm install -D @types/dockerode@latest
```

### Pulumi Infrastructure
```bash
# Navigate to infra directory
mkdir -p infra/pulumi
cd infra/pulumi
npm init -y

# Pulumi packages
npm install @pulumi/pulumi@^3.0.0
npm install @pulumi/aws@^6.0.0
npm install @pulumi/awsx@^2.0.0
npm install @pulumi/docker@^4.0.0
npm install @pulumi/random@^4.0.0
npm install @pulumi/tls@^5.0.0

# Return to root
cd ../..
```

---

## Step 9: Development Scripts

Add these scripts to your root `package.json`:

```json
{
  "scripts": {
    "dev:frontend": "nx serve frontend",
    "dev:backend": "nx serve api",
    "dev:db": "docker-compose up postgres",
    "dev:full": "docker-compose up",
    "build:frontend": "nx build frontend",
    "build:backend": "nx build api",
    "test:e2e": "nx e2e frontend-e2e",
    "test:unit": "nx test",
    "lint": "nx lint",
    "typecheck": "nx run-many --target=typecheck",
    "pgtyped": "pgtyped -c pgtyped.config.json",
    "db:migrate": "node scripts/migrate.js",
    "docker:build": "docker-compose build",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down"
  }
}
```

---

## Step 10: Verification Commands

After installation, verify everything is working:

```bash
# Check NX setup
nx --version
nx show projects

# Check TypeScript
npx tsc --version

# Check pgTyped
npx pgtyped --version

# Check Playwright
npx playwright --version

# Run type checking
npm run typecheck

# Start development environment
npm run docker:up
npm run dev:full
```

---

## Complete Package Count Summary

**Total Packages to Install: ~150+ packages**

### Breakdown by Category:
- **Global Tools**: 7 packages
- **NX Workspace**: 8 plugins
- **Frontend Core**: 12 packages  
- **UI Components**: 25+ Radix components
- **State & Data**: 8 packages
- **Backend Core**: 15+ NestJS packages
- **Database**: 8 packages
- **AWS SDK**: 10+ packages
- **Testing**: 15+ packages
- **Development Tools**: 20+ packages
- **Infrastructure**: 8 Pulumi packages

### Installation Time Estimate:
- **Fresh Install**: 15-20 minutes
- **With Fast Internet**: 10-15 minutes
- **Total Disk Space**: ~2-3 GB for node_modules

---

## Troubleshooting Common Issues

### Node Version Conflicts
```bash
# Use Node Version Manager if issues arise
nvm install 18.17.0
nvm use 18.17.0
```

### Permission Issues (macOS/Linux)
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
```

### Docker Issues
```bash
# Reset Docker if containers fail
docker system prune -f
docker-compose down --volumes
```

### PostgreSQL Connection Issues
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Reset database
docker-compose down postgres
docker-compose up postgres
```

This document provides everything needed to set up the complete Phase 0 development environment for the Forward Inheritance Platform!