# Forward Inheritance Platform Fullstack Architecture Document

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-08-01 | 1.0 | Initial fullstack architecture document | |

## Table of Contents

### 📋 Architecture Decisions
- [Architecture Decision Records (ADRs)](#architecture-decision-records-adrs)
  - [ADR-001: Nest.js over Express](#adr-001-nestjs-over-express-for-backend-framework)
  - [ADR-002: pgTyped + Slonik Database Access](#adr-002-pgtyped--slonik-for-database-access)
  - [ADR-003: AWS Cognito Authentication](#adr-003-aws-cognito-for-authentication)
  - [ADR-004: Progressive Caching Strategy](#adr-004-progressive-caching-strategy-in-memory-first)
  - [ADR-005: Monorepo with Nx](#adr-005-monorepo-with-nx)
  - [ADR-006: AWS Step Functions](#adr-006-aws-step-functions-for-document-processing)

### 🏗️ Architecture Foundation
- [Introduction](#introduction)
- [Phase 0: Local Development Architecture](#phase-0-local-development-architecture)
  - [Overview](#overview)
  - [Technology Stack](#technology-stack-1)
  - [Docker Setup](#docker-setup)
  - [Development Workflow](#development-workflow)
  - [Key Differences from Production](#key-differences-from-production)
  - [Migration Path to Phase 1A](#migration-path-to-phase-1a)
  - [Phase 0 Authentication Implementation Strategy](#phase-0-authentication-implementation-strategy)
- [AWS Infrastructure Build-Out Plan (Pulumi-Based)](#aws-infrastructure-build-out-plan-pulumi-based)
  - [Overview](#overview-1)
  - [Infrastructure Components](#infrastructure-components)
  - [Phased Deployment Strategy](#phased-deployment-strategy)
  - [Cost Optimization Strategy](#cost-optimization-strategy)
  - [Repository Structure](#repository-structure-1)
- [High Level Architecture](#high-level-architecture)
  - [Technical Summary](#technical-summary)
  - [Platform and Infrastructure Choice](#platform-and-infrastructure-choice)
  - [Repository Structure](#repository-structure)
  - [High Level Architecture Diagram](#high-level-architecture-diagram)
  - [Architectural Patterns](#architectural-patterns)

### 🔧 Technology Stack
- [Tech Stack](#tech-stack)
  - [Technology Stack Table](#technology-stack-table)

### 🗄️ Data & Database
- [Database Access Architecture (pgTyped + Slonik)](#database-access-architecture-pgtyped--slonik)
  - [pgTyped Configuration](#pgtyped-configuration)
  - [Slonik Runtime Client](#slonik-runtime-client)
  - [SQL Query Organization](#sql-query-organization)
- [Data Models](#data-models)
  - [Core Entities](#core-entities)
  - [Subscription & Payment Entities](#subscription--payment-entities)
  - [Complete Example: RealEstateAsset](#complete-example-realestateasset)
  - [Other Asset Type Examples](#other-asset-type-examples-key-fields-only)
- [Database Schema](#database-schema)

### 🔐 Security & Authentication
- [Authentication Architecture (AWS Cognito + API Gateway)](#authentication-architecture-aws-cognito--api-gateway)
  - [Cognito Configuration](#cognito-configuration)
  - [Authentication Flow](#authentication-flow)
  - [API Gateway Integration](#api-gateway-integration)
  - [Frontend Integration with Amplify](#frontend-integration-with-amplify)
  - [Security Best Practices](#security-best-practices)

### 🌐 Frontend Architecture
- [Frontend Architecture](#frontend-architecture)
  - [Component Architecture Overview](#component-architecture-overview)
  - [State Management Architecture](#state-management-architecture)
  - [Component Patterns](#component-patterns)
  - [Routing Architecture](#routing-architecture)
  - [API Service Layer](#api-service-layer)

### ⚙️ Backend Architecture
- [Backend Architecture](#backend-architecture)
  - [Nest.js Module Architecture](#nestjs-module-architecture)
  - [NestJS Controller Implementation](#nestjs-controller-implementation)
  - [AWS Step Functions Document Processing](#aws-step-functions-document-processing)
  - [Database Architecture with Nest.js](#database-architecture-with-nestjs)
  - [Authentication and Authorization Guards](#authentication-and-authorization-guards)
  - [AWS Cognito Authentication Flows](#aws-cognito-authentication-flows)
  - [Progressive Caching Strategy](#progressive-caching-strategy-cost-optimized)
  - [Real-Time WebSocket Layer](#real-time-websocket-layer-with-socketio)
  - [API Gateway Pattern Implementation](#api-gateway-pattern-implementation)
  - [Event Sourcing Architecture](#event-sourcing-architecture-postgresql-based)
  - [Queue Processing with AWS SQS](#queue-processing-with-aws-sqs)

### 🔄 Communication & Integration
- [Real-time Communication Architecture (WebSockets)](#real-time-communication-architecture-websockets)
  - [WebSocket Implementation](#websocket-implementation)
  - [Frontend WebSocket Hook](#frontend-websocket-hook)
  - [Why WebSockets over SSE](#why-websockets-over-sse)
- [Message Queue Architecture (AWS SQS)](#message-queue-architecture-aws-sqs)
  - [SQS Configuration](#sqs-configuration)
  - [Idempotent Message Processing](#idempotent-message-processing)
- [External APIs](#external-apis)
  - [Twilio API](#twilio-api)
  - [SendGrid API](#sendgrid-api)
  - [Quiltt API](#quiltt-api)
  - [HEI Asset Category & Ingestion API](#hei-asset-category--ingestion-api)
  - [Real Estate Valuation API](#real-estate-valuation-api-phase-2---provider-tbd)
  - [Vanta API](#vanta-api)
  - [AWS Services (Native Integration)](#aws-services-native-integration)

### 📋 API & Workflows
- [API Specification](#api-specification)
  - [REST API Specification](#rest-api-specification)
- [Components](#components)
  - [Frontend Components](#frontend-components)
  - [Backend Components](#backend-components)
  - [Shared Components](#shared-components)
- [Core Workflows](#core-workflows)

### 🚀 Development & Deployment
- [Unified Project Structure](#unified-project-structure)
- [Development Workflow](#development-workflow)
  - [Local Development Setup](#local-development-setup)
  - [Environment Configuration](#environment-configuration)
  - [Development Patterns](#development-patterns)
- [Deployment Architecture](#deployment-architecture)
  - [Deployment Strategy](#deployment-strategy)
  - [CI/CD Pipeline](#cicd-pipeline)
  - [Environments](#environments)
  - [Infrastructure as Code](#infrastructure-as-code)

### 💰 Cost & Performance
- [Cost Optimization Strategy](#cost-optimization-strategy)
  - [Progressive Infrastructure Scaling](#progressive-infrastructure-scaling)
  - [Cost Comparison: Traditional vs Optimized](#cost-comparison-traditional-vs-optimized)
  - [Key Cost Optimization Principles](#key-cost-optimization-principles)
  - [Break-Even Analysis](#break-even-analysis)
- [Security and Performance](#security-and-performance)
  - [Security Requirements](#security-requirements)
  - [Performance Optimization](#performance-optimization)
  - [Security Monitoring](#security-monitoring)

### 🧪 Testing & Quality
- [Testing Strategy](#testing-strategy)
  - [Testing Pyramid](#testing-pyramid)
  - [Test Organization](#test-organization)
  - [Test Configuration](#test-configuration)
  - [Test Examples](#test-examples)
  - [Test Data Management](#test-data-management)
  - [Continuous Integration Testing](#continuous-integration-testing)
- [Coding Standards](#coding-standards)
  - [Critical Fullstack Rules](#critical-fullstack-rules)
  - [Naming Conventions](#naming-conventions)
  - [File Organization Standards](#file-organization-standards)
  - [Code Quality Standards](#code-quality-standards)
  - [Documentation Standards (JSDoc)](#documentation-standards-jsdoc)
  - [Git Commit Standards](#git-commit-standards)
  - [Code Review Checklist](#code-review-checklist)

### 🚨 Error Handling & Monitoring
- [Error Handling Strategy](#error-handling-strategy)
  - [Error Flow](#error-flow)
  - [Error Response Format](#error-response-format)
  - [Error Codes and Categories](#error-codes-and-categories)
  - [Frontend Error Handling](#frontend-error-handling)
  - [Backend Error Handling](#backend-error-handling)
  - [Error Recovery Strategies](#error-recovery-strategies)
  - [Error Monitoring and Alerting](#error-monitoring-and-alerting)
- [Monitoring and Observability](#monitoring-and-observability)
  - [Monitoring Stack](#monitoring-stack)
  - [Key Metrics](#key-metrics)
  - [Distributed Tracing](#distributed-tracing)
  - [Logging Strategy](#logging-strategy)
  - [Alerting Rules](#alerting-rules)
  - [Custom Dashboards](#custom-dashboards)
  - [Health Checks](#health-checks)
  - [SLIs, SLOs, and SLAs](#slis-slos-and-slas)

### 📚 Quick Reference
- [Quick Reference Guide](#-quick-reference-guide)
  - [Essential Commands](#-essential-commands)
  - [Environment Variables Reference](#-environment-variables-reference)
  - [Architecture Patterns Quick Reference](#-architecture-patterns-quick-reference)
  - [Troubleshooting Guide](#-troubleshooting-guide)
  - [Decision Trees](#-decision-trees)

### 📋 Requirements Traceability
- [PRD Requirements Traceability Matrix](#-prd-requirements-traceability-matrix)
  - [Core Business Requirements Implementation](#core-business-requirements-implementation)
  - [Technical Requirements Implementation](#technical-requirements-implementation)
  - [Security & Compliance Requirements](#security--compliance-requirements)
  - [Performance & Scale Requirements](#performance--scale-requirements)
  - [Feature Coverage Matrix](#feature-coverage-matrix)

### 🌍 Additional Considerations
- [Translation System (Simple English/Spanish)](#translation-system-simple-englishspanish)
  - [Implementation Approach](#implementation-approach)
- [Internationalization (i18n) Strategy](#internationalization-i18n-strategy)
  - [Language Support](#language-support)
  - [Implementation Approach](#implementation-approach-1)
- [Accessibility (a11y) Requirements](#accessibility-a11y-requirements)
  - [WCAG 2.1 Level AA Compliance](#wcag-21-level-aa-compliance)
- [SEO Optimization for Public Pages](#seo-optimization-for-public-pages)
- [Analytics and Tracking Implementation](#analytics-and-tracking-implementation)
- [Backup and Disaster Recovery](#backup-and-disaster-recovery)
- [Data Retention Policies](#data-retention-policies)
- [GDPR/CCPA Compliance Measures](#gdprccpa-compliance-measures)
- [Vanta Integration for SOC 2 Compliance](#vanta-integration-for-soc-2-compliance)

### 🔮 Future Architecture
- [Microservices Architecture (Future Decomposition)](#microservices-architecture-future-decomposition)
  - [Overview](#overview-1)
  - [Service Boundaries](#service-boundaries)
  - [Inter-Service Communication](#inter-service-communication)
  - [Data Management Strategy](#data-management-strategy)
  - [Migration Strategy](#migration-strategy)
  - [Service Governance](#service-governance)
  - [Cost Optimization](#cost-optimization)

---

## Architecture Decision Records (ADRs)

This section documents key architectural decisions made for the Forward Inheritance Platform, providing context, alternatives considered, and rationale for choices.

### ADR-001: Nest.js over Express for Backend Framework

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need enterprise-grade Node.js backend framework

**Decision:** Use Nest.js instead of Express.js

**Rationale:**
- **Enterprise Structure**: Built-in dependency injection, modular architecture, and decorators
- **TypeScript First**: Native TypeScript support with compile-time safety
- **Scalability**: Guards, interceptors, and pipes provide clean separation of concerns
- **Testing**: Built-in testing utilities and mocking support
- **Maintainability**: Opinionated structure reduces decision fatigue

**Alternatives Considered:**
- **Express.js**: Too minimal, requires significant boilerplate for enterprise features
- **Fastify**: Better performance but less mature ecosystem
- **Koa.js**: Smaller but lacks built-in structure for large applications

**Consequences:**
- ✅ Faster development with built-in patterns
- ✅ Better code organization and testability  
- ✅ Strong ecosystem and community support
- ⚠️ Steeper learning curve for developers new to decorators
- ⚠️ Slightly higher memory overhead than Express

**Referenced In:** [Backend Architecture](#backend-architecture), [Nest.js Module Architecture](#nestjs-module-architecture)

---

### ADR-002: pgTyped + Slonik for Database Access

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need type-safe database operations with SQL flexibility

**Decision:** Use pgTyped for compile-time types + Slonik for runtime execution

**Rationale:**
- **Type Safety**: Compile-time validation prevents SQL/TypeScript mismatches
- **SQL Control**: Write raw SQL instead of ORM abstractions
- **Performance**: Direct SQL queries without ORM overhead
- **Version Control**: SQL files can be version controlled and code reviewed
- **Testing**: Individual queries can be unit tested

**Alternatives Considered:**
- **Prisma**: Good TypeScript support but limited SQL flexibility
- **TypeORM**: Heavy ORM overhead, complex migrations
- **Knex.js**: Query builder but no compile-time type safety
- **Raw pg**: No type safety, high boilerplate

**Consequences:**
- ✅ Maximum type safety with SQL flexibility
- ✅ Better performance than ORMs
- ✅ Clear separation of concerns
- ⚠️ Requires PostgreSQL-specific knowledge
- ⚠️ Setup complexity higher than simple ORMs

**Referenced In:** [Database Access Architecture](#database-access-architecture-pgtyped--slonik), [Tech Stack](#tech-stack)

---

### ADR-003: AWS Cognito for Authentication

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need enterprise authentication with compliance features

**Decision:** Use AWS Cognito with Authorization Code Grant + PKCE flow

**Rationale:**
- **Security**: Industry-standard OAuth 2.0 with PKCE for SPAs
- **Compliance**: Built-in SOC 2, GDPR compliance features
- **Scalability**: Managed service handles millions of users
- **Integration**: Native AWS ecosystem integration
- **Features**: MFA, password policies, user pools out of the box

**Alternatives Considered:**
- **Auth0**: Similar features but higher cost at scale
- **Firebase Auth**: Google ecosystem lock-in
- **Custom JWT**: High security implementation burden
- **Passport.js**: DIY approach with maintenance overhead

**Consequences:**
- ✅ Enterprise-grade security and compliance
- ✅ Reduced implementation and maintenance overhead
- ✅ Built-in MFA and advanced security features
- ⚠️ AWS vendor lock-in
- ⚠️ Less customization than custom solutions

**Referenced In:** [Authentication Architecture](#authentication-architecture-aws-cognito--api-gateway), [Security Best Practices](#security-best-practices)

---

### ADR-004: Progressive Caching Strategy (In-Memory First)

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need cost-effective caching for multi-tenant SaaS

**Decision:** Start with in-memory caching, progressively add Redis when needed

**Rationale:**
- **Cost Optimization**: In-memory caching costs $0 vs $200-500/month for Redis
- **Simplicity**: No additional infrastructure for MVP
- **Performance**: In-memory access is faster than network calls
- **Scalability Path**: Clear migration path to distributed caching

**Alternatives Considered:**
- **Redis from Day 1**: Higher cost, over-engineering for early stage
- **DynamoDB**: Higher latency, more complex
- **No caching**: Poor performance for frequently accessed data

**Consequences:**
- ✅ Significant cost savings during MVP phase
- ✅ Simpler deployment and monitoring
- ✅ Better performance for single-instance scenarios
- ⚠️ Requires sticky sessions for consistency
- ⚠️ Migration needed when scaling beyond single instance

**Referenced In:** [Progressive Caching Strategy](#progressive-caching-strategy-cost-optimized), [Cost Optimization Strategy](#cost-optimization-strategy)

---

### ADR-005: Monorepo with Nx

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need to manage fullstack TypeScript codebase efficiently

**Decision:** Use Nx monorepo with shared packages approach

**Rationale:**
- **Code Sharing**: Share types, utilities between frontend/backend
- **Build Optimization**: Advanced caching and dependency graphs
- **Developer Experience**: Single repo, unified tooling
- **Scaling**: Better than multi-repo for coordinated changes

**Alternatives Considered:**
- **Multi-repo**: Coordination overhead, dependency management complexity
- **Lerna**: Less advanced than Nx for TypeScript projects
- **Yarn Workspaces**: Basic monorepo, lacks advanced features
- **Rush**: Microsoft tool, less community adoption

**Consequences:**
- ✅ Improved developer productivity
- ✅ Better code sharing and consistency
- ✅ Advanced build optimization
- ⚠️ Learning curve for Nx-specific concepts
- ⚠️ Repo size grows larger than multi-repo

**Referenced In:** [Repository Structure](#repository-structure), [Unified Project Structure](#unified-project-structure)

---

### ADR-006: AWS Step Functions for Document Processing

**Status:** ✅ Accepted  
**Date:** 2025-08-01  
**Context:** Need reliable document processing with PII detection

**Decision:** Use AWS Step Functions to orchestrate document processing pipeline

**Rationale:**
- **Reliability**: Built-in retry, error handling, and state management
- **Scalability**: Serverless, handles variable document processing loads
- **Monitoring**: Native CloudWatch integration for observability
- **Compliance**: AWS services provide SOC 2 compliance foundation

**Alternatives Considered:**
- **Queue-based processing**: More complex error handling and state management
- **Synchronous processing**: Blocks user requests, poor UX
- **Custom orchestration**: High development and maintenance overhead

**Consequences:**
- ✅ Reliable document processing with automatic retries
- ✅ Serverless cost model - pay only for usage
- ✅ Built-in monitoring and error handling
- ⚠️ AWS vendor lock-in for workflow orchestration
- ⚠️ Learning curve for Step Functions state machine design

**Referenced In:** [AWS Step Functions Document Processing](#aws-step-functions-document-processing), [Tech Stack](#tech-stack)

---

## Introduction

This document outlines the complete fullstack architecture for Forward Inheritance Platform, including backend systems, frontend implementation, and their integration. It serves as the single source of truth for AI-driven development, ensuring consistency across the entire technology stack.

This unified approach combines what would traditionally be separate backend and frontend architecture documents, streamlining the development process for modern fullstack applications where these concerns are increasingly intertwined.

### Starter Template or Existing Project

Based on review of the PRD and existing documentation, this is a **Greenfield project** with no existing starter template mentioned. The project is being built from scratch with the following key constraints:

- Type-safe database architecture with pgTyped and Slonik (84% of stored procedures converted to SQL queries)
- PostgreSQL as the primary database (already designed with 72 tables)
- AWS cloud infrastructure preferred
- React frontend with TypeScript
- Nest.js backend (enterprise-grade Node.js framework)
- Multi-tenant SaaS architecture
- AWS Amplify used specifically for React CI/CD and hosting
- AWS Step Functions for document processing and PII workflows

## Phase 0: Local Development Architecture

### Overview

Phase 0 provides a minimal local development environment to validate the technical architecture before AWS deployment. This phase uses Docker containers to host the complete stack locally, enabling rapid development and testing.

### Technology Stack

**Frontend (Vite + React)**
- **Framework**: React with TypeScript
- **Build Tool**: Vite (fast development server)
- **Routing**: React Router
- **UI Styling**: Tailwind CSS
- **Component Library**: shadcn/ui
- **Port**: 3000

**Backend (NestJS)**
- **Framework**: NestJS with TypeScript
- **Database Access**: Slonik + pgTyped for type-safe SQL
- **Port**: 4000

**Database (PostgreSQL)**
- **Database**: PostgreSQL 15+
- **Port**: 15432 (to avoid conflicts with system PostgreSQL)
- **Schema**: Complete 72-table schema (already designed)
- **Data Access**: SQL-first approach with pgTyped type generation

**Local Storage**
- **File Storage**: Local filesystem for documents/images
- **Encryption**: Placeholder/mock encryption for development

### Docker Setup

```yaml
# docker-compose.yml (conceptual)
services:
  frontend:
    build: ./apps/web
    ports:
      - "3000:3000"
    depends_on:
      - backend
      
  backend:
    build: ./apps/api
    ports:
      - "4000:4000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/fwd_db
    depends_on:
      - db
      
  db:
    image: postgres:15
    ports:
      - "15432:5432"
    environment:
      - POSTGRES_DB=fwd_db
      - POSTGRES_PASSWORD=FGt!3reGTdt5BG!
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Phase 0 Project Creation & Setup

#### Step 1: NX Monorepo Initialization
```bash
# Create NX monorepo workspace
npx create-nx-workspace@latest fwd-inh --preset=empty --packageManager=npm
cd fwd-inh

# Install required NX plugins
npm install -D @nx/react @nx/node @nx/vite @nx/playwright @nx/docker
```

#### Step 2: Frontend Application (Vite + React)
```bash
# Generate React app with Vite
nx generate @nx/react:application frontend --bundler=vite --style=css --routing=true --unitTestRunner=vitest --e2eTestRunner=playwright

# Add TypeScript and required dependencies
npm install @types/react@^18.2.0 @types/react-dom@^18.2.0
npm install react-router-dom@^6.20.0 
npm install tailwindcss@^3.4.0 @tailwindcss/forms @tailwindcss/typography
npm install @radix-ui/react-* lucide-react class-variance-authority clsx tailwind-merge
npm install @tanstack/react-query axios @hookform/resolvers zod react-hook-form
npm install @builder.io/react @builder.io/sdk
```

#### Step 3: Backend Application (NestJS)
```bash
# Generate NestJS application
nx generate @nx/node:application api --framework=nestjs

# Add backend dependencies
npm install @nestjs/common @nestjs/core @nestjs/platform-express
npm install @nestjs/config @nestjs/jwt @nestjs/passport
npm install slonik @slonik/typegen @slonik/interceptor-preset
npm install pgtyped @pgtyped/cli @pgtyped/runtime
npm install bcrypt argon2 uuid class-validator class-transformer
npm install @aws-sdk/client-s3 @aws-sdk/client-cognito-identity-provider
npm install @aws-sdk/client-step-functions @aws-sdk/client-ses
```

#### Step 4: Database Layer (pgTyped + Slonik)
```bash
# Create database directories
mkdir -p apps/api/src/database/{queries,types,migrations}
mkdir -p apps/api/src/database/sql/{procedures,functions,views}

# Setup pgTyped configuration
echo '{
  "transforms": [
    {
      "mode": "sql",
      "include": "apps/api/src/database/queries/**/*.sql", 
      "emitTemplate": "apps/api/src/database/types/{{name}}.types.ts"
    }
  ]
}' > pgtyped.config.json
```

#### Step 5: Shared Package (Types & Utilities)
```bash
# Generate shared library
nx generate @nx/js:library shared --buildable=true

# Create shared type definitions
mkdir -p libs/shared/src/types/{assets,personas,ffc,auth}
mkdir -p libs/shared/src/utils/{validation,formatting,constants}
```

#### Step 6: Infrastructure as Code (Pulumi)
```bash
# Create infrastructure directory structure
mkdir -p infra/pulumi/{00-account-foundation,10-network-dev-open}
mkdir -p infra/pulumi/{20-data-dev,30-ecr-ecs-api,40-frontend-amplify}
mkdir -p infra/pulumi/{50-auth-cognito,55-api-gateway,60-queues-workers}
mkdir -p infra/pulumi/{70-cdn-cloudfront,80-monitoring-logging}
mkdir -p infra/docker/{frontend,backend,database}

# Install Pulumi dependencies
cd infra/pulumi
npm init -y
npm install @pulumi/pulumi @pulumi/aws @pulumi/awsx
npm install @pulumi/docker @pulumi/random @pulumi/tls
```

#### Step 7: Testing Setup (Playwright + Vitest)
```bash
# Setup Playwright for E2E testing
nx generate @nx/playwright:configuration --project=frontend-e2e

# Create testing directory structure
mkdir -p apps/frontend-e2e/src/{fixtures,page-objects,utils}
mkdir -p apps/api-e2e/src/{test-data,mocks,integration}

# Add testing dependencies
npm install -D @playwright/test @vitest/ui jsdom
npm install -D @testing-library/react @testing-library/jest-dom
npm install -D supertest @types/supertest
```

#### Step 8: Docker Configuration
```bash
# Create Docker configurations
mkdir -p infra/docker/{frontend,backend,database}

# Frontend Dockerfile
echo 'FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]' > infra/docker/frontend/Dockerfile

# Backend Dockerfile  
echo 'FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 4000
CMD ["npm", "run", "start:prod"]' > infra/docker/backend/Dockerfile
```

#### Step 9: Complete Directory Structure
```
fwd-inh/
├── apps/
│   ├── frontend/                    # React + Vite SPA
│   │   ├── src/
│   │   │   ├── components/          # Reusable UI components
│   │   │   │   ├── ui/              # shadcn/ui base components
│   │   │   │   ├── forms/           # Form components
│   │   │   │   ├── charts/          # Financial data visualization
│   │   │   │   └── cards/           # Asset & family cards
│   │   │   ├── features/            # Feature-based organization
│   │   │   │   ├── auth/            # Authentication flows
│   │   │   │   ├── assets/          # Asset management (14 categories)
│   │   │   │   ├── ffc/             # Family Circle features
│   │   │   │   ├── personas/        # Family member management
│   │   │   │   └── documents/       # Document management
│   │   │   ├── hooks/               # Custom React hooks
│   │   │   ├── services/            # API integration layer
│   │   │   ├── utils/               # Frontend utilities
│   │   │   └── types/               # Frontend-specific types
│   │   ├── public/                  # Static assets
│   │   └── e2e/                     # Playwright E2E tests
│   │
│   ├── api/                         # NestJS Backend
│   │   ├── src/
│   │   │   ├── modules/             # Feature modules
│   │   │   │   ├── auth/            # Authentication & authorization
│   │   │   │   ├── assets/          # Asset management (14 categories)
│   │   │   │   ├── ffc/             # Family Circle operations
│   │   │   │   ├── personas/        # Family member operations  
│   │   │   │   ├── documents/       # Document storage & retrieval
│   │   │   │   ├── builder/         # Builder.io integration
│   │   │   │   └── integrations/    # External API integrations
│   │   │   ├── database/            # Database layer
│   │   │   │   ├── queries/         # SQL queries (.sql files)
│   │   │   │   ├── types/           # pgTyped generated types
│   │   │   │   ├── migrations/      # Database migrations
│   │   │   │   └── client/          # Slonik connection setup
│   │   │   ├── common/              # Shared backend utilities
│   │   │   │   ├── guards/          # Auth & permission guards
│   │   │   │   ├── decorators/      # Custom decorators
│   │   │   │   ├── filters/         # Exception filters
│   │   │   │   └── interceptors/    # Request/response interceptors
│   │   │   └── config/              # Environment configuration
│   │   └── test/                    # Integration tests
│   │
│   └── frontend-e2e/                # E2E test application
│       └── src/
│           ├── fixtures/            # Test data fixtures
│           ├── page-objects/        # Page object models
│           └── specs/               # Test specifications
│
├── libs/                            # Shared libraries
│   └── shared/
│       ├── src/
│       │   ├── types/               # Shared TypeScript interfaces
│       │   │   ├── assets/          # Asset type definitions
│       │   │   ├── personas/        # Family member types
│       │   │   ├── ffc/             # Family Circle types
│       │   │   ├── auth/            # Authentication types
│       │   │   └── api/             # API request/response types
│       │   ├── utils/               # Shared utilities
│       │   │   ├── validation/      # Zod schemas
│       │   │   ├── formatting/      # Data formatting
│       │   │   └── constants/       # Shared constants
│       │   └── config/              # Shared configuration
│       └── README.md
│
├── infra/                           # Infrastructure as Code
│   ├── pulumi/                      # Pulumi infrastructure definitions
│   │   ├── 00-account-foundation/   # Root account setup, IAM roles
│   │   ├── 10-network-dev-open/     # VPC, subnets, security groups
│   │   ├── 20-data-dev/             # RDS PostgreSQL, S3 buckets
│   │   ├── 30-ecr-ecs-api/          # Container registry, ECS service
│   │   ├── 40-frontend-amplify/     # Amplify hosting, CloudFront
│   │   ├── 50-auth-cognito/         # Cognito user pools, identity
│   │   ├── 55-api-gateway/          # API Gateway, Lambda functions
│   │   ├── 60-queues-workers/       # SQS queues, Step Functions
│   │   ├── 70-cdn-cloudfront/       # CDN, static asset distribution
│   │   └── 80-monitoring-logging/   # CloudWatch, logging, alerts
│   │
│   └── docker/                      # Docker configurations
│       ├── frontend/                # Frontend container setup
│       ├── backend/                 # Backend container setup
│       └── database/                # Database container setup
│
├── tools/                           # Development tooling
│   ├── scripts/                     # Build & deployment scripts
│   └── generators/                  # NX generators for consistency
│
├── docs/                            # Project documentation
│   ├── architecture.md              # This document
│   ├── prd.md                       # Product requirements
│   ├── front-end-spec.md            # UI/UX specifications
│   └── requirements/                # Detailed requirements
│
├── .github/                         # GitHub configurations
│   └── workflows/                   # CI/CD pipelines
│
├── nx.json                          # NX workspace configuration
├── package.json                     # Root package configuration
├── tsconfig.base.json              # Base TypeScript configuration
├── pgtyped.config.json             # pgTyped configuration
├── docker-compose.yml              # Local development stack
├── tailwind.config.js              # Tailwind CSS configuration
└── README.md                       # Project setup instructions
```

### Development Workflow

1. **Project Initialization**: Complete NX monorepo setup with all directory structures
2. **Database Setup**: Run SQL schema scripts to create 72 tables and functions  
3. **Type Generation**: pgTyped generates TypeScript types from SQL files
4. **Container Setup**: Docker Compose orchestrates local development stack
5. **Backend Start**: NestJS server with Slonik database client
6. **Frontend Start**: Vite dev server with React and hot module replacement
7. **Testing**: Playwright E2E tests and Vitest unit tests
8. **Local Development**: Full stack runs locally with live reload

### Key Differences from Production

- **Authentication**: Complete 2FA flow UI/UX with stubbed backend services
  - **Email Verification**: Full UI flow, stubbed email sending (returns "OK")
  - **SMS 2FA**: Full UI flow, stubbed SMS sending (returns "OK") 
  - **Authorization Logic**: Stubbed functions return "OK" (no actual validation)
  - **JWT Tokens**: Complete token generation and validation
  - **Session Management**: Full httpOnly cookie implementation
  - **Advantage**: Phase 1A only needs external service integrations
- **File Storage**: Local filesystem (no AWS S3)
- **Integrations**: Mock/placeholder integrations (Quiltt, Twilio, Zillow)
- **Encryption**: Development-only encryption keys
- **Infrastructure**: Docker containers (no AWS ECS/Fargate)

### Migration Path to Phase 1A

Phase 0 validates the core architecture patterns that will be deployed to AWS in Phase 1A:
- Same database schema and queries
- Same NestJS backend structure
- Same React frontend components
- Same pgTyped + Slonik data access patterns

### Phase 0 Migration Path to Production Authentication

**Migration Strategy**
1. **Infrastructure Setup**: Deploy AWS Cognito, configure Twilio, configure SendGrid
2. **Replace Email Stubs**: Fill in `sendEmailVerification()` and `verifyEmailCode()` with SendGrid
3. **Replace SMS Stubs**: Fill in `sendSMSVerification()` and `verifySMSCode()` with Twilio
4. **Replace Auth Stubs**: Fill in `validateCredentials()` and `checkPermissions()` with AWS Cognito
5. **Keep Everything Else**: All UI flows, database integration, and API structure remain unchanged

**Phase 0 Implementation Notes**
- Complete user registration flow with database persistence
- Full email/phone verification tracking in database
- Session management with database storage
- Audit logging for all authentication events
- All frontend authentication UI flows fully implemented

See [🔐 Authentication Architecture](#🔐-authentication-architecture-phased-implementation) for complete implementation details.

## AWS Infrastructure Build-Out Plan (Pulumi-Based)

### Overview

The platform follows a lean-first, phase-by-phase infrastructure build that maintains development velocity while progressively adding security and operational capabilities. This approach maps directly to the technology decisions documented in this architecture (Cognito + httpOnly cookies, ECS/Fargate, RDS PostgreSQL, S3, SQS, Step Functions, Amplify/CloudFront).

### Infrastructure Components

**Account & Organization (Baseline)**
- IAM OIDC role for GitHub Actions deploys
- Least-privilege roles for CI, ECS tasks, Step Functions, and data access

**Networking (Per Environment)**
- VPC with 3 AZs, private subnets (app/db) and public subnets (egress only)
- Internet Gateway, NAT Gateways, route tables
- VPC endpoints for S3, ECR, CloudWatch Logs, Secrets Manager, SSM, KMS, STS

**Security**
- KMS CMKs for RDS/S3/secrets
- WAF on API Gateway and CloudFront
- Secrets Manager for database/auth/3rd-party API secrets
- CloudTrail + CloudWatch metrics/alarms

**Data & Storage**
- RDS PostgreSQL Multi-AZ with subnet groups and parameter groups
- S3 buckets: docs-original, docs-processed, website-static (versioning + KMS + lifecycle)
- In-memory cache in NestJS; Redis/Upstash when scale requires (matches ADR-004)

**Compute & Containers**
- ECR repositories (api, worker)
- ECS (Fargate) cluster with task definitions for API/worker/migrations
- Internal ALB for REST APIs
- WebSocket support via API Gateway WebSocket API or ALB pass-through

**API & Authentication**
- API Gateway HTTP API with VPC Link to internal ALB
- Usage plans/quotas, WAF, custom domain + ACM
- Cognito User Pool & Hosted UI
- Pre-Token-Generation Lambda for tenant claims

**Async & Workflows**
- SQS (main + DLQ) for app tasks & Stripe webhooks
- Step Functions state machine for Textract/Comprehend/Lambda document processing

**Observability**
- CloudWatch log groups with retention, dashboards, alarms
- Sentry for application error tracking

**Frontend**
- Amplify app connected to GitHub for React SPA builds
- CloudFront distribution with Origin Access Control (OAC)

### Phased Deployment Strategy

#### **Phase 0: Local Development** (Current)
**Goal**: Validate architecture with Docker containers locally
- Complete application development with stubbed external services
- Database schema validation and pgTyped integration
- UI/UX flows for authentication and core features

#### **Phase 1: Account Foundation**
**Goal**: Safe root access, developer access, billing safety
```bash
# Pulumi Module: 00-account-foundation
```
- Root MFA and break-glass user setup
- Development account with AWS Budgets + alerts
- CloudTrail (single trail, all regions) → S3
- DeployRole for CI/CD (GitHub OIDC-ready)
- DeveloperRole with console access

#### **Phase 2: Open Development Networking**
**Goal**: Get containers/DB reachable quickly, keep simple
```bash
# Pulumi Module: 10-network-dev-open
```
- Single VPC with two public subnets (2 AZs)
- No NAT Gateways initially (cost savings)
- Security Groups: ALB (80/443 from 0.0.0.0/0), ECS (3000 from ALB), DB (5432 from ECS)
- Public ALB as temporary development front door

**Pulumi Configuration**:
```typescript
// config.ts
export const isProd = pulumi.getStack() === "prod";
export const openDev = !isProd;       // public ALB, tasks with public IPs
export const natCount = isProd ? 2 : 0;
```

#### **Phase 3: Minimum Application Stack**
**Goal**: Ship the app end-to-end with fewest moving parts
```bash
# Pulumi Modules: 20-data-dev, 30-ecr-ecs-api, 40-frontend-amplify
```
- ECR repository for NestJS API image
- RDS PostgreSQL (single-AZ, t4g.small, default KMS)
- S3 buckets: app-docs-original, app-docs-processed (versioning enabled)
- ECS/Fargate cluster with API service (2 tasks) behind public ALB
- Amplify deployment for React SPA

**Smoke Tests**:
- `curl ALB /healthz → 200`
- Database migrations via one-off Fargate task
- SPA renders and API calls succeed

#### **Phase 4: Authentication & API Gateway**
**Goal**: Implement Cognito + Authorization Code with PKCE, httpOnly cookies
```bash
# Pulumi Modules: 50-auth-cognito, 55-api-gateway
```
- Cognito User Pool + Hosted UI (scopes: openid, email, profile)
- Pre-Token-Generation Lambda for tenant/role claims
- API Gateway HTTP API routing /auth/* and /api/* to backend
- HttpOnly cookie management, JWT tokens stay out of JavaScript

**Smoke Tests**:
- Login via Cognito → callback → cookies set (not visible to JS)
- Token refresh flow succeeds transparently

#### **Phase 5: Storage & Async Primitives**
**Goal**: Enable uploads and background work
```bash
# Pulumi Module: 60-queues-workers
```
- S3 integration for original + processed document storage
- SQS (main + DLQ) for Stripe webhooks, notifications
- Worker ECS service reading SQS queues
- In-memory caching (no Redis yet, per ADR-004)

**Smoke Tests**:
- Upload document → appears in original bucket
- Test job enqueued → worker consumes
- DLQ receives poison messages

#### **Phase 6: Document Processing Pipeline**
**Goal**: Fulfill PII masking flow
```bash
# Pulumi Module: 70-step-functions-doc-pipeline
```
- Step Functions state machine: Validate → Textract → Comprehend PII → Mask → Write copies → Update DB → Notify
- S3 event trigger on original bucket upload
- Lambda functions for processing steps (small memory, short timeouts)

**Smoke Tests**:
- Upload PDF → masked copy in processed bucket
- Database updated with processing status
- Application displays masked version

#### **Phase 7: Network Hardening**
**Goal**: Secure network now that development velocity is established
```bash
# Pulumi Module: 80-network-harden
```
- Migrate ECS tasks to private subnets (no public IP)
- Add 1 NAT Gateway for VPC (dev cost optimization)
- Move ALB to internal, connect API Gateway via VPC Link
- Add VPC Endpoints: S3, ECR, CloudWatch Logs, Secrets Manager, SSM, KMS
- Attach WAF to API Gateway (rate limiting, SQL injection, XSS protection)

**Smoke Tests**:
- External access only via API Gateway (ALB not public)
- WAF blocks test attack signatures
- Application functionality maintained

#### **Phase 8: Global Delivery**
**Goal**: Production-grade static asset and API delivery
```bash
# Pulumi Module: 90-cloudfront
```
- CloudFront distribution in front of Amplify SPA
- Optional CloudFront in front of API Gateway for global edge latency
- Long-TTL caching for static assets, no-cache for APIs

#### **Phase 9: Observability & CI/CD**
**Goal**: Production monitoring and deployment automation
```bash
# Pulumi Modules: 95-observability, 99-cicd
```
- CloudWatch Logs/Dashboards/Alarms:
  - API 4xx/5xx rates and P95 latency
  - ECS CPU/Memory utilization
  - RDS CPU/connections
  - SQS queue depth
  - Step Functions failures
- Sentry integration for frontend and backend error tracking
- GitHub Actions CI/CD:
  - Build & push Docker images
  - `pulumi up` for development
  - Manual approvals for staging/production

### Cost Optimization Reference

See [💰 Cost Optimization Strategy](#cost-optimization-strategy) for comprehensive cost optimization including environment-specific strategies, progressive scaling, and break-even analysis.

### Repository Structure

```
/
├── apps/
│   ├── frontend/          # React SPA
│   └── api/              # NestJS backend
├── packages/
│   └── shared/           # Shared TypeScript types
└── infra/
    └── pulumi/           # Infrastructure as Code
        ├── 00-account-foundation/
        ├── 10-network-dev-open/
        ├── 20-data-dev/
        ├── 30-ecr-ecs-api/
        ├── 40-frontend-amplify/
        ├── 50-auth-cognito/
        ├── 55-api-gateway/
        ├── 60-queues-workers/
        ├── 70-step-functions-doc-pipeline/
        ├── 80-network-harden/
        ├── 90-cloudfront/
        ├── 95-observability/
        └── 99-cicd/
```

## Phase-by-Phase Integration Migration Strategy

This section documents the comprehensive migration strategy from Phase 0 local development through full AWS production deployment, ensuring minimal disruption and systematic validation at each stage.

### Migration Overview

The Forward Inheritance Platform follows a **risk-minimized, incrementally-validated migration approach** that enables continuous development velocity while systematically replacing stubbed components with production implementations.

#### Migration Principles

1. **Backward Compatibility**: Each phase maintains full compatibility with previous phases
2. **Zero-Downtime Transitions**: Live system remains operational during all migrations
3. **Incremental Validation**: Each component is validated independently before proceeding
4. **Rollback Capability**: Every phase includes rollback procedures for critical failures
5. **Feature Flag Control**: New integrations controlled via feature flags for safe deployment

### Detailed Phase Migration Strategy

#### Phase 0 → Phase 1A: AWS Infrastructure Foundation

**Migration Scope**: Local Docker → AWS Cloud Infrastructure
**Timeline**: Days 15-74 (60 days)
**Risk Level**: Medium (infrastructure change)

```typescript
// Migration checklist and validation
interface Phase1AMigration {
  infrastructureMigration: {
    awsAccount: 'Setup with security foundation',
    networking: 'VPC with public subnets (cost-optimized)',
    compute: 'ECS/Fargate cluster deployment',
    database: 'RDS PostgreSQL migration from local',
    storage: 'S3 bucket creation and file migration',
    monitoring: 'Basic CloudWatch logging'
  },
  
  applicationMigration: {
    containerization: 'Docker images to ECR',
    configuration: 'Environment variable migration',
    secrets: 'AWS Secrets Manager integration',
    healthChecks: 'ALB health check endpoints',
    dataValidation: 'Database consistency verification'
  },
  
  validationGates: {
    functional: 'All Phase 0 functionality working on AWS',
    performance: 'Response times within 2x of local',
    security: 'TLS termination and basic security groups',
    cost: 'Monthly cost under $200 for development workload'
  }
}
```

#### Phase 1A → Phase 1B: Authentication & External Services

**Migration Scope**: Stubbed Auth → Production AWS Cognito + API Gateway
**Timeline**: Days 75-134 (60 days)  
**Risk Level**: High (authentication change affects all users)

```typescript
interface Phase1BMigration {
  authenticationMigration: {
    cognitoSetup: 'User pool creation and configuration',
    apiGatewayIntegration: 'HTTP API with VPC Link to ALB',
    jwtAuthorization: 'Token validation and refresh flows',
    sessionMigration: 'Migrate existing stub sessions to Cognito',
    backupAuth: 'Maintain stub auth as fallback during migration'
  },
  
  migrationSteps: [
    {
      step: 1,
      action: 'Deploy Cognito infrastructure alongside existing auth',
      validation: 'New user registration works with Cognito',
      rollback: 'Disable Cognito, continue with stub auth'
    },
    {
      step: 2, 
      action: 'Migrate existing users to Cognito user pool',
      validation: 'All existing users can log in with new system',
      rollback: 'Restore user data from backup, use stub auth'
    },
    {
      step: 3,
      action: 'Switch production traffic to Cognito authentication',
      validation: 'All authentication flows working, performance acceptable',
      rollback: 'Feature flag to revert to stub authentication'
    },
    {
      step: 4,
      action: 'Remove stub authentication code and dependencies',
      validation: 'Clean production system with only Cognito auth',
      rollback: 'Redeploy previous version with stub auth'
    }
  ],
  
  featureFlags: {
    'auth.useStubs': 'Control between stub and Cognito authentication',
    'auth.migrationMode': 'Enable dual authentication during transition',
    'auth.requireVerification': 'Control email/SMS verification requirements'
  }
}
```

#### Phase 1B → Phase 1C: External Integration Migration

**Migration Scope**: Stubbed Services → Production Integrations (Twilio, Quiltt, Zillow, Spanish)
**Timeline**: Days 135-164 (30 days)
**Risk Level**: Medium (external dependencies)

```typescript
interface Phase1CMigration {
  integrationMigration: {
    twilioIntegration: {
      timeline: 'Week 1',
      scope: 'SMS verification replacement',
      validation: 'Real SMS delivery and verification',
      fallback: 'Stub SMS with admin override capability'
    },
    
    quilttIntegration: {
      timeline: 'Weeks 2-3', 
      scope: 'Financial account aggregation',
      validation: 'Bank account connectivity and balance sync',
      fallback: 'Manual asset entry with Quiltt disabled'
    },
    
    zillowIntegration: {
      timeline: 'Week 4',
      scope: 'Real estate valuation data',
      validation: 'Property value estimates and market data',
      fallback: 'Manual property valuation entry'
    },
    
    spanishLocalization: {
      timeline: 'Week 5',
      scope: 'Spanish language support',
      validation: 'Complete UI translation and email templates',
      fallback: 'English-only with graceful language switching'
    }
  },
  
  migrationPattern: {
    preparation: [
      'Create integration service stubs alongside existing stubs',
      'Implement feature flags for each integration',
      'Add comprehensive error handling and fallback logic',
      'Create integration health check endpoints'
    ],
    
    deployment: [
      'Deploy integration code with feature flags disabled',
      'Validate integration connectivity in staging environment',
      'Enable feature flag for subset of users (beta testing)',
      'Monitor performance and error rates',
      'Gradually increase traffic to new integration',
      'Switch 100% traffic once validation complete'
    ],
    
    validation: [
      'Integration health checks passing',
      'Error rates below 1% for integration calls',
      'Performance impact negligible on core flows',
      'Fallback mechanisms tested and working',
      'User experience equivalent or improved'
    ]
  }
}
```

### Migration Infrastructure & Tooling

#### Feature Flag Management

```typescript
// Integration feature flag service
class FeatureFlagService {
  async isEnabled(flag: string, userId?: string, ffcId?: string): Promise<boolean> {
    // Hierarchical flag evaluation: user > ffc > tenant > global
    const userFlag = userId ? await this.getUserFlag(flag, userId) : null;
    const ffcFlag = ffcId ? await this.getFFCFlag(flag, ffcId) : null;
    const globalFlag = await this.getGlobalFlag(flag);
    
    return userFlag ?? ffcFlag ?? globalFlag ?? false;
  }
  
  // Integration-specific flags
  async shouldUseTwilio(userId: string): Promise<boolean> {
    return this.isEnabled('integrations.twilio.enabled', userId);
  }
  
  async shouldUseQuiltt(userId: string): Promise<boolean> {
    return this.isEnabled('integrations.quiltt.enabled', userId);
  }
}
```

#### Migration Health Monitoring

```typescript
// Migration health monitoring service
class MigrationHealthService {
  async checkMigrationHealth(): Promise<MigrationHealthReport> {
    return {
      authenticationHealth: await this.checkAuthenticationMigration(),
      integrationHealth: await this.checkIntegrationMigration(),
      performanceHealth: await this.checkPerformanceImpact(),
      errorRates: await this.checkErrorRates(),
      recommendedActions: await this.generateRecommendations()
    };
  }
  
  private async checkAuthenticationMigration(): Promise<AuthMigrationHealth> {
    const cognitoSuccess = await this.testCognitoAuth();
    const stubFallbackWorking = await this.testStubAuth();
    const userMigrationProgress = await this.getUserMigrationProgress();
    
    return {
      cognitoHealthy: cognitoSuccess,
      fallbackAvailable: stubFallbackWorking,
      migrationProgress: userMigrationProgress,
      recommendation: this.getAuthRecommendation(cognitoSuccess, stubFallbackWorking)
    };
  }
}
```

#### Rollback Procedures

```typescript
interface RollbackProcedures {
  authenticationRollback: {
    trigger: 'Cognito failure rate > 5% OR user complaints > 10',
    procedure: [
      'Enable feature flag auth.useStubs = true',
      'Verify stub authentication working',
      'Monitor user login success rates',
      'Investigate Cognito issues offline',
      'Plan re-migration once issues resolved'
    ],
    timeToRollback: '< 5 minutes',
    validationSteps: [
      'User login success rate > 95%',
      'No authentication-related error reports',
      'All core application functionality accessible'
    ]
  },
  
  integrationRollback: {
    trigger: 'Integration failure rate > 10% OR performance degradation > 50%',
    procedure: [
      'Disable problematic integration via feature flag',
      'Verify fallback/stub integration working',
      'Monitor application performance recovery',
      'Debug integration issues in staging environment',
      'Plan re-deployment with fixes'
    ],
    timeToRollback: '< 2 minutes per integration',
    validationSteps: [
      'Application functionality equivalent to pre-integration',
      'Performance back to baseline levels',
      'Error rates below normal thresholds'
    ]
  }
}
```

### Success Metrics & Validation Gates

#### Phase Migration Success Criteria

```typescript
interface MigrationSuccessCriteria {
  functionalRequirements: {
    featureParity: '100% of Phase 0 functionality working',
    userExperience: 'No degradation in user workflows',
    dataIntegrity: 'Zero data loss during migration',
    securityCompliance: 'All security requirements maintained'
  },
  
  performanceRequirements: {
    responseTime: 'API response times within 150% of baseline',
    availability: 'System uptime > 99.5% during migration',
    errorRate: 'Error rates < 1% for core functionality',
    throughput: 'System handles expected user load'
  },
  
  operationalRequirements: {
    monitoring: 'All critical metrics being tracked',
    alerting: 'Alert systems functional and tuned',
    logging: 'Complete audit trail of migration activities',
    documentation: 'All changes documented and validated'
  }
}
```

This comprehensive migration strategy ensures the Forward Inheritance Platform can evolve from local development through full production deployment while maintaining system reliability, user experience, and development velocity throughout the transformation process.

## Epic 7: Performance Optimization & Advanced Caching

> **🚀 Performance Goal**: Optimize React application performance, implement advanced caching strategies, and ensure scalable database operations for family wealth management at scale.

### Overview

Epic 7 focuses on performance optimization across the entire stack to support thousands of families managing complex asset portfolios. This includes React performance optimization, advanced caching implementation, database query optimization, CDN configuration, and comprehensive performance monitoring.

### React Performance Optimization

#### Component Performance Strategies

**TBD**: React.memo implementation patterns
**TBD**: useMemo and useCallback optimization strategies  
**TBD**: Virtual scrolling for large asset lists
**TBD**: Code splitting and lazy loading implementation
**TBD**: Bundle size optimization techniques

```typescript
// TBD: Example React performance patterns
// - Memoized components for asset lists
// - Optimized re-rendering strategies
// - Performance profiling implementation
```

#### State Management Optimization

**TBD**: Zustand store optimization patterns
**TBD**: Selective state subscriptions
**TBD**: State normalization strategies
**TBD**: Optimistic updates implementation

### Advanced Caching Implementation

#### Multi-Level Caching Strategy

**TBD**: In-memory caching with Redis migration path
**TBD**: Browser caching strategies  
**TBD**: API response caching patterns
**TBD**: Database query result caching

```typescript
// TBD: Caching service implementation
// - Redis integration for multi-instance deployments
// - Cache invalidation strategies
// - Cache warming procedures
```

#### CDN and Asset Optimization

**TBD**: CloudFront configuration for optimal performance
**TBD**: Static asset optimization
**TBD**: Image optimization and lazy loading
**TBD**: Font loading optimization

### Database Query Optimization

#### Query Performance Strategies

**TBD**: Database index optimization
**TBD**: Query execution plan analysis
**TBD**: Stored procedure performance tuning
**TBD**: Connection pooling optimization

```sql
-- TBD: Optimized database queries
-- - Asset retrieval with pagination
-- - Complex family relationship queries
-- - Financial data aggregation optimization
```

#### Data Access Patterns

**TBD**: Efficient data loading strategies
**TBD**: Bulk operation optimization
**TBD**: Read replica implementation
**TBD**: Database partitioning strategies

### Performance Monitoring

#### Metrics and Observability

**TBD**: Performance metric collection
**TBD**: Real User Monitoring (RUM) implementation
**TBD**: Core Web Vitals tracking
**TBD**: API performance monitoring

```typescript
// TBD: Performance monitoring service
// - Page load time tracking
// - API response time monitoring  
// - Error rate tracking
// - User experience metrics
```

#### Performance Dashboards

**TBD**: CloudWatch dashboard configuration
**TBD**: Sentry performance monitoring
**TBD**: Custom performance analytics
**TBD**: Performance alerting strategies

### Implementation Timeline

**Phase 1**: React component optimization and code splitting
**Phase 2**: Advanced caching layer implementation
**Phase 3**: Database query optimization and indexing
**Phase 4**: CDN configuration and asset optimization
**Phase 5**: Performance monitoring and alerting setup

### Success Metrics

- **Page Load Time**: < 2 seconds for dashboard
- **API Response Time**: < 500ms for asset queries
- **Bundle Size**: < 1MB total JavaScript
- **Core Web Vitals**: Green scores across all metrics
- **Database Query Time**: < 100ms for complex asset queries

*Note: This section contains placeholder content (TBD) for future implementation. Detailed specifications will be developed during Epic 7 planning phase.*

## High Level Architecture

### Technical Summary

#### Core Architecture
The Forward Inheritance Platform employs a **multi-tenant SaaS architecture** with:
- **Frontend**: React/TypeScript deployed via AWS Amplify for streamlined CI/CD
- **Backend**: Nest.js running on containerized AWS infrastructure (Fargate/ECS)
- **Communication**: RESTful APIs with real-time WebSocket support
- **Architecture Pattern**: Modular design with dependency injection, guards for multi-tenant isolation, and interceptors for cross-cutting concerns

#### Database Strategy
- **Type Safety**: pgTyped for compile-time SQL type safety + Slonik for runtime execution
- **Query Optimization**: 84% of stored procedures converted to individual SQL queries (99 files)
- **Database**: PostgreSQL with comprehensive schema design (72+ tables)

#### Authentication & Security
- **Authentication**: AWS Cognito with secure httpOnly cookies
- **Flow**: Authorization Code Grant with PKCE through API Gateway
- **Isolation**: Multi-tenant data segregation at database level

#### Payment & Subscription System
- **Payment Provider**: Stripe integration with webhook processing
- **Plan Types**: Free plans (automatic assignment), paid subscriptions with seat management, one-time services
- **Architecture**: Queue-based processing for reliability and idempotency

#### Document Processing Pipeline
- **Orchestration**: AWS Step Functions for serverless document workflows
- **PII Protection**: S3 + Lambda + Comprehend for automatic detection and masking
- **Storage**: Dual storage strategy (original + masked versions)

#### Async Processing
- **Queue System**: AWS SQS for application-level async tasks
- **Use Cases**: Stripe webhook processing, notifications, background operations

#### External Integrations
- **Payments**: Stripe for all payment processing
- **Communications**: Twilio (SMS), SendGrid (email)
- **Financial Data**: Quiltt API for bank account aggregation
- **Compliance**: Vanta for SOC 2 compliance automation

##### Integration Implementation Priority (Phase 1C)
Based on PRD requirements, external integrations follow this implementation order:

1. **Twilio SMS 2FA Integration** (Epic 2: Story 2.4, Week 1)
   - **Purpose**: Replace stubbed SMS verification with production Twilio integration
   - **Scope**: Full dual-channel authentication (email + SMS)
   - **Dependencies**: AWS Cognito authentication foundation from Phase 1A

2. **Quiltt API Integration** (Epic 4: Story 4.8, Weeks 2-3)
   - **Purpose**: Financial account aggregation and balance synchronization
   - **Scope**: Bank account connectivity, transaction sync, balance updates
   - **Dependencies**: Asset management infrastructure from Phase 1B

3. **Zillow API Integration** (Epic 4: Story 4.9, Week 4)
   - **Purpose**: Real estate asset valuation and market data
   - **Scope**: Property value estimation, market trend analysis
   - **Dependencies**: Real estate asset category implementation

4. **Spanish Language Foundation** (Epic 5: Story 5.1, Week 5)
   - **Purpose**: Native Spanish language support for US market expansion
   - **Scope**: UI translation, localized email templates, cultural adaptations
   - **Dependencies**: Translation system architecture foundation

#### Scale & Performance
This architecture achieves **enterprise-grade security**, **scalability for millions of families**, and **maintainable code** through Nest.js's structured approach with clear separation of concerns.

### Platform and Infrastructure Choice

**Platform:** AWS Cloud Services  
**Key Services:** 
- **AWS Amplify:** React SPA hosting, CI/CD pipeline, authentication flow orchestration
- **API Gateway:** Auth routes proxy, API rate limiting, CORS handling
- **Fargate/ECS:** NestJS backend containers
- **RDS PostgreSQL:** Primary database (70+ tables)
- **S3:** Document storage
- **Lambda:** PII processing, async operations
- **CloudFront:** CDN for static assets
- **KMS:** Encryption key management
**Deployment Host and Regions:** Primary: US-West-1, with CloudFront edge locations US wide

### Repository Structure

**Structure:** Monorepo  
**Monorepo Tool:** Nx (enterprise-grade monorepo management)  
**Package Organization:** 
- `/apps` - Frontend (React) and Backend (Node.js) applications
- `/packages` - Shared types, utilities, and database interfaces
- `/infrastructure` - Pulumi definitions

**Why Nx over alternatives:**
- Advanced dependency graph visualization
- Superior caching strategies
- Robust plugin ecosystem
- Better build optimization for enterprise needs

### High Level Architecture Diagram

```mermaid
graph TB
    subgraph "Users"
        U[Users/Families]
        M[Marketing Team]
    end
    
    subgraph "CDN Layer"
        CF[CloudFront CDN]
        B[Builder.io CMS]
    end
    
    subgraph "Frontend"
        AMP[AWS Amplify<br/>React App]
    end
    
    subgraph "API Layer"
        AG[API Gateway<br/>Rate Limiting<br/>API Keys]
        WAF[AWS WAF<br/>DDoS Protection]
        USAGE[Usage Plans<br/>Quotas]
    end
    
    subgraph "Backend Services"
        ECS[Fargate/ECS<br/>Nest.js]
        SF[Step Functions<br/>Document Pipeline]
        L1[Lambda<br/>PII Processing]
        L2[Lambda<br/>Report Generation]
        SQS[AWS SQS<br/>App Tasks]
    end
    
    subgraph "Data Layer"
        RDS[(RDS PostgreSQL<br/>72 Tables<br/>69 Stored Procedures)]
        S3[S3 Storage<br/>Documents]
        MEM[In-Memory Cache<br/>NestJS Service]
    end
    
    subgraph "External Services"
        ST[Stripe Payments]
        TW[Twilio SMS]
        SG[SendGrid Email]
        Q[Quiltt API]
        RE[Real Estate API]
    end
    
    U --> CF --> AMP
    M --> B --> CF
    AMP --> AG
    AG --> USAGE
    AG --> WAF --> ECS
    ECS --> RDS
    ECS --> MEM
    MEM --> RDS
    ECS --> SF
    SF --> L1
    SF --> S3
    ECS --> SQS
    L1 --> S3
    L2 --> S3
    ECS --> ST
    ECS --> TW
    ECS --> SG
    ECS --> Q
    ECS --> RE
    ST -.->|webhooks| SQS
    
    style MEM fill:#f9f,stroke:#333,stroke-width:2px
```

### Architectural Patterns

- **Type-Safe Database Operations:** pgTyped for compile-time SQL validation, Slonik for runtime execution with 99 SQL query files - _Rationale:_ Prevents SQL injection through parameterization, compile-time type safety, better version control and testing of individual queries  
  → _See: [Database Access Architecture](#database-access-architecture-pgtyped--slonik)_

- **Modular Architecture with Nest.js:** Domain-driven modules with dependency injection, guards, and interceptors - _Rationale:_ Enterprise-grade structure, testability, and clear separation of concerns  
  → _See: [Nest.js Module Architecture](#nestjs-module-architecture)_

- **Business Logic in Application Layer:** Nest.js services handle all business rules, validations, and orchestration - _Rationale:_ Keeps business logic testable, maintainable, and independent of database implementation  
  → _See: [Backend Architecture](#backend-architecture)_

- **Multi-Tenant Isolation:** Tenant ID-based data segregation at database level - _Rationale:_ Complete data isolation for different white lable B2B partners, while maintaining single codebase  
  → _See: [Authentication and Authorization Guards](#authentication-and-authorization-guards)_

- **Component-Based UI:** Reusable React components with TypeScript and shadcn/ui - _Rationale:_ Consistency across UI, type safety, and faster development  
  → _See: [Frontend Architecture](#frontend-architecture), [Component Patterns](#component-patterns)_

- **Repository Pattern:** Abstract database access through typed stored procedure calls - _Rationale:_ Type-safe database operations with pgtyped, easier testing  
  → _See: [Database Architecture with Nest.js](#database-architecture-with-nestjs)_

- **API Gateway Pattern:** Centralized entry point for all backend services - _Rationale:_ Unified authentication, rate limiting, and monitoring  
  → _See: [API Gateway Pattern Implementation](#api-gateway-pattern-implementation)_

- **Event-Driven Processing:** Lambda functions for async operations like PII masking - _Rationale:_ Scalable processing without blocking main application flow  
  → _See: [AWS Step Functions Document Processing](#aws-step-functions-document-processing)_

- **Dual-Identity System:** Separate users (authentication) from personas (business entities) - _Rationale:_ Enables complex family relationships and proxy management  
  → _See: [Data Models](#data-models), [Core Entities](#core-entities)_

- **Subscription-First Architecture:** Automatic free plan assignment on FFC creation - _Rationale:_ Zero payment barrier for users, seamless upgrade path  
  → _See: [Subscription & Payment Entities](#subscription--payment-entities)_

- **Asynchronous Payment Processing:** Webhook-based Stripe integration via queues - _Rationale:_ Reliability, idempotency, and system resilience  
  → _See: [Queue Processing with AWS SQS](#queue-processing-with-aws-sqs)_

- **Dynamic UI Configuration:** Plan-based UI visibility stored in database - _Rationale:_ Flexibility without code changes, A/B testing capability  
  → _See: [State Management Architecture](#state-management-architecture)_

## 🔧 Tech Stack

> **⚠️ DEFINITIVE SELECTION**: This is the official technology selection for the entire Forward Inheritance Platform. All development must use these exact versions.

**Related ADRs:** [ADR-001: Nest.js](#adr-001-nestjs-over-express-for-backend-framework) | [ADR-002: pgTyped + Slonik](#adr-002-pgtyped--slonik-for-database-access) | [ADR-005: Monorepo](#adr-005-monorepo-with-nx)

### Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| Frontend Language | TypeScript | 5.3+ | Type-safe development | Prevents runtime errors, better IDE support, enforces data contracts |
| Frontend Framework | React | 18.2+ | UI framework | Mature ecosystem, component reusability, strong community |
| Frontend Routing | React Router | 6.20+ | Client-side routing | De facto standard, nested routes, data loading APIs |
| UI Component Library | shadcn/ui + Radix | Latest | Accessible components | Customizable, accessible by default, Tailwind integration |
| State Management | Zustand | 4.4+ | Client UI state only | Simpler than Redux, TypeScript-first, no server state duplication |
| Real-time Communication | Socket.io | Latest | WebSocket implementation | Bidirectional for FFC messaging, reusable for all real-time features |
| Internationalization | Custom Simple | - | English/Spanish only | Lightweight translation for US market, not full i18n |
| Backend Language | TypeScript | 5.3+ | Type-safe backend | Shared types with frontend, consistency across stack |
| Backend Framework | Nest.js | 10.0+ | Enterprise Node.js framework | Modular architecture, dependency injection, built-in testing support, TypeScript-first |
| API Style | REST | - | API architecture | Simple, well-understood, sufficient for requirements |
| Database | PostgreSQL | 14+ | Primary data store | Already designed with 72 tables, JSONB support, robust |
| Cache | **In-Memory (NestJS)** | - | Session & data cache | **Cost-optimized: In-memory caching as primary strategy. DynamoDB for distributed sessions, Upstash Redis for pay-per-use caching when needed** |
| File Storage | AWS S3 | - | Document storage | Integrated encryption, versioning, cost-effective |
| Authentication | AWS Cognito | - | Auth system | Authorization Code Grant with PKCE, httpOnly cookies via API Gateway, MFA support |
| Frontend Testing | Vitest + React Testing Library | Latest | Unit/integration tests | Fast, Jest-compatible, good React integration |
| Backend Testing | Jest | 29+ | API testing | Mature, extensive mocking, good TypeScript support |
| E2E Testing | Playwright | 1.40+ | End-to-end testing | Cross-browser, reliable, good debugging |
| Build Tool | Vite | 5.0+ | Frontend bundling | Fast HMR, excellent DX, optimized production builds |
| Bundler | esbuild (via Vite) | - | JS/TS compilation | Fastest compilation, built into Vite |
| Monorepo Build | Nx | 17+ | Build orchestration | Advanced caching, dependency graph, parallel builds |
| IaC Tool | Pulumi | 3.0+ | Infrastructure as code | TypeScript-native, multi-cloud support, excellent state management |
| CI/CD | GitHub Actions + AWS Amplify | - | Deployment automation | GitHub integration, Amplify for React auto-deploy |
| Monitoring | CloudWatch + Sentry | - | Observability | AWS-native metrics, error tracking with Sentry |
| Logging | Winston + CloudWatch | - | Application logging | Structured logging, AWS integration |
| CSS Framework | Tailwind CSS | 3.4+ | Styling system | Utility-first, small production builds, shadcn/ui compatible |
| Container Platform | Docker + ECS/Fargate | - | Backend deployment | Serverless containers, no cluster management needed |
| ORM/Query Builder | Slonik + pgTyped | Latest | Database interface | Type-safe SQL operations, compile-time validation, 99 SQL query files + 10 procedure wrappers |
| Queue Management | AWS SQS | - | Application task queue | Configured with DLQ, monitoring, idempotent handlers. Used for notifications, Stripe webhooks, async tasks |
| Workflow Orchestration | AWS Step Functions | - | Document processing | Serverless orchestration for PII detection pipeline |

## 🗄️ Database Access Architecture (pgTyped + Slonik)

> **🎯 Core Strategy**: Type-safe database operations with 84% of stored procedures converted to individual SQL queries for better version control and testing.

**📋 Related ADR:** [ADR-002: pgTyped + Slonik for Database Access](#adr-002-pgtyped--slonik-for-database-access)

**🔗 Related Sections:**
- 📊 [Database Schema](#database-schema) - Complete database design
- 🏗️ [Data Models](#data-models) - TypeScript interfaces matching the schema
- ⚙️ [Database Architecture with Nest.js](#database-architecture-with-nestjs) - Backend integration
- 🧪 [Test Data Management](#test-data-management) - Testing strategies

---

### pgTyped Configuration

pgTyped provides compile-time type safety by introspecting the live PostgreSQL schema and generating TypeScript types from SQL files.

**Configuration (`pgtyped.config.json`):**
```json
{
  "srcDir": "docs/requirements/DB/sql scripts/5_SQL_files",
  "glob": "*.sql",
  "db": {
    "host": "localhost",
    "port": 15432,
    "database": "fwd_db"
  },
  "outDir": "apps/api/generated/pgtyped",
  "camelCaseColumnNames": true
}
```

**Development Workflow:**
1. Write SQL queries in `.sql` files with parameter comments
2. Run `pnpm pgtyped:gen` to generate TypeScript types
3. Use generated types in NestJS services
4. Commit both SQL and `.types.ts` files

### Slonik Runtime Client

Slonik provides a production-grade PostgreSQL client with connection pooling, strict parameterization, and monitoring.

#### Connection Configuration with Timeout Protection

This configuration establishes a production-ready connection pool with comprehensive timeout protections to prevent database resource exhaustion:

```typescript
import { createPool } from 'slonik';

export const slonikPool = createPool(connectionString, {
  // Connection pool settings
  maximumPoolSize: 10,
  minimumPoolSize: 2,
  
  // Timeout configurations (prevent rogue queries)
  connectionTimeout: 60000,      // 60s to establish connection
  idleTimeout: 30000,           // 30s idle before closing
  statementTimeout: 30000,       // 30s max per statement
  
  interceptors: [
    // Query logging, performance monitoring, error handling
  ]
});

// Database-level timeout settings
await slonikPool.query(sql`
  ALTER DATABASE fwd_db SET statement_timeout = '30s';
  ALTER DATABASE fwd_db SET lock_timeout = '10s';
  ALTER DATABASE fwd_db SET idle_in_transaction_session_timeout = '60s';
`);
```

**Key Features:**
- **Connection Pooling**: 2-10 connections for optimal resource usage
- **Timeout Protection**: Multiple timeout layers prevent hanging queries
- **Production Safety**: Statement and lock timeouts protect database performance
- **Resource Management**: Automatic connection cleanup and monitoring
```

#### Service Pattern Integration

This example shows how NestJS services integrate pgTyped types with Slonik for type-safe database operations:

```typescript
// NestJS service using pgTyped types and Slonik
async getUserById(params: GetUserByIdParams): Promise<GetUserByIdRow | null> {
  const text = loadSql('get_user_by_id.sql');
  const result = await this.pool.query(sql.unsafe(text, [params.id]));
  return result.rows[0] as GetUserByIdRow;
}
```

**Type Safety Benefits:**
- `GetUserByIdParams` - Auto-generated from SQL parameter types
- `GetUserByIdRow` - Auto-generated from SQL result types  
- Compile-time validation prevents type mismatches
- IDE autocomplete for all database operations

### SQL Query Organization

**File Structure:**
```
/docs/requirements/DB/sql scripts/5_SQL_files/
├── Authentication/      (5 files)
├── Assets/             (15 files)
├── Subscriptions/      (20 files)
├── Contacts/           (6 files)
├── Audit/              (5 files)
├── EventSourcing/      (6 files)
├── Integrations/       (30+ files)
└── Wrappers/           (10 procedure wrappers)
```

**Migration Statistics:**
- Total Procedures: 70
- Converted to SQL: 59 (84%)
- Kept as Procedures: 10 (complex business logic)
- Total SQL Files: 99 conversions + 10 wrappers

**Remaining Complex Procedures:**
1. `sp_create_user_from_cognito` - Multi-table transactional user creation
2. `sp_create_asset` - Complex asset creation with validation
3. `sp_create_ffc_with_subscription` - FFC with automatic subscription
4. `sp_process_seat_invitation` - Complex invitation workflow
5. `sp_purchase_service` - Payment processing logic
6. `sp_process_stripe_webhook` - Dynamic webhook routing
7. `sp_rebuild_projection` - Event sourcing projection
8. `sp_sync_quiltt_data` - Financial data synchronization
9. `sp_sync_real_estate_data` - Property data sync
10. `sp_refresh_builder_content` - CMS content refresh

### NestJS Integration Reference

For detailed NestJS service implementation including connection pooling, tenant isolation, and stored procedure execution patterns, see [⚙️ Database Architecture with Nest.js](#database-architecture-with-nestjs) in the Backend Architecture section.

**Key Integration Points:**
- Slonik connection pooling with tenant context
- Multi-tenant Row Level Security (RLS) setup
- Service layer patterns for database operations
- Error handling and transaction management

## Real-time Communication Architecture (WebSockets)

The platform uses WebSockets for all real-time features, with Socket.io providing reliable bidirectional communication.

### WebSocket Implementation

**Primary Use Case:** FFC Group Messaging
```typescript
// Backend: NestJS WebSocket Gateway
@WebSocketGateway({
  cors: { 
    origin: process.env.FRONTEND_URL, 
    credentials: true 
  },
  transports: ['websocket', 'polling']
})
export class EventsGateway {
  @WebSocketServer()
  server: Server;

  // FFC group messaging (bidirectional)
  @SubscribeMessage('ffc:message')
  async handleFFCMessage(client: Socket, payload: FFCMessage) {
    const room = `ffc:${payload.ffcId}`;
    // Validate user is FFC member
    if (!await this.isFFCMember(client.userId, payload.ffcId)) {
      throw new WsException('Unauthorized');
    }
    this.server.to(room).emit('ffc:new-message', payload);
  }

  // Join FFC room on connection
  async handleConnection(client: Socket) {
    const user = await this.validateToken(client.handshake.auth.token);
    const ffcs = await this.getUserFFCs(user.id);
    ffcs.forEach(ffc => client.join(`ffc:${ffc.id}`));
    client.join(`user:${user.id}`);
  }
}
```

**Secondary Use Cases (Unidirectional):**
- Document processing status updates
- Payment confirmation notifications
- Quiltt sync progress
- Asset valuation updates

### Frontend WebSocket Hook

#### Production-Ready WebSocket Hook Implementation

```typescript
// hooks/useWebSocket.ts - Complete WebSocket management
import { useEffect, useRef, useState, useCallback } from 'react';
import { io, Socket } from 'socket.io-client';
import { useAuthContext } from '@/contexts/AuthContext';
import { toast } from '@/components/ui/use-toast';

interface WebSocketState {
  connected: boolean;
  error: string | null;
  reconnectAttempts: number;
}

interface UseWebSocketReturn {
  socket: Socket | null;
  state: WebSocketState;
  joinFFCRoom: (ffcId: string) => void;
  leaveFFCRoom: (ffcId: string) => void;
  sendMessage: (event: string, data: any) => void;
  disconnect: () => void;
}

export const useWebSocket = (): UseWebSocketReturn => {
  const socketRef = useRef<Socket | null>(null);
  const { user, isAuthenticated } = useAuthContext();
  const [state, setState] = useState<WebSocketState>({
    connected: false,
    error: null,
    reconnectAttempts: 0
  });

  const updateState = useCallback((updates: Partial<WebSocketState>) => {
    setState(prev => ({ ...prev, ...updates }));
  }, []);

  // Initialize WebSocket connection
  useEffect(() => {
    if (!isAuthenticated || !user) return;

    const socket = io(process.env.REACT_APP_WS_URL!, {
      withCredentials: true,
      transports: ['websocket', 'polling'],
      timeout: 10000,
      retries: 3,
      auth: {
        userId: user.id,
        tenantId: user.tenantId
      }
    });

    socketRef.current = socket;

    // Connection event handlers
    socket.on('connect', () => {
      console.log('✅ WebSocket connected:', socket.id);
      updateState({ connected: true, error: null, reconnectAttempts: 0 });
      toast({
        title: "Connected",
        description: "Real-time updates enabled",
        duration: 2000
      });
    });

    socket.on('disconnect', (reason) => {
      console.log('❌ WebSocket disconnected:', reason);
      updateState({ connected: false });
      
      if (reason === 'io server disconnect') {
        // Server initiated disconnect - don't auto-reconnect
        toast({
          title: "Connection Lost",
          description: "Server disconnected the session",
          variant: "destructive"
        });
      }
    });

    socket.on('connect_error', (error) => {
      console.error('🔥 WebSocket connection error:', error);
      updateState({ 
        error: error.message,
        reconnectAttempts: prev => prev.reconnectAttempts + 1
      });
      
      if (state.reconnectAttempts > 3) {
        toast({
          title: "Connection Failed",
          description: "Unable to establish real-time connection",
          variant: "destructive"
        });
      }
    });

    // FFC-specific event handlers
    socket.on('ffc_member_added', (data: { ffcId: string; member: any }) => {
      toast({
        title: "New Member",
        description: `${data.member.firstName} joined your family circle`,
      });
      // Trigger React Query refetch
      queryClient.invalidateQueries(['ffc', data.ffcId, 'members']);
    });

    socket.on('asset_updated', (data: { assetId: string; ffcId: string }) => {
      toast({
        title: "Asset Updated",
        description: "Family asset information has been updated",
      });
      queryClient.invalidateQueries(['assets', data.ffcId]);
    });

    socket.on('document_processed', (data: { 
      documentId: string; 
      status: 'completed' | 'failed';
      piiDetected: boolean;
    }) => {
      const message = data.status === 'completed' 
        ? `Document processed${data.piiDetected ? ' (PII detected and masked)' : ''}`
        : 'Document processing failed';
        
      toast({
        title: "Document Processing",
        description: message,
        variant: data.status === 'failed' ? 'destructive' : 'default'
      });
      
      queryClient.invalidateQueries(['documents', data.documentId]);
    });

    // Cleanup on unmount
    return () => {
      socket.disconnect();
      socketRef.current = null;
    };
  }, [isAuthenticated, user, updateState]);

  // Room management functions
  const joinFFCRoom = useCallback((ffcId: string) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('join_ffc_room', { ffcId });
      console.log(`📍 Joined FFC room: ${ffcId}`);
    }
  }, []);

  const leaveFFCRoom = useCallback((ffcId: string) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('leave_ffc_room', { ffcId });
      console.log(`🚪 Left FFC room: ${ffcId}`);
    }
  }, []);

  // Generic message sender
  const sendMessage = useCallback((event: string, data: any) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit(event, data);
    } else {
      console.warn('⚠️ Cannot send message: WebSocket not connected');
    }
  }, []);

  // Manual disconnect
  const disconnect = useCallback(() => {
    if (socketRef.current) {
      socketRef.current.disconnect();
      socketRef.current = null;
      updateState({ connected: false, error: null });
    }
  }, [updateState]);

  return {
    socket: socketRef.current,
    state,
    joinFFCRoom,
    leaveFFCRoom,
    sendMessage,
    disconnect
  };
};

// Usage in FFC component
const FFCDashboard: React.FC<{ ffcId: string }> = ({ ffcId }) => {
  const { joinFFCRoom, leaveFFCRoom, state } = useWebSocket();

  useEffect(() => {
    joinFFCRoom(ffcId);
    return () => leaveFFCRoom(ffcId);
  }, [ffcId, joinFFCRoom, leaveFFCRoom]);

  return (
    <div className="ffc-dashboard">
      <div className="flex items-center gap-2 mb-4">
        <div className={`w-2 h-2 rounded-full ${
          state.connected ? 'bg-green-500' : 'bg-red-500'
        }`} />
        <span className="text-sm text-muted-foreground">
          {state.connected ? 'Real-time updates active' : 'Offline mode'}
        </span>
      </div>
      
      {/* Dashboard content */}
    </div>
  );
};

    // FFC messaging listeners
    socket.current.on('ffc:new-message', (message) => {
      // Update message store
    });

    // Status update listeners
    socket.current.on('document:status', (status) => {
      // Update document processing UI
    });

    return () => socket.current?.disconnect();
  }, []);

  return socket.current;
};
```

### Why WebSockets over SSE
- **Bidirectional:** Required for FFC group messaging
- **Infrastructure Reuse:** Single solution for all real-time needs
- **Reliability:** Socket.io handles reconnection, fallback to polling
- **Room Support:** Built-in room/namespace management for FFCs

### Production Implementation Reference

For complete WebSocket implementation including authentication guards, scaling strategies, and comprehensive collaboration features, see [⚙️ Real-Time WebSocket Layer with Socket.io](#real-time-websocket-layer-with-socketio) in the Backend Architecture section.

**Advanced Features Covered:**
- JWT-based WebSocket authentication
- Multi-tenant collaboration patterns
- Horizontal scaling with DynamoDB/Redis adapters
- Error handling and reconnection logic
- Performance monitoring and connection management

## 🔐 Authentication Architecture (Phased Implementation)

> **🛡️ Security First**: Phase 0 builds complete 2FA flows with stubbed authorization, Phase 1A adds AWS Cognito security.

**Implementation Strategy:**
- **Phase 0**: Complete email + SMS 2FA implementation with stubbed authorization  
- **Phase 1A**: AWS Cognito integration replaces authorization stubs
- **Phase 1A+**: Full production security with Cognito + API Gateway

**📋 Related ADR:** [ADR-003: AWS Cognito for Authentication](#adr-003-aws-cognito-for-authentication)

**🔗 Related Sections:**
- 🔒 [Security Best Practices](#security-best-practices) - Implementation guidelines
- ⚙️ [Authentication and Authorization Guards](#authentication-and-authorization-guards) - Backend enforcement
- 🌐 [Frontend Integration with Amplify](#frontend-integration-with-amplify) - Client-side integration

---

### Cognito Configuration

**User Pool Settings:**
- **OAuth Flows:** Authorization Code Grant only (with PKCE)
- **Scopes:** `openid`, `email`, `profile`
- **Callback URL:** `https://api.example.com/auth/callback`
- **Sign-out URL:** `https://app.example.com/`
- **Domain:** `your-pool-domain.auth.us-west-2.amazoncognito.com`

**Custom JWT Claims via Lambda Trigger:**
```typescript
// Lambda function for Pre Token Generation trigger
export const handler = async (event: any) => {
  const { userPoolId, userName } = event;
  
  // Lookup tenant_id once during token generation (not every request)
  const user = await getUserByUsername(userName);
  const tenantId = user.tenantId;
  const userRole = user.role;
  
  // Add custom claims to JWT
  event.response.claimsOverrideDetails = {
    claimsToAddOrOverride: {
      'custom:tenant_id': tenantId.toString(),
      'custom:role': userRole,
      'custom:ffc_ids': user.ffcIds.join(',')  // Comma-separated FFC IDs
    }
  };
  
  return event;
};

// Backend: Extract tenant from token (no DB lookup needed)
@Injectable()
export class AuthGuard {
  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);
    const decoded = this.jwtService.verify(token);
    
    // Tenant ID directly from token - eliminates DB call
    request.tenantId = parseInt(decoded['custom:tenant_id']);
    request.userRole = decoded['custom:role'];
    request.ffcIds = decoded['custom:ffc_ids'].split(',');
    
    return true;
  }
}
```

### Authentication Flow

#### Complete Authentication Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User Browser
    participant R as React SPA
    participant AG as API Gateway
    participant N as Nest.js Backend
    participant C as AWS Cognito
    participant DB as PostgreSQL

    Note over U,DB: User Login Flow
    
    U->>R: Click "Login" button
    R->>AG: GET /auth/login
    AG->>N: Forward request
    
    Note over N: Generate PKCE challenge
    N->>N: Generate code_verifier & code_challenge
    N->>N: Generate state parameter
    N->>DB: Store PKCE session data
    
    N->>AG: Redirect to Cognito URL
    AG->>R: 302 Redirect
    R->>U: Browser redirect
    U->>C: Navigate to Cognito Hosted UI
    
    Note over U,C: User Authentication
    U->>C: Enter credentials
    C->>C: Validate credentials
    C->>U: Redirect with auth code
    
    Note over U,N: Token Exchange
    U->>AG: GET /auth/callback?code=xxx&state=yyy
    AG->>N: Forward callback
    N->>DB: Validate state parameter
    N->>C: POST /oauth2/token (with PKCE)
    C->>N: Return access_token + id_token
    
    Note over N: Set Secure Cookies
    N->>N: Validate JWT tokens
    N->>N: Extract user info
    N->>DB: Set RLS context (tenant_id)
    N->>AG: Set httpOnly cookies + redirect
    AG->>R: 302 to React SPA
    R->>U: User authenticated
```

#### Token Refresh Flow

```mermaid
sequenceDiagram
    participant R as React SPA
    participant AG as API Gateway  
    participant N as Nest.js Backend
    participant C as AWS Cognito

    Note over R,C: Automatic Token Refresh
    
    R->>AG: API request with expired token
    AG->>N: Forward request
    N->>N: Validate JWT (expired)
    N->>C: POST /oauth2/token (refresh_token)
    C->>N: New access_token + id_token
    N->>N: Update httpOnly cookies
    N->>AG: Return data + new cookies
    AG->>R: Success response
    
    Note over R: Transparent to user - no re-login required
```

#### Multi-Tenant Security Context

```mermaid
flowchart TD
    A[API Request] --> B{Valid JWT?}
    B -->|No| C[Return 401]
    B -->|Yes| D[Extract tenant_id from JWT]
    D --> E[Set PostgreSQL RLS Context]
    E --> F[Execute Database Query]
    F --> G{Data belongs to tenant?}
    G -->|No| H[Empty Result Set]
    G -->|Yes| I[Return Data]
    
    style E fill:#f9f,stroke:#333,stroke-width:2px
    style G fill:#bbf,stroke:#333,stroke-width:2px
```

**Authentication Flow Steps:**

1. **Login Initiation:**
   - SPA redirects to `https://api.example.com/auth/login`
   - Backend generates PKCE challenge and state
   - Redirects to Cognito Hosted UI

2. **Callback Processing:**
   - Cognito redirects to API Gateway callback endpoint
   - Backend exchanges code for tokens
   - Sets httpOnly cookies and redirects to SPA

3. **Token Management:**
   ```javascript
   // Cookie configuration set by NestJS backend
   id_token:      HttpOnly; Secure; SameSite=Lax; Max-Age=3600
   access_token:  HttpOnly; Secure; SameSite=Lax; Max-Age=3600
   refresh_token: HttpOnly; Secure; SameSite=Lax; Max-Age=2592000
   XSRF-TOKEN:    Secure; SameSite=Lax; // Not HttpOnly for CSRF
   ```

### API Gateway Integration

**Configuration:**
- Proxy `/auth/*` and `/api/*` to NestJS backend
- Forward cookies and headers untouched
- CORS configuration with credentials support
- Optional Cognito Authorizer for pre-validation

**Auth Routes:**
```typescript
GET  /auth/login     // Initiate OAuth flow
GET  /auth/callback  // Handle Cognito callback
POST /auth/refresh   // Refresh tokens
POST /auth/logout    // Clear cookies, optional GlobalSignOut
GET  /me            // Get current user info
```

### Frontend Integration with Amplify

**Amplify's Role:**
- **Hosting & CI/CD:** Amplify hosts the React SPA and provides automated deployments
- **Auth Orchestration:** Amplify libraries handle OAuth flow redirects (but tokens never touch JavaScript)
- **No Token Storage:** Unlike typical Amplify auth, tokens are stored in httpOnly cookies only
- **UX Helpers:** Amplify provides UI components for login/logout buttons

**Amplify Configuration:**
```typescript
// Amplify config for Cognito (without token storage)
import { Amplify } from 'aws-amplify';

Amplify.configure({
  Auth: {
    region: 'us-west-2',
    userPoolId: 'us-west-2_xxxxx',
    userPoolWebClientId: 'xxxxx',
    oauth: {
      domain: 'your-pool-domain.auth.us-west-2.amazoncognito.com',
      scope: ['openid', 'email', 'profile'],
      redirectSignIn: 'https://api.example.com/auth/callback',
      redirectSignOut: 'https://app.example.com/',
      responseType: 'code' // Authorization Code flow
    }
  }
});
```

**API Calls with Credentials:**
```typescript
// All API calls include cookies automatically (not using Amplify API)
fetch('https://api.example.com/api/assets', {
  method: 'GET',
  credentials: 'include',
  headers: {
    'X-XSRF-TOKEN': getCsrfToken() // From XSRF-TOKEN cookie
  }
});
```

**Login/Logout Flow:**
```typescript
// Login button redirects to backend auth endpoint
const handleLogin = () => {
  window.location.href = 'https://api.example.com/auth/login';
};

// Logout clears cookies via backend
const handleLogout = () => {
  window.location.href = 'https://api.example.com/auth/logout';
};
```

### Security Best Practices

1. **Token Security:**
   - Tokens never stored in localStorage/sessionStorage
   - httpOnly cookies prevent XSS attacks
   - CSRF protection via XSRF-TOKEN
   - Short token lifetimes (1 hour)

2. **JWT Validation:**
   - Backend validates all tokens using Cognito JWKS
   - Verify `iss`, `aud`, `token_use`, and `exp`
   - Automatic refresh on expiration

3. **Session Management:**
   - RLS context set after authentication
   - Session cleared on logout
   - Tenant isolation enforced

### Production Implementation Flows

#### User Registration Flow
```typescript
// registration.service.ts
import { CognitoIdentityProviderClient, SignUpCommand, ConfirmSignUpCommand } from '@aws-sdk/client-cognito-identity-provider';
import { Injectable } from '@nestjs/common';

@Injectable()
export class RegistrationService {
  private cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' });
  
  async registerUser(dto: RegisterUserDto) {
    // Step 1: Register user with Cognito
    const signUpCommand = new SignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: dto.email,
      Password: dto.password,
      UserAttributes: [
        { Name: 'email', Value: dto.email },
        { Name: 'phone_number', Value: dto.phoneNumber },
        { Name: 'given_name', Value: dto.firstName },
        { Name: 'family_name', Value: dto.lastName },
        { Name: 'custom:tenant_id', Value: dto.tenantId.toString() },
      ],
    });
    
    const cognitoResponse = await this.cognitoClient.send(signUpCommand);
    return {
      userSub: cognitoResponse.UserSub,
      codeDeliveryDetails: cognitoResponse.CodeDeliveryDetails,
    };
  }
  
  async confirmRegistration(email: string, code: string) {
    const confirmCommand = new ConfirmSignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      ConfirmationCode: code,
    });
    
    await this.cognitoClient.send(confirmCommand);
    
    // Create user record in database after confirmation
    const userDetails = await this.getUserFromCognito(email);
    await this.databaseService.query(sql`
      SELECT * FROM sp_create_user_from_cognito(
        ${userDetails.tenantId}::int,
        ${userDetails.sub}::text,
        ${userDetails.email}::text,
        ${userDetails.phoneNumber}::text,
        ${userDetails.firstName}::text,
        ${userDetails.lastName}::text
      )
    `);
    
    return { success: true };
  }
}
```

#### User Login Flow
```typescript
@Injectable()
export class AuthService {
  async login(email: string, password: string) {
    try {
      const authCommand = new InitiateAuthCommand({
        AuthFlow: 'USER_SRP_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
          USERNAME: email,
          PASSWORD: password,
        },
      });
      
      const authResponse = await this.cognitoClient.send(authCommand);
      
      // Handle MFA challenge if required
      if (authResponse.ChallengeName === 'SMS_MFA') {
        return {
          requiresMfa: true,
          session: authResponse.Session,
          challengeType: 'SMS_MFA',
        };
      }
      
      const tokens = authResponse.AuthenticationResult;
      const idTokenPayload = this.decodeToken(tokens.IdToken);
      
      await this.auditService.logAuthEvent(idTokenPayload.sub, 'LOGIN_SUCCESS');
      
      return {
        accessToken: tokens.AccessToken,
        idToken: tokens.IdToken,
        refreshToken: tokens.RefreshToken,
        expiresIn: tokens.ExpiresIn,
        user: {
          id: idTokenPayload.sub,
          email: idTokenPayload.email,
          tenantId: idTokenPayload['custom:tenant_id'],
        },
      };
    } catch (error) {
      await this.auditService.logAuthEvent(email, 'LOGIN_FAILED');
      throw new UnauthorizedException('Invalid credentials');
    }
  }
}
```

#### JWT Token Validation Middleware
```typescript
@Injectable()
export class JwtAuthGuard {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);
    
    try {
      const decoded = this.jwtService.verify(token);
      
      // Set tenant context directly from token - eliminates DB call
      request.tenantId = parseInt(decoded['custom:tenant_id']);
      request.userRole = decoded['custom:role'];
      request.ffcIds = decoded['custom:ffc_ids'].split(',');
      
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }
}
```

## Data Models

These TypeScript interfaces define the core entities shared between frontend and backend, matching the database schema while keeping business logic in the application layer.

**Note:** The RealEstateAsset interface below shows ALL fields as an example. Other asset interfaces show key fields only for brevity, but in implementation they should include ALL database table fields.

### Core Entities

```typescript
interface User {
  id: string;
  tenantId: number;
  email: string;
  firstName: string;
  lastName: string;
  status: 'pending_verification' | 'active' | 'inactive' | 'suspended' | 'locked';
  emailVerified: boolean;
  phoneVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface Persona {
  id: string;
  tenantId: number;
  userId: string | null;
  firstName: string;
  middleName?: string;
  lastName: string;
  suffix?: string;
  nickname?: string;
  dateOfBirth?: Date;
  dateOfDeath?: Date;
  isLiving: boolean;
  gender?: 'male' | 'female' | 'non_binary' | 'prefer_not_to_say' | 'other';
  maritalStatus?: 'single' | 'married' | 'divorced' | 'widowed' | 'separated' | 'domestic_partnership';
  status: 'active' | 'inactive' | 'pending' | 'suspended' | 'deleted';
}

interface ForwardFamilyCircle {
  id: string;
  tenantId: number;
  name: string;
  description?: string;
  ownerUserId: string;
  familyPhotoUrl?: string;
  establishedDate: Date;
  settings: Record<string, any>;
  privacySettings: Record<string, any>;
  isActive: boolean;
  status: 'active' | 'inactive' | 'pending' | 'suspended' | 'deleted';
  subscription?: Subscription; // Active subscription details
}

### Subscription & Payment Entities

interface Plan {
  id: string;
  planCode: string;
  planName: string;
  planType: 'free' | 'paid' | 'sponsored';
  basePrice: number;
  billingFrequency: 'monthly' | 'annual' | 'one_time' | 'lifetime';
  features: Record<string, any>;
  uiConfig: {
    hideSeatManagement?: boolean;
    hideBillingSection?: boolean;
    showUnlimitedBadge?: boolean;
    badgeText?: string;
  };
}

interface Subscription {
  id: string;
  ffcId: string;
  planId: string;
  plan?: Plan;
  status: 'active' | 'trialing' | 'past_due' | 'canceled' | 'pending' | 'paused';
  payerType: 'owner' | 'advisor' | 'third_party' | 'individual' | 'none';
  advisorId?: string;
  billingAmount: number;
  currentPeriodStart?: Date;
  currentPeriodEnd?: Date;
  nextBillingDate?: Date;
  seats?: SeatAssignment[];
}

interface SeatAssignment {
  id: string;
  subscriptionId: string;
  personaId: string;
  seatType: 'basic' | 'pro' | 'enterprise';
  status: 'active' | 'inactive' | 'pending' | 'suspended' | 'deleted';
  isSelfPaid: boolean;
  invitationId?: string;
}

interface PaymentMethod {
  id: string;
  userId: string;
  paymentType: string;
  lastFour?: string;
  brand?: 'visa' | 'mastercard' | 'amex' | 'discover' | 'diners' | 'jcb' | 'unionpay' | 'other';
  expMonth?: number;
  expYear?: number;
  isDefault: boolean;
  status: 'active' | 'inactive' | 'pending' | 'suspended' | 'deleted';
}

interface Service {
  id: string;
  serviceCode: string;
  serviceName: string;
  price: number;
  serviceType: 'one_time' | 'recurring';
  deliveryTimeline?: string;
  features: Record<string, any>;
}

interface Asset {
  id: string;
  tenantId: number;
  categoryId: string;
  ffcId: string;
  name: string;
  description?: string;
  estimatedValue?: number;
  lastValuedDate?: Date;
  currencyCode: string;
  primaryDocumentId?: string;
  supportingDocuments?: string[];
  status: 'active' | 'inactive' | 'pending' | 'suspended' | 'deleted';
  isVerified: boolean;
}
```

### Complete Example: RealEstateAsset

```typescript
// COMPLETE EXAMPLE - All fields from database table included
interface RealEstateAsset extends Asset {
  // Property identification
  propertyType: 'single_family' | 'multi_family' | 'condo' | 'townhouse' | 'commercial' | 'land' | 'farm_ranch' | 'vacation_property' | 'other';
  propertySubtype?: string;
  
  // Address (references address table)
  addressId: string;
  address?: Address; // Populated when joined
  
  // Property details
  squareFootage?: number;
  lotSize?: number;
  yearBuilt?: number;
  bedrooms?: number;
  bathrooms?: number;
  parkingSpaces?: number;
  
  // Usage and ownership
  propertyUse: 'primary_residence' | 'rental' | 'vacation' | 'commercial' | 'investment' | 'vacant';
  ownershipType: 'sole_ownership' | 'joint_tenancy' | 'tenancy_in_common' | 'community_property' | 'trust_owned' | 'llc_owned';
  ownershipPercentage?: number;
  
  // Financial information
  purchasePrice?: number;
  purchaseDate?: Date;
  currentMarketValue?: number;
  taxAssessedValue?: number;
  annualPropertyTax?: number;
  mortgageBalance?: number;
  mortgageLender?: string;
  mortgageAccountNumber?: string;
  
  // Rental information (if applicable)
  monthlyRentalIncome?: number;
  currentTenant?: string;
  leaseEndDate?: Date;
  
  // Property management
  propertyManager?: string;
  propertyManagerPhone?: string;
  hoaName?: string;
  hoaFees?: number;
  hoaFrequency?: 'monthly' | 'quarterly' | 'annual';
  
  // Insurance
  insuranceProvider?: string;
  insurancePolicyNumber?: string;
  insuranceAnnualPremium?: number;
  insuranceCoverage?: number;
  
  // Additional details
  amenities?: string[];
  improvements?: string;
  notes?: string;
  
  // Valuation history
  lastAppraisalDate?: Date;
  lastAppraisalValue?: number;
  nextAppraisalDate?: Date;
}
```

### Other Asset Type Examples (Key Fields Only)

```typescript
// SIMPLIFIED EXAMPLE - Additional fields exist in actual implementation
interface FinancialAccount extends Asset {
  accountType: 'checking' | 'savings' | 'investment' | 'retirement_401k' | 'retirement_ira' | 'retirement_roth' | 'retirement_pension' | 'college_529' | 'college_coverdell' | 'hsa' | 'trust_account' | 'business_account' | 'cryptocurrency';
  institutionName: string;
  accountNumberLast4?: string;
  currentBalance: number;
  balanceAsOfDate: Date;
  isQuilttConnected: boolean;
  quilttConnectionId?: string;
  // ... 20+ additional fields in actual implementation
}

// Pattern continues for all 14 asset types
```

**Implementation Note for AI Agents:** When implementing these interfaces, reference the database schema in `DB-architecture.md` to include ALL fields from the corresponding tables. The stored procedures will return complete data which the Node.js layer processes according to business rules before sending to the frontend.

### Persona-Based Ownership Model

The Forward Inheritance Platform implements a sophisticated persona-based ownership model that enables precise asset attribution and flexible permission management within family structures.

#### Core Ownership Concepts

```typescript
interface Asset {
  id: string;
  tenantId: number;
  ffcId: string;
  categoryId: string;
  assetName: string;
  assetDescription?: string;
  status: 'active' | 'inactive' | 'pending_verification' | 'archived' | 'disputed';
  createdAt: Date;
  updatedAt: Date;
  // Ownership relationships defined separately in asset_persona table
}

interface AssetPersonaOwnership {
  id: string;
  assetId: string;
  personaId: string;
  ownershipType: 'direct' | 'trust' | 'beneficiary' | 'joint' | 'power_of_attorney' | 'custodial';
  ownershipPercentage: number; // Precise to 0.01% (stored as decimal)
  ownershipStartDate: Date;
  ownershipEndDate?: Date;
  isActiveOwner: boolean;
  ownershipNotes?: string;
  createdAt: Date;
  updatedAt: Date;
}

interface AssetPermission {
  id: string;
  assetId: string;
  personaId: string;
  permissionType: 'view' | 'edit' | 'share' | 'transfer' | 'delete' | 'admin';
  grantedBy: string; // personaId of grantor
  grantedAt: Date;
  expiresAt?: Date;
  isActive: boolean;
  permissionSource: 'ownership' | 'explicit_grant' | 'inherited' | 'administrative';
}
```

#### Ownership Model Features

1. **Direct Persona-to-Asset Links**
   - Each asset can have multiple owners (personas) with specific ownership percentages
   - Ownership percentages are precise to 0.01% for complex estate planning scenarios
   - Multiple ownership types support various legal structures (direct, trust, beneficiary, etc.)

2. **Ownership Type Classifications**
   - **Direct**: Traditional personal ownership
   - **Trust**: Assets held in trust structures
   - **Beneficiary**: Beneficiary rights to trust or retirement assets
   - **Joint**: Joint ownership (marriage, partnerships)
   - **Power of Attorney**: Legal representative ownership
   - **Custodial**: Guardian/custodial ownership for minors

3. **Permission Inheritance Model**
   ```typescript
   // Permission calculation logic
   interface PersonaAssetAccess {
     canView: boolean;      // Ownership >= 0.01% OR explicit view permission
     canEdit: boolean;      // Ownership >= 25% OR explicit edit permission  
     canShare: boolean;     // Ownership >= 50% OR explicit share permission
     canTransfer: boolean;  // Ownership >= 75% OR explicit transfer permission
     canDelete: boolean;    // Ownership = 100% OR explicit admin permission
     hasAdminRights: boolean; // Explicit admin permission only
   }
   ```

4. **Ownership Transfer & History**
   - Complete ownership transfer functionality with audit trails
   - Historical ownership tracking for estate planning and legal compliance
   - Transfer approval workflows for high-value assets
   - Automatic permission recalculation upon ownership changes

#### Implementation Architecture

##### Database Layer
- **`assets`**: Core asset information
- **`asset_persona`**: Direct ownership relationships with percentages
- **`asset_permissions`**: Explicit permission grants independent of ownership
- **`asset_ownership_history`**: Complete ownership change audit trail

##### Business Logic Layer
```typescript
class AssetOwnershipService {
  async getAssetOwners(assetId: string): Promise<AssetPersonaOwnership[]> {
    return this.pool.query(sql`
      SELECT * FROM sp_get_asset_owners(${assetId}::uuid)
    `);
  }

  async calculatePersonaPermissions(personaId: string, assetId: string): Promise<PersonaAssetAccess> {
    const ownership = await this.getPersonaOwnershipPercentage(personaId, assetId);
    const explicitPermissions = await this.getExplicitPermissions(personaId, assetId);
    
    return {
      canView: ownership > 0 || explicitPermissions.includes('view'),
      canEdit: ownership >= 25 || explicitPermissions.includes('edit'),
      canShare: ownership >= 50 || explicitPermissions.includes('share'),
      canTransfer: ownership >= 75 || explicitPermissions.includes('transfer'),
      canDelete: ownership === 100 || explicitPermissions.includes('admin'),
      hasAdminRights: explicitPermissions.includes('admin')
    };
  }

  async transferOwnership(
    assetId: string, 
    fromPersonaId: string, 
    toPersonaId: string, 
    percentage: number
  ): Promise<void> {
    return this.pool.query(sql`
      SELECT sp_transfer_asset_ownership(
        ${assetId}::uuid,
        ${fromPersonaId}::uuid,
        ${toPersonaId}::uuid,
        ${percentage}::decimal
      )
    `);
  }
}
```

##### Security & Access Control
- **Tenant Isolation**: All ownership queries include tenant context
- **Permission Validation**: Guards validate persona ownership before asset operations
- **Audit Logging**: All ownership changes logged for compliance and dispute resolution
- **Privacy Protection**: Assets only visible to personas with explicit ownership or permissions

#### Key Architectural Principles

1. **Asset Independence**: Assets have independent ownership structures separate from FFC membership
2. **Percentage Precision**: Support for complex ownership scenarios with decimal precision
3. **Permission Flexibility**: Explicit permissions can override ownership-based defaults
4. **Historical Tracking**: Complete audit trail for legal and estate planning requirements
5. **Transfer Workflows**: Secure ownership transfer with approval mechanisms for valuable assets

This model enables the platform to handle complex family wealth structures while maintaining clear asset attribution and flexible access controls for various estate planning scenarios.

## API Specification

Based on REST architecture, this OpenAPI 3.0 specification defines all endpoints. The NestJS backend handles business logic, while stored procedures manage CRUD operations.

### REST API Specification

```yaml
openapi: 3.0.0
info:
  title: Forward Inheritance Platform API
  version: 1.0.0
  description: RESTful API for Forward Inheritance Platform with business logic in Node.js and CRUD operations via stored procedures
servers:
  - url: https://api.forwardinheritance.com/v1
    description: Production
  - url: https://staging-api.forwardinheritance.com/v1
    description: Staging
  - url: http://localhost:3000/v1
    description: Development

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      
  schemas:
    Error:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
              example: "VALIDATION_ERROR"
            message:
              type: string
            details:
              type: object
            timestamp:
              type: string
              format: date-time
            requestId:
              type: string
              format: uuid

paths:
  # Authentication Endpoints
  /auth/register:
    post:
      tags: [Authentication]
      summary: Register new user
      description: Business logic validates input, registers with AWS Cognito, then calls sp_create_user_from_cognito
      
  /auth/verify-email:
    post:
      tags: [Authentication]
      summary: Verify email address
      description: NestJS service validates token format, then verifies via AWS Cognito (no database procedure)
      
  /auth/verify-phone:
    post:
      tags: [Authentication]
      summary: Verify phone number
      description: NestJS service validates code format and rate limits, then verifies via AWS Cognito (no database procedure)
      
  /auth/login:
    post:
      tags: [Authentication]
      summary: User login
      description: NestJS service authenticates via AWS Cognito which handles password validation and JWT generation
      
  # FFC Management Endpoints
  /ffcs:
    post:
      tags: [FFC]
      summary: Create new FFC
      description: Business logic validates user permissions, then calls sp_create_ffc
      security:
        - bearerAuth: []
        
    get:
      tags: [FFC]
      summary: List user's FFCs
      description: NestJS service applies filters and pagination, calls sp_get_ffc_summary for each FFC
      security:
        - bearerAuth: []
        
  /ffcs/{ffcId}/members:
    post:
      tags: [FFC]
      summary: Invite member to FFC
      description: Complex business logic for dual-channel verification, then sp_create_invitation
      security:
        - bearerAuth: []
        
  # Subscription & Payment Endpoints
  /subscriptions:
    get:
      tags: [Subscriptions]
      summary: Get FFC subscription details
      description: Retrieves active subscription with plan details and seat assignments
      security:
        - bearerAuth: []
        
  /subscriptions/plans:
    get:
      tags: [Subscriptions]
      summary: List available plans
      description: Returns public plans with UI configuration for dynamic rendering
        
  /subscriptions/upgrade:
    post:
      tags: [Subscriptions]
      summary: Upgrade subscription plan
      description: Handles plan transitions with proration via sp_transition_subscription_plan
      security:
        - bearerAuth: []
        
  /subscriptions/seats:
    post:
      tags: [Subscriptions]
      summary: Assign seat to member
      description: Process seat invitation via sp_process_seat_invitation
      security:
        - bearerAuth: []
        
  /payments/methods:
    post:
      tags: [Payments]
      summary: Add payment method
      description: Store payment method via Stripe, cache details locally
      security:
        - bearerAuth: []
        
    delete:
      tags: [Payments]
      summary: Remove payment method
      description: Calls sp_delete_payment_method, fails if in use
      security:
        - bearerAuth: []
        
  /services:
    get:
      tags: [Services]
      summary: List available services
      description: Returns one-time services like Estate Capture Service
        
  /services/purchase:
    post:
      tags: [Services]
      summary: Purchase one-time service
      description: Process service purchase via sp_purchase_service
      security:
        - bearerAuth: []
        
  /webhooks/stripe:
    post:
      tags: [Webhooks]
      summary: Stripe webhook endpoint
      description: Asynchronous processing via sp_process_stripe_webhook
        
  # Asset Management Endpoints
  /assets:
    post:
      tags: [Assets]
      summary: Create new asset
      description: NestJS service validates asset data based on category, then calls category-specific stored procedure
      security:
        - bearerAuth: []
        
  /assets/{assetId}:
    get:
      tags: [Assets]
      summary: Get asset details
      description: NestJS service checks permissions via RLS policies, then sp_get_asset_details
      security:
        - bearerAuth: []
        
    put:
      tags: [Assets]
      summary: Update asset
      description: Business logic validates changes and permissions, then calls sp_update_asset
      security:
        - bearerAuth: []
        
  /assets/{assetId}/documents:
    post:
      tags: [Assets]
      summary: Upload document for asset
      description: NestJS service handles file upload to S3, triggers Lambda for PII processing (document storage handled in application layer)
      security:
        - bearerAuth: []
        
  # Integration Endpoints
  /integrations/quiltt/connect:
    post:
      tags: [Integrations]
      summary: Connect Quiltt account
      description: NestJS service orchestrates OAuth flow with Quiltt, then sp_configure_quiltt_integration
      security:
        - bearerAuth: []
        
  /integrations/quiltt/sync:
    post:
      tags: [Integrations]
      summary: Sync Quiltt accounts
      description: NestJS service fetches from Quiltt API, processes data, then calls sp_sync_quiltt_data
      security:
        - bearerAuth: []
        
  # Reporting Endpoints
  /reports/wealth-summary:
    get:
      tags: [Reports]
      summary: Generate wealth summary report
      description: NestJS service aggregates data from multiple stored procedures, applies business calculations
      security:
        - bearerAuth: []
```

## Components

Major logical components and services across the fullstack, with clear boundaries and responsibilities.

### Frontend Components

- **React Application Shell**: Main application container, routing, layout, and global state initialization
- **Authentication Service (Frontend)**: Manage authentication state, token storage, and auth flows
- **Asset Management Module**: Handle all asset CRUD operations and display logic
- **Document Upload Service**: Handle file uploads with progress tracking and S3 integration

### Backend Components

- **Nest.js Application**: Modular backend with dependency injection, guards, interceptors, and decorators
- **Module Organization**: Domain-driven modules (AuthModule, FFCModule, AssetsModule, IntegrationsModule)
- **Service Layer**: Business logic services with dependency injection and testability
- **Repository Layer**: Type-safe stored procedure execution using Slonik
- **Guard Layer**: TenantIsolationGuard, FfcMembershipGuard, AssetPermissionsGuard for authorization
- **Interceptor Layer**: Caching, logging, performance monitoring, and tenant context management
- **AWS Step Functions**: Orchestrate document processing pipeline for PII detection
- **SQS Queue Processors**: Handle async application tasks (notifications, reports, API sync)
- **External Integration Modules**: Dedicated modules for Quiltt, Builder.io, Vanta integrations

### Shared Components

- **Type Definitions Package**: Shared TypeScript interfaces and types between frontend and backend
- **Utility Functions Package**: Common utilities used across the stack

## External APIs

The platform integrates with several external services to provide comprehensive functionality.

### Twilio API
- **Purpose:** SMS verification for dual-channel authentication and notifications
- **Documentation:** https://www.twilio.com/docs/sms/api
- **Base URL(s):** https://api.twilio.com/2010-04-01
- **Authentication:** Basic Auth with Account SID and Auth Token
- **Rate Limits:** 1 request/second for SMS sending

### SendGrid API
- **Purpose:** Transactional email for verification, invitations, and notifications
- **Documentation:** https://docs.sendgrid.com/api-reference/mail-send
- **Base URL(s):** https://api.sendgrid.com/v3
- **Authentication:** Bearer token with API Key
- **Rate Limits:** 600 requests/second (unlikely to hit)

### Quiltt Integration Architecture

#### Overview

This section defines the complete architecture for integrating Quiltt banking connectivity into the Forward Inheritance Platform. The design focuses on the normal user flow: one user connecting their personal bank accounts to their primary persona.

#### User Flow

##### Standard Banking Connection Flow

1. **User Authentication**: User logs into Forward Inheritance Platform
2. **Asset Creation Intent**: User navigates to "Add Financial Asset"
3. **Connection Method Selection**: User chooses "Connect Bank Account" vs "Manual Entry"
4. **Quiltt Session Creation**: Backend creates temporary Quiltt session token
5. **Bank Authentication**: User redirected to Quiltt UI, authenticates with bank
6. **Account Selection**: User selects which accounts to share (e.g., 3 accounts)
7. **Webhook Processing**: Quiltt sends webhook with connection details
8. **Asset Creation**: Backend creates 3 financial account assets
9. **Data Synchronization**: Account balances and details populated from Quiltt

#### Database Architecture

##### Core Tables

###### quiltt_integrations
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

###### quiltt_sessions
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

###### financial_accounts (enhanced)
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

##### Data Relationships

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

#### API Implementation

##### Backend Services

###### QuilttIntegrationService

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

##### Frontend Integration

###### React Component for Banking Connection

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

#### Security Considerations

##### Data Protection
- All Quiltt tokens encrypted at rest using AWS KMS
- Session tokens expire quickly (15 minutes max)
- Only account metadata stored, no credentials
- Webhook signatures verified using HMAC

##### Access Control
- Quiltt integration tied to specific persona
- Asset ownership automatically assigned to connecting persona
- Standard RBAC applies to viewing/editing financial assets

##### Privacy
- Bank credentials never stored in our system
- Account numbers masked (last 4 digits only)
- PII handling follows existing platform standards

#### Monitoring & Observability

##### Key Metrics
- Banking connection success/failure rates
- Account sync frequency and success rates
- Session token usage and expiration
- Webhook processing latency

##### Alerting
- Failed webhook processing
- Sync failures for multiple accounts
- Expired or invalid tokens
- Unusual account access patterns

#### Error Handling

##### Connection Failures
- Graceful fallback to manual asset entry
- Clear error messages for users
- Retry mechanisms for temporary failures
- Admin dashboard for connection status

##### Data Sync Issues
- Exponential backoff for API calls
- Dead letter queue for failed webhooks
- Manual sync triggers for administrators
- Account status indicators in UI

**API Reference:**
- **Documentation:** https://docs.quiltt.io/api-reference
- **Base URL(s):** https://api.quiltt.io/v1
- **Authentication:** OAuth 2.0 with client credentials
- **Rate Limits:** 100 requests/minute per connection

### HEI Asset Category & Ingestion API

#### Overview
HEI (Home Equity Investment) is implemented as the **14th Asset Category** in the Forward platform, providing complete flexibility for HEI-specific workflows without affecting the loans section.

#### Architecture Pattern
- **Asset Category:** Dedicated 'HEI' category with specialized fields
- **Database Design:** `hei_assets` table linked to base `assets` table
- **Document Processing:** Reuses existing document pipeline with HEI context
- **Property Linking:** HEI assets reference associated real estate assets

#### API Endpoints

**HEI Ingestion**
- **Endpoint:** `POST /ingest/hei`
- **Purpose:** External HEI system ingestion for completed deals
- **Authentication:** API Key
- **Idempotency:** Required via `Idempotency-Key` header
- **Rate Limits:** 100 requests/minute

**Document Upload**
- **Endpoint:** `POST /ingest/hei/{heiAssetId}/documents`
- **Purpose:** Attach HEI-specific documents
- **Content-Type:** multipart/form-data
- **Processing:** Sync document processing via NestJS cache

#### Data Model
```sql
-- 14th Asset Category
INSERT INTO asset_categories (name, code, description, sort_order) VALUES
('HEI', 'hei', 'Home Equity Investment assets', 14);

-- HEI-specific table
CREATE TABLE hei_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE REFERENCES assets(id),
    
    -- HEI terms
    amount_funded DECIMAL(15,2) NOT NULL,
    equity_share_pct DECIMAL(5,2) NOT NULL,
    effective_date DATE NOT NULL,
    maturity_terms TEXT,
    
    -- Property relationship
    property_asset_id UUID REFERENCES assets(id),
    
    -- External tracking
    source_system TEXT,
    external_id TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Entity Creation Flow
1. **Real Estate Asset:** Create/find property asset (category: real_estate)
2. **HEI Asset:** Create HEI investment asset (category: hei)
3. **Persona & FFC:** Create owner persona and family circle
4. **Ownership Links:** Link both assets to persona/FFC via asset_persona
5. **Document Processing:** Cache and process HEI documents
6. **User Invitation:** Send FFC invitation email

#### User Experience Benefits
- **Clean Separation:** HEI and loans remain independent
- **Flexible Management:** HEI-specific permissions and workflows
- **Clear UI:** Distinct asset categories in dashboard
- **Future Extensibility:** HEI features (buyouts, refinancing) contained

#### Implementation Services
```typescript
// HEI Asset Service
class HEIAssetService {
  async createHEIAsset(heiData: HEIData, propertyAssetId: string) {
    // Create base asset
    const asset = await this.createAsset({
      category: 'hei',
      name: `HEI Investment - ${heiData.property_address}`,
      value: heiData.amount_funded
    })
    
    // Create HEI-specific record
    await this.createHEISpecificRecord(asset.id, heiData, propertyAssetId)
    
    return asset
  }
}

// Document Processing
class HEIDocumentService {
  async processHEIDocuments(heiAssetId: string, documents: File[]) {
    // Store in NestJS cache
    await this.cache.set(`hei-docs-${heiAssetId}`, documents)
    
    // Process using existing pipeline
    for (const doc of documents) {
      await this.documentService.processDocument(
        doc, 'hei', heiAssetId, 'HEI Investment'
      )
    }
  }
}
```

### Real Estate Valuation API (Phase 2 - Provider TBD)
- **Purpose:** Automated property valuations and market data
- **Documentation:** *Provider selection pending*
- **Provider Options Under Evaluation:**
  1. Zillow GetEstimate API
  2. CoreLogic Property API
  3. RentSpree Valuation API
  4. Attom Data API

### Vanta API
- **Purpose:** SOC 2 compliance automation, security monitoring, and audit evidence collection
- **Documentation:** `/docs/requirements/API/Vanta/vanta-api-documentation.md`
- **Base URL:** https://api.vanta.com
- **Authentication:** OAuth 2.0 Client Credentials flow
- **Rate Limits:** 
  - Management endpoints: 50 requests/minute
  - OAuth endpoints: 5 requests/minute
  - Integration endpoints: 20 requests/minute
- **Key Features:**
  - Security control monitoring
  - Vendor management
  - Compliance evidence collection
  - Employee device tracking
  - Automated SOC 2 reporting

### AWS Services (Native Integration)
- **S3:** Document storage with KMS encryption (SSE-KMS) for both original and masked documents
- **Step Functions:** Orchestrate document processing workflow with automatic retries and error handling
- **Lambda:** Execute PII detection and document processing tasks within Step Functions
- **Comprehend:** Native PII detection and redaction in ONLY_REDACTION mode
- **KMS:** Customer-managed keys for document encryption with automatic rotation
- **CloudWatch:** Centralized logging and monitoring for all services
- **EventBridge:** Event-driven triggers for Step Functions execution
- **CloudTrail:** Audit logging for compliance and security monitoring

## Core Workflows

[User Registration, FFC Creation, Asset Creation, Financial Sync, Permission Check, and Error Handling workflows documented with detailed sequence diagrams]

## Database Schema

The database schema is already fully designed with 72 tables and 69 stored procedures (54 functions and 15 procedures). Essential tables include:

- Multi-tenant foundation (tenants, users, personas)
- Family circles (fwd_family_circles, ffc_personas)
- Asset management (assets, asset_persona, asset_permissions)
- Contact normalization (email_address, phone_number, usage tables)
- Security and audit (audit_log, audit_events)

Key stored procedures handle:
- User registration with normalized contacts
- Asset creation with ownership
- Permission checking
- All CRUD operations

**Note**: The complete schema with all 72 tables and 69 stored procedures is documented in `DB-architecture.md`.

## 🌐 Frontend Architecture

> **🎯 Core Strategy**: Feature-based architecture with clear separation of concerns, type safety, and reusable components for optimal developer experience and maintainability.

**🔗 Related Sections:**
- 🔧 [Tech Stack](#tech-stack) - Frontend technology choices
- 🏗️ [Component Patterns](#component-patterns) - Detailed component guidelines
- 🔄 [State Management Architecture](#state-management-architecture) - Client state management
- 🧪 [Testing Strategy](#testing-strategy) - Frontend testing approaches

---

### Component Architecture Overview

The frontend follows a feature-based architecture with clear separation of concerns, type safety, and reusable components.

```typescript
// Frontend structure
apps/web/src/
├── components/           // Shared UI components
│   ├── ui/              // shadcn/ui base components
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── dialog.tsx
│   │   └── form.tsx
│   ├── layout/          // Layout components
│   │   ├── AppShell.tsx
│   │   ├── Navigation.tsx
│   │   ├── Sidebar.tsx
│   │   └── Footer.tsx
│   └── shared/          // Shared business components
│       ├── AssetCard.tsx
│       ├── PersonaAvatar.tsx
│       ├── PermissionBadge.tsx
│       └── LoadingStates.tsx
├── features/            // Feature-based modules
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   ├── DualChannelVerification.tsx
│   │   │   └── PasswordReset.tsx
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   └── useVerification.ts
│   │   ├── stores/
│   │   │   └── authStore.ts
│   │   └── services/
│   │       └── authService.ts
│   ├── ffcs/            // Family Circles
│   │   ├── components/
│   │   │   ├── FFCList.tsx
│   │   │   ├── FFCCard.tsx
│   │   │   ├── CreateFFCWizard.tsx
│   │   │   ├── MemberInvitation.tsx
│   │   │   └── MemberManagement.tsx
│   │   ├── hooks/
│   │   │   ├── useFFCs.ts
│   │   │   └── useMembers.ts
│   │   └── stores/
│   │       └── ffcStore.ts
│   ├── assets/          // Asset Management (13 types)
│   │   ├── components/
│   │   │   ├── AssetDashboard.tsx
│   │   │   ├── AssetList.tsx
│   │   │   ├── AssetDetail.tsx
│   │   │   └── CreateAssetFlow.tsx
│   │   ├── types/       // Asset type-specific components
│   │   │   ├── RealEstate/
│   │   │   │   ├── RealEstateForm.tsx
│   │   │   │   ├── PropertyValuation.tsx
│   │   │   │   └── MortgageDetails.tsx
│   │   │   ├── FinancialAccounts/
│   │   │   │   ├── AccountForm.tsx
│   │   │   │   ├── QuilttConnection.tsx
│   │   │   │   └── BalanceSync.tsx
│   │   │   └── [11 other asset types]/
│   │   ├── hooks/
│   │   │   ├── useAssets.ts
│   │   │   ├── useAssetPermissions.ts
│   │   │   └── useAssetCategories.ts
│   │   └── stores/
│   │       └── assetStore.ts
│   └── documents/       // Document Management
│       ├── components/
│       │   ├── DocumentUploader.tsx
│       │   ├── DocumentViewer.tsx
│       │   ├── PIIStatusIndicator.tsx
│       │   └── DocumentList.tsx
│       └── hooks/
│           └── useDocuments.ts
├── hooks/               // Global hooks
│   ├── usePermissions.ts
│   ├── useWebSocket.ts
│   ├── useNotifications.ts
│   └── useBreakpoints.ts
├── stores/              // Global state stores
│   ├── globalStore.ts
│   ├── notificationStore.ts
│   └── cacheStore.ts
├── services/            // API service layer
│   ├── apiClient.ts     // Axios instance
│   ├── authService.ts
│   ├── ffcService.ts
│   ├── assetService.ts
│   └── documentService.ts
├── utils/               // Utility functions
│   ├── formatters.ts
│   ├── validators.ts
│   ├── constants.ts
│   └── errors.ts
├── types/               // TypeScript types
│   └── index.ts         // Re-exports from @fwd/shared
└── pages/               // Route pages
    ├── Dashboard.tsx
    ├── Assets.tsx
    ├── FFCs.tsx
    └── Settings.tsx
```

### State Management Architecture

#### Clear Separation: React Query for Server State, Zustand for UI State

**React Query - Server State Only:**
```typescript
// hooks/useAssets.ts - Server state via React Query
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch assets - NO Zustand sync
export const useAssets = () => {
  return useQuery({
    queryKey: ['assets'],
    queryFn: fetchAssets,
    staleTime: 5 * 60 * 1000,  // 5 minutes
    cacheTime: 10 * 60 * 1000,  // 10 minutes
  });
};

// Optimistic update example (fixed from feedback)
export const useCreateAsset = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: createAsset,
    onMutate: async (newAsset) => {
      // Cancel in-flight queries
      await queryClient.cancelQueries(['assets']);
      
      // Snapshot for rollback
      const previousAssets = queryClient.getQueryData(['assets']);
      
      // TRUE optimistic update - happens before server response
      queryClient.setQueryData(['assets'], (old: Asset[]) => [
        ...old,
        { ...newAsset, id: `temp-${Date.now()}`, status: 'creating' }
      ]);
      
      return { previousAssets };
    },
    onError: (err, newAsset, context) => {
      // Rollback on error
      queryClient.setQueryData(['assets'], context.previousAssets);
    },
    onSettled: () => {
      // Refetch to ensure consistency
      queryClient.invalidateQueries(['assets']);
    }
  });
};
```

**Zustand - UI State Only (NO Server Data):**
```typescript
// stores/uiStore.ts - UI state only
import { create } from 'zustand';

interface UIState {
  // UI-only state
  selectedAssetId: string | null;
  viewMode: 'grid' | 'list' | 'table';
  sidebarOpen: boolean;
  filterPanelOpen: boolean;
  activeFilters: FilterOptions;
  
  // Actions
  selectAsset: (id: string | null) => void;
  setViewMode: (mode: 'grid' | 'list' | 'table') => void;
  toggleSidebar: () => void;
  setFilters: (filters: FilterOptions) => void;
}

// Production-safe store (no devtools in prod)
export const useUIStore = import.meta.env.PROD
  ? create<UIState>((set) => ({
      selectedAssetId: null,
      viewMode: 'grid',
      sidebarOpen: true,
      filterPanelOpen: false,
      activeFilters: {},
        filters: {},
        isLoading: false,
        error: null,
        
        setAssets: (assets) => set((state) => {
          state.assets = assets;
        }),
        
        selectAsset: (id) => set((state) => {
          state.selectedAsset = state.assets.find(a => a.id === id) || null;
        }),
        
        updateAsset: (id, updates) => set((state) => {
          const index = state.assets.findIndex(a => a.id === id);
          if (index !== -1) {
            state.assets[index] = { ...state.assets[index], ...updates };
          }
        }),
        
        deleteAsset: (id) => set((state) => {
          state.assets = state.assets.filter(a => a.id !== id);
        }),
        
        setFilters: (filters) => set((state) => {
          state.filters = filters;
        }),
        
        reset: () => set(() => initialState),
      })),
      {
        name: 'asset-store',
        partialize: (state) => ({ filters: state.filters }), // Only persist filters
      }
    )
  )
);
```

#### React Query Integration
```typescript
// hooks/useAssets.ts - Server state management
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { assetService } from '@/services/assetService';
import { useAssetStore } from '@/stores/assetStore';

export function useAssets(ffcId: string) {
  const setAssets = useAssetStore((state) => state.setAssets);
  
  return useQuery({
    queryKey: ['assets', ffcId],
    queryFn: () => assetService.getAssets(ffcId),
    onSuccess: (data) => {
      setAssets(data); // Sync with Zustand
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
}

export function useCreateAsset() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: assetService.createAsset,
    onSuccess: (newAsset) => {
      // Optimistic update
      queryClient.setQueryData(
        ['assets', newAsset.ffcId],
        (old: Asset[] = []) => [...old, newAsset]
      );
    },
    onError: (error, variables, context) => {
      // Rollback optimistic update
      queryClient.setQueryData(['assets', variables.ffcId], context.previousAssets);
    },
  });
}
```

### Component Patterns

#### Feature Component Pattern
```typescript
// features/assets/components/AssetDashboard.tsx
import { Suspense, lazy } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { useAssets } from '../hooks/useAssets';
import { AssetFilters } from './AssetFilters';
import { AssetList } from './AssetList';
import { AssetSkeleton } from './AssetSkeleton';

const AssetDetail = lazy(() => import('./AssetDetail'));

export function AssetDashboard({ ffcId }: { ffcId: string }) {
  const { data: assets, isLoading, error } = useAssets(ffcId);
  const selectedAsset = useAssetStore((state) => state.selectedAsset);
  
  if (error) {
    return <AssetErrorState error={error} />;
  }
  
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2">
        <AssetFilters />
        {isLoading ? (
          <AssetSkeleton count={5} />
        ) : (
          <AssetList assets={assets} />
        )}
      </div>
      
      <div className="lg:col-span-1">
        <ErrorBoundary fallback={<div>Error loading asset details</div>}>
          <Suspense fallback={<AssetDetailSkeleton />}>
            {selectedAsset && <AssetDetail asset={selectedAsset} />}
          </Suspense>
        </ErrorBoundary>
      </div>
    </div>
  );
}
```

#### Compound Component Pattern
```typescript
// components/shared/AssetCard.tsx
import { createContext, useContext } from 'react';

const AssetCardContext = createContext<Asset | null>(null);

export function AssetCard({ asset, children }: { asset: Asset; children: React.ReactNode }) {
  return (
    <AssetCardContext.Provider value={asset}>
      <Card className="p-4">
        {children}
      </Card>
    </AssetCardContext.Provider>
  );
}

AssetCard.Header = function Header() {
  const asset = useContext(AssetCardContext);
  return (
    <div className="flex justify-between items-start">
      <h3 className="text-lg font-semibold">{asset.name}</h3>
      <AssetTypeBadge type={asset.type} />
    </div>
  );
};

AssetCard.Value = function Value() {
  const asset = useContext(AssetCardContext);
  return (
    <div className="text-2xl font-bold">
      {formatCurrency(asset.currentValue)}
    </div>
  );
};

AssetCard.Actions = function Actions({ onEdit, onDelete }: ActionProps) {
  const asset = useContext(AssetCardContext);
  return (
    <div className="flex gap-2">
      <Button size="sm" onClick={() => onEdit(asset.id)}>Edit</Button>
      <Button size="sm" variant="destructive" onClick={() => onDelete(asset.id)}>Delete</Button>
    </div>
  );
};

// Usage
<AssetCard asset={asset}>
  <AssetCard.Header />
  <AssetCard.Value />
  <AssetCard.Actions onEdit={handleEdit} onDelete={handleDelete} />
</AssetCard>
```

#### Dynamic Form Generation Pattern (UI Collection Mask)

The platform uses a metadata-driven form generation system that dynamically creates forms based on database configuration. For assets, this requires merging two UI collection masks: the base asset mask and the specific asset type mask.

**Core Architecture:**
```typescript
// types/uiCollectionMask.ts
export interface UIEntity {
  entityCode: string;      // 'ASSETS', 'REAL_ESTATE', 'FINANCIAL_ACCOUNTS', etc.
  tableName: string;       // 'assets', 'real_estate', 'financial_accounts', etc.
}

export interface UICollectionMask {
  entityCode: string;
  columnName: string;
  requirement: 'mandatory' | 'optional';
  fieldType: 'text' | 'int' | 'real' | 'phone' | 'zip' | 'email' | 'date' | 'year' | 'currency' | 'currency_code' | 'enum';
  displayOrder: number;
  note?: string;           // Enum choices in pipe-separated format
}

export interface MergedAssetMask {
  baseFields: UICollectionMask[];      // From ASSETS entity
  typeFields: UICollectionMask[];      // From specific asset type entity
  allFields: UICollectionMask[];       // Merged and sorted by display_order
  mandatory: UICollectionMask[];
  optional: UICollectionMask[];
}
```

**Asset Form Hook (Merged Masks):**
```typescript
// hooks/useAssetForm.ts
import { useQuery } from '@tanstack/react-query';
import { uiCollectionMaskService } from '../services/uiCollectionMaskService';

export const useAssetForm = (assetType: string) => {
  return useQuery({
    queryKey: ['asset-form-mask', assetType],
    queryFn: () => uiCollectionMaskService.getAssetFormMask(assetType),
    staleTime: 10 * 60 * 1000,  // 10 minutes - forms don't change often
    select: (data: MergedAssetMask) => ({
      ...data,
      mandatoryBase: data.baseFields.filter(f => f.requirement === 'mandatory'),
      mandatoryType: data.typeFields.filter(f => f.requirement === 'mandatory'),
      optionalBase: data.baseFields.filter(f => f.requirement === 'optional'),
      optionalType: data.typeFields.filter(f => f.requirement === 'optional')
    })
  });
};
```

**Service Layer (Single API Call, Two DB Queries):**
```typescript
// services/uiCollectionMaskService.ts
export const uiCollectionMaskService = {
  // Single API call that internally does two DB queries and merges
  getAssetFormMask: async (assetType: string): Promise<MergedAssetMask> => {
    const response = await apiClient.get(`/ui-collection-mask/asset-form/${assetType}`);
    return response.data;
  },
  
  // For non-asset entities (single mask lookup)
  getByEntityCode: async (entityCode: string): Promise<UICollectionMask[]> => {
    const response = await apiClient.get(`/ui-collection-mask/entity/${entityCode}`);
    return response.data;
  }
};
```

**Backend API Implementation:**
```typescript
// Backend: controllers/ui-collection-mask.controller.ts
@Get('asset-form/:assetType')
async getAssetFormMask(@Param('assetType') assetType: string): Promise<MergedAssetMask> {
  // Two database queries in parallel
  const [baseFields, typeFields] = await Promise.all([
    this.uiCollectionMaskService.getByEntityCode('ASSETS'),
    this.uiCollectionMaskService.getByEntityCode(assetType.toUpperCase())
  ]);
  
  // Merge and sort by display_order
  const allFields = [...baseFields, ...typeFields]
    .sort((a, b) => a.displayOrder - b.displayOrder);
  
  return {
    baseFields,
    typeFields, 
    allFields,
    mandatory: allFields.filter(f => f.requirement === 'mandatory'),
    optional: allFields.filter(f => f.requirement === 'optional')
  };
}
```

**Progressive Asset Form Pattern:**
```typescript
// components/assets/DynamicAssetForm.tsx
export function DynamicAssetForm({ assetType }: { assetType: string }) {
  const { data: maskConfig, isLoading } = useAssetForm(assetType);
  const [showAdvanced, setShowAdvanced] = useState(false);
  
  if (isLoading) return <FormSkeleton />;
  
  return (
    <Form>
      {/* Base Asset Fields (Required) */}
      <FieldGroup title="Basic Asset Information">
        {maskConfig.mandatoryBase.map(field => (
          <DynamicField key={field.columnName} field={field} {...fieldProps} />
        ))}
      </FieldGroup>
      
      {/* Asset Type Specific Fields (Required) */}
      {maskConfig.mandatoryType.length > 0 && (
        <FieldGroup title={`${assetType} Details`}>
          {maskConfig.mandatoryType.map(field => (
            <DynamicField key={field.columnName} field={field} {...fieldProps} />
          ))}
        </FieldGroup>
      )}
      
      {/* Progressive disclosure for all optional fields */}
      {(maskConfig.optionalBase.length > 0 || maskConfig.optionalType.length > 0) && (
        <>
          <Button 
            type="button" 
            variant="outline" 
            onClick={() => setShowAdvanced(!showAdvanced)}
          >
            {showAdvanced ? 'Hide' : 'Show'} Advanced Fields 
            ({maskConfig.optionalBase.length + maskConfig.optionalType.length})
          </Button>
          
          {showAdvanced && (
            <>
              {maskConfig.optionalBase.length > 0 && (
                <FieldGroup title="Additional Asset Information">
                  {maskConfig.optionalBase.map(field => (
                    <DynamicField key={field.columnName} field={field} {...fieldProps} />
                  ))}
                </FieldGroup>
              )}
              
              {maskConfig.optionalType.length > 0 && (
                <FieldGroup title={`Additional ${assetType} Information`}>
                  {maskConfig.optionalType.map(field => (
                    <DynamicField key={field.columnName} field={field} {...fieldProps} />
                  ))}
                </FieldGroup>
              )}
            </>
          )}
        </>
      )}
    </Form>
  );
}
```

**Database Query Implementation:**
```sql
-- Backend: Two queries executed in parallel, then merged
-- Query 1: Base asset fields
SELECT column_name, requirement::text, field_type::text, display_order, note 
FROM ui_collection_mask 
WHERE entity_code = 'ASSETS' 
ORDER BY display_order;

-- Query 2: Specific asset type fields  
SELECT column_name, requirement::text, field_type::text, display_order, note 
FROM ui_collection_mask 
WHERE entity_code = $1  -- e.g., 'REAL_ESTATE'
ORDER BY display_order;
```

**Benefits:**
- **Single API Call**: Frontend makes one request, backend handles complexity
- **Optimized Performance**: Two DB queries run in parallel
- **Clear Separation**: Base vs type-specific fields are clearly distinguished in UI
- **Flexible Display**: Can group fields logically (Basic Info vs Real Estate Details)
- **Type Safety**: Full TypeScript support throughout the chain

### Routing Architecture

```typescript
// routes/index.tsx - Centralized routing
import { createBrowserRouter } from 'react-router-dom';
import { ProtectedRoute } from './ProtectedRoute';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppLayout />,
    children: [
      {
        index: true,
        element: <Navigate to="/dashboard" />,
      },
      {
        path: 'dashboard',
        element: (
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        ),
      },
      {
        path: 'ffcs/:ffcId',
        element: (
          <ProtectedRoute requiredPermission="ffc.view">
            <FFCLayout />
          </ProtectedRoute>
        ),
        children: [
          {
            path: 'assets',
            element: <AssetDashboard />,
          },
          {
            path: 'members',
            element: <MemberManagement />,
          },
        ],
      },
    ],
  },
  {
    path: '/auth',
    element: <AuthLayout />,
    children: [
      {
        path: 'login',
        element: <LoginPage />,
      },
      {
        path: 'register',
        element: <RegisterPage />,
      },
    ],
  },
]);
```

### API Service Layer

```typescript
// services/apiClient.ts - Centralized API configuration
import axios from 'axios';
import { useAuthStore } from '@/stores/authStore';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 30000,
});

// Request interceptor for auth
apiClient.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    if (error.response?.status === 401) {
      // Token refresh logic
      const refreshed = await authService.refreshToken();
      if (refreshed) {
        return apiClient.request(error.config);
      }
      // Redirect to login
      window.location.href = '/auth/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

## Message Queue Architecture (AWS SQS)

### SQS Configuration

**Queue Settings:**
```typescript
const queueConfig = {
  // Message handling
  VisibilityTimeout: 300,           // 5 minutes for processing
  MessageRetentionPeriod: 1209600,  // 14 days max retention
  ReceiveMessageWaitTime: 20,       // Long polling
  MaximumMessageSize: 262144,       // 256 KB
  
  // Dead Letter Queue
  RedrivePolicy: {
    deadLetterTargetArn: 'arn:aws:sqs:us-west-1:xxx:dlq',
    maxReceiveCount: 3              // 3 attempts before DLQ
  }
};
```

**CloudWatch Monitoring:**
```typescript
const alarms = {
  QueueDepth: { 
    threshold: 1000, 
    action: 'scale-workers' 
  },
  OldestMessage: { 
    threshold: 3600,  // 1 hour
    action: 'alert' 
  },
  DLQMessages: { 
    threshold: 1, 
    action: 'immediate-alert' 
  }
};
```

### Idempotent Message Processing

**Implementation Pattern:**
```typescript
@Injectable()
export class IdempotencyService {
  constructor(
    private readonly redis: Redis,
    private readonly lockService: LockService
  ) {}

  async processMessage<T>(
    messageId: string,
    handler: () => Promise<T>
  ): Promise<T | null> {
    // Check if already processed
    const processed = await this.redis.get(`processed:${messageId}`);
    if (processed) return null;
    
    // Acquire distributed lock
    const lock = await this.lockService.acquire(`lock:${messageId}`, 30000);
    if (!lock) return null;
    
    try {
      // Process message
      const result = await handler();
      
      // Mark as processed (TTL = message retention)
      await this.redis.setex(`processed:${messageId}`, 1209600, '1');
      
      return result;
    } finally {
      await lock.release();
    }
  }
}

// Usage in message handlers
@Injectable()
export class StripeWebhookHandler {
  async handleWebhook(message: SQSMessage) {
    const event = JSON.parse(message.Body) as Stripe.Event;
    
    return this.idempotencyService.processMessage(
      event.id,
      async () => {
        // Process only once, even if webhook delivered multiple times
        switch (event.type) {
          case 'payment_intent.succeeded':
            await this.handlePaymentSuccess(event);
            break;
          // ... other event types
        }
      }
    );
  }
}
```

**Use Cases:**
- Stripe webhook processing
- Document processing completion
- Integration sync completion
- Email/SMS notifications

## Translation System (Simple English/Spanish)

### Implementation Approach

**Not Full i18n:** Simple translation for US market only

```typescript
// shared/translations/index.ts
export const translations = {
  en: {
    common: {
      save: 'Save',
      cancel: 'Cancel',
      delete: 'Delete',
      confirm: 'Confirm'
    },
    errors: {
      ASSET_NOT_FOUND: 'Asset not found',
      INSUFFICIENT_PERMISSIONS: 'Insufficient permissions',
      PAYMENT_FAILED: 'Payment failed'
    },
    assets: {
      title: 'Assets',
      addNew: 'Add New Asset',
      types: {
        real_estate: 'Real Estate',
        vehicle: 'Vehicle',
        financial_account: 'Financial Account'
      }
    }
  },
  es: {
    common: {
      save: 'Guardar',
      cancel: 'Cancelar',
      delete: 'Eliminar',
      confirm: 'Confirmar'
    },
    errors: {
      ASSET_NOT_FOUND: 'Activo no encontrado',
      INSUFFICIENT_PERMISSIONS: 'Permisos insuficientes',
      PAYMENT_FAILED: 'Pago fallido'
    },
    assets: {
      title: 'Activos',
      addNew: 'Agregar Nuevo Activo',
      types: {
        real_estate: 'Bienes Raíces',
        vehicle: 'Vehículo',
        financial_account: 'Cuenta Financiera'
      }
    }
  }
};

// Simple hook - no heavy i18n library
export const useTranslation = () => {
  const language = useAppStore(state => state.language);
  const t = (key: string): string => {
    const keys = key.split('.');
    let value: any = translations[language];
    for (const k of keys) {
      value = value?.[k];
    }
    return value || key;
  };
  return { t, language };
};

// Usage
const AssetList = () => {
  const { t } = useTranslation();
  return (
    <div>
      <h1>{t('assets.title')}</h1>
      <button>{t('assets.addNew')}</button>
    </div>
  );
};
```

**Scope Limitations:**
- No date/time formatting localization
- No number/currency formatting localization  
- No pluralization rules
- No RTL support
- US market only (English/Spanish)

## ⚙️ Backend Architecture

> **🎯 Core Strategy**: Nest.js modular architecture with domain-driven design, dependency injection, and comprehensive guard/interceptor system for enterprise-grade backend services.

**📋 Related ADRs:** [ADR-001: Nest.js over Express](#adr-001-nestjs-over-express-for-backend-framework) | [ADR-002: Database Access](#adr-002-pgtyped--slonik-for-database-access)

**🔗 Related Sections:**
- 🗄️ [Database Access Architecture](#database-access-architecture-pgtyped--slonik) - Database integration
- 🔐 [Authentication and Authorization Guards](#authentication-and-authorization-guards) - Security implementation
- 🔄 [Real-Time WebSocket Layer](#real-time-websocket-layer-with-socketio) - Real-time features
- 📨 [Queue Processing with AWS SQS](#queue-processing-with-aws-sqs) - Async processing

---

### Nest.js Module Architecture
```typescript
// Module structure for Forward Inheritance Platform
src/
├── app.module.ts                 // Root module
├── common/
│   ├── guards/                   // Multi-tenant, FFC, asset guards
│   ├── interceptors/             // Caching, logging, performance
│   ├── pipes/                    // Validation, transformation
│   └── decorators/               // Custom decorators
├── modules/
│   ├── auth/                     // AWS Cognito integration
│   ├── tenants/                  // Multi-tenant management
│   ├── ffcs/                     // Family circles
│   ├── assets/                   // Asset management with 13 types
│   ├── documents/                // Document processing
│   ├── integrations/
│   │   ├── quiltt/              // Financial sync
│   │   ├── builder-io/          // CMS integration
│   │   └── vanta/               // Compliance
│   └── queues/                   // SQS message processors
└── database/
    ├── slonik.provider.ts        // Database connection
    └── repositories/             // Stored procedure calls
```

### NestJS Controller Implementation

#### Complete Production-Ready Controller Example

```typescript
// ffcs.controller.ts - Enterprise-grade NestJS controller
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  UseInterceptors,
  UsePipes,
  ValidationPipe,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  Logger,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
  UnprocessableEntityException
} from '@nestjs/common';
import { 
  ApiTags, 
  ApiOperation, 
  ApiResponse, 
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { TenantIsolationGuard } from '../common/guards/tenant-isolation.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { FFCMembershipGuard } from './guards/ffc-membership.guard';
import { CacheInterceptor } from '../common/interceptors/cache.interceptor';
import { LoggingInterceptor } from '../common/interceptors/logging.interceptor';
import { TransformInterceptor } from '../common/interceptors/transform.interceptor';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FFCService } from './ffc.service';
import { CreateFFCDto } from './dto/create-ffc.dto';
import { UpdateFFCDto } from './dto/update-ffc.dto';
import { InviteMemberDto } from './dto/invite-member.dto';
import { FFCQueryDto } from './dto/ffc-query.dto';
import { User } from '../users/entities/user.entity';
import { FFC } from './entities/ffc.entity';
import { FFCMember } from './entities/ffc-member.entity';

@ApiTags('Forward Family Circles')
@ApiBearerAuth()
@Controller('api/v1/ffcs')
@UseGuards(JwtAuthGuard, TenantIsolationGuard)
@UseInterceptors(LoggingInterceptor, TransformInterceptor)
export class FFCController {
  private readonly logger = new Logger(FFCController.name);

  constructor(private readonly ffcService: FFCService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Create new Forward Family Circle',
    description: 'Creates a new FFC with the current user as owner and automatically assigns free plan'
  })
  @ApiResponse({ 
    status: 201, 
    description: 'FFC created successfully',
    type: FFC
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid FFC data provided'
  })
  @ApiResponse({ 
    status: 409, 
    description: 'FFC with this name already exists for user'
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async createFFC(
    @Body() createFFCDto: CreateFFCDto,
    @CurrentUser() user: User
  ): Promise<FFC> {
    try {
      this.logger.log(`Creating FFC for user ${user.id}: ${createFFCDto.name}`);
      
      // Check if user already has an FFC with this name
      const existingFFC = await this.ffcService.findByNameAndOwner(
        createFFCDto.name, 
        user.id
      );
      
      if (existingFFC) {
        throw new BadRequestException('FFC with this name already exists');
      }

      const ffc = await this.ffcService.create({
        ...createFFCDto,
        ownerUserId: user.id,
        tenantId: user.tenantId
      });

      this.logger.log(`FFC created successfully: ${ffc.id}`);
      return ffc;
    } catch (error) {
      this.logger.error(`Failed to create FFC: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Get()
  @ApiOperation({ 
    summary: 'Get user\'s FFCs',
    description: 'Retrieves all FFCs where user is owner or member with pagination and filtering'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Items per page (default: 10, max: 100)' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search by FFC name' })
  @ApiQuery({ name: 'role', required: false, enum: ['owner', 'member'], description: 'Filter by user role' })
  @ApiResponse({ 
    status: 200, 
    description: 'FFCs retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { $ref: '#/components/schemas/FFC' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
        totalPages: { type: 'number' }
      }
    }
  })
  @UseInterceptors(CacheInterceptor)
  async getUserFFCs(
    @Query() query: FFCQueryDto,
    @CurrentUser() user: User
  ) {
    try {
      this.logger.log(`Fetching FFCs for user ${user.id}`);
      
      const result = await this.ffcService.findUserFFCs(user.id, {
        page: query.page || 1,
        limit: Math.min(query.limit || 10, 100),
        search: query.search,
        role: query.role
      });

      return {
        data: result.ffcs,
        total: result.total,
        page: result.page,
        limit: result.limit,
        totalPages: Math.ceil(result.total / result.limit)
      };
    } catch (error) {
      this.logger.error(`Failed to fetch user FFCs: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Get(':ffcId')
  @ApiOperation({ 
    summary: 'Get FFC details',
    description: 'Retrieves detailed information about a specific FFC'
  })
  @ApiParam({ name: 'ffcId', type: 'string', format: 'uuid', description: 'FFC unique identifier' })
  @ApiResponse({ 
    status: 200, 
    description: 'FFC details retrieved successfully',
    type: FFC
  })
  @ApiResponse({ 
    status: 404, 
    description: 'FFC not found'
  })
  @ApiResponse({ 
    status: 403, 
    description: 'User not member of this FFC'
  })
  @UseGuards(FFCMembershipGuard)
  @UseInterceptors(CacheInterceptor)
  async getFFCById(
    @Param('ffcId', ParseUUIDPipe) ffcId: string,
    @CurrentUser() user: User
  ): Promise<FFC> {
    try {
      this.logger.log(`Fetching FFC ${ffcId} for user ${user.id}`);
      
      const ffc = await this.ffcService.findByIdWithDetails(ffcId);
      
      if (!ffc) {
        throw new NotFoundException('FFC not found');
      }

      return ffc;
    } catch (error) {
      this.logger.error(`Failed to fetch FFC ${ffcId}: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Put(':ffcId')
  @ApiOperation({ 
    summary: 'Update FFC',
    description: 'Updates FFC information (owner only)'
  })
  @ApiParam({ name: 'ffcId', type: 'string', format: 'uuid' })
  @ApiBody({ type: UpdateFFCDto })
  @ApiResponse({ 
    status: 200, 
    description: 'FFC updated successfully',
    type: FFC
  })
  @ApiResponse({ 
    status: 403, 
    description: 'Only FFC owner can update'
  })
  @Roles('ffc_owner')
  @UseGuards(FFCMembershipGuard, RolesGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async updateFFC(
    @Param('ffcId', ParseUUIDPipe) ffcId: string,
    @Body() updateFFCDto: UpdateFFCDto,
    @CurrentUser() user: User
  ): Promise<FFC> {
    try {
      this.logger.log(`Updating FFC ${ffcId} by user ${user.id}`);
      
      const updatedFFC = await this.ffcService.update(ffcId, updateFFCDto);
      
      this.logger.log(`FFC ${ffcId} updated successfully`);
      return updatedFFC;
    } catch (error) {
      this.logger.error(`Failed to update FFC ${ffcId}: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Post(':ffcId/members/invite')
  @HttpCode(HttpStatus.ACCEPTED)
  @ApiOperation({ 
    summary: 'Invite member to FFC',
    description: 'Sends invitation with dual-channel verification (email + SMS)'
  })
  @ApiParam({ name: 'ffcId', type: 'string', format: 'uuid' })
  @ApiBody({ type: InviteMemberDto })
  @ApiResponse({ 
    status: 202, 
    description: 'Invitation sent successfully'
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid invitation data or user already invited'
  })
  @Roles('ffc_owner', 'ffc_admin')
  @UseGuards(FFCMembershipGuard, RolesGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async inviteMember(
    @Param('ffcId', ParseUUIDPipe) ffcId: string,
    @Body() inviteMemberDto: InviteMemberDto,
    @CurrentUser() user: User
  ): Promise<{ message: string; invitationId: string }> {
    try {
      this.logger.log(`Inviting member to FFC ${ffcId} by user ${user.id}`);
      
      // Validate email format and phone number
      if (!this.isValidEmail(inviteMemberDto.email)) {
        throw new BadRequestException('Invalid email format');
      }
      
      if (!this.isValidPhoneNumber(inviteMemberDto.phoneNumber)) {
        throw new BadRequestException('Invalid phone number format');
      }

      // Check if user is already a member or has pending invitation
      const existingMember = await this.ffcService.findMemberByEmail(
        ffcId, 
        inviteMemberDto.email
      );
      
      if (existingMember) {
        throw new BadRequestException('User is already a member or has pending invitation');
      }

      const invitation = await this.ffcService.inviteMember(ffcId, {
        ...inviteMemberDto,
        invitedByUserId: user.id
      });

      this.logger.log(`Invitation sent successfully: ${invitation.id}`);
      
      return {
        message: 'Invitation sent successfully. The user will receive email and SMS verification.',
        invitationId: invitation.id
      };
    } catch (error) {
      this.logger.error(`Failed to invite member to FFC ${ffcId}: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Get(':ffcId/members')
  @ApiOperation({ 
    summary: 'Get FFC members',
    description: 'Retrieves all members of the FFC with their roles and status'
  })
  @ApiParam({ name: 'ffcId', type: 'string', format: 'uuid' })
  @ApiResponse({ 
    status: 200, 
    description: 'FFC members retrieved successfully',
    type: [FFCMember]
  })
  @UseGuards(FFCMembershipGuard)
  @UseInterceptors(CacheInterceptor)
  async getFFCMembers(
    @Param('ffcId', ParseUUIDPipe) ffcId: string,
    @CurrentUser() user: User
  ): Promise<FFCMember[]> {
    try {
      this.logger.log(`Fetching members for FFC ${ffcId}`);
      
      const members = await this.ffcService.getMembers(ffcId);
      
      return members;
    } catch (error) {
      this.logger.error(`Failed to fetch FFC members: ${error.message}`, error.stack);
      throw error;
    }
  }

  @Delete(':ffcId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ 
    summary: 'Delete FFC',
    description: 'Permanently deletes FFC and all associated data (owner only)'
  })
  @ApiParam({ name: 'ffcId', type: 'string', format: 'uuid' })
  @ApiResponse({ 
    status: 204, 
    description: 'FFC deleted successfully'
  })
  @ApiResponse({ 
    status: 403, 
    description: 'Only FFC owner can delete'
  })
  @Roles('ffc_owner')
  @UseGuards(FFCMembershipGuard, RolesGuard)
  async deleteFFC(
    @Param('ffcId', ParseUUIDPipe) ffcId: string,
    @CurrentUser() user: User
  ): Promise<void> {
    try {
      this.logger.log(`Deleting FFC ${ffcId} by owner ${user.id}`);
      
      // Verify FFC has no active subscriptions or assets
      const canDelete = await this.ffcService.canDelete(ffcId);
      
      if (!canDelete.allowed) {
        throw new UnprocessableEntityException(
          `Cannot delete FFC: ${canDelete.reason}`
        );
      }

      await this.ffcService.delete(ffcId);
      
      this.logger.log(`FFC ${ffcId} deleted successfully`);
    } catch (error) {
      this.logger.error(`Failed to delete FFC ${ffcId}: ${error.message}`, error.stack);
      throw error;
    }
  }

  // Utility methods
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  private isValidPhoneNumber(phone: string): boolean {
    // US phone number validation
    const phoneRegex = /^\+1[2-9]\d{2}[2-9]\d{2}\d{4}$/;
    return phoneRegex.test(phone);
  }
}

// Supporting DTOs and Guards

// dto/create-ffc.dto.ts
import { IsString, IsOptional, IsNotEmpty, MaxLength, IsUrl } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateFFCDto {
  @ApiProperty({ 
    description: 'Forward Family Circle name',
    example: 'Smith Family Heritage',
    maxLength: 100
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @ApiProperty({ 
    description: 'Family description',
    example: 'Our family\'s inheritance and legacy planning circle',
    required: false,
    maxLength: 500
  })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;

  @ApiProperty({ 
    description: 'Family photo URL',
    example: 'https://s3.amazonaws.com/fwd-photos/smith-family.jpg',
    required: false
  })
  @IsUrl()
  @IsOptional()
  familyPhotoUrl?: string;
}

// guards/ffc-membership.guard.ts
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { FFCService } from '../ffc.service';

@Injectable()
export class FFCMembershipGuard implements CanActivate {
  constructor(private ffcService: FFCService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const ffcId = request.params.ffcId;

    if (!ffcId || !user) {
      throw new ForbiddenException('Invalid request context');
    }

    const isMember = await this.ffcService.isUserMember(ffcId, user.id);
    
    if (!isMember) {
      throw new ForbiddenException('User is not a member of this FFC');
    }

    return true;
  }
}

@ApiTags('FFCs')
@ApiBearerAuth()
@Controller('ffcs')
@UseGuards(JwtAuthGuard, TenantIsolationGuard, RolesGuard)
@UseInterceptors(LoggingInterceptor)
export class FFCController {
  private readonly logger = new Logger(FFCController.name);

  constructor(private readonly ffcService: FFCService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new FFC' })
  @ApiResponse({ status: 201, description: 'FFC created successfully', type: FFC })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async create(
    @Body() createFFCDto: CreateFFCDto,
    @CurrentUser() user: User,
  ): Promise<FFC> {
    this.logger.log(`Creating FFC for user ${user.id}`);
    return this.ffcService.create(createFFCDto, user);
  }

  @Get()
  @UseInterceptors(CacheInterceptor)
  @ApiOperation({ summary: 'List all FFCs for current user' })
  @ApiResponse({ status: 200, description: 'List of FFCs', type: [FFC] })
  async findAll(
    @CurrentUser() user: User,
    @Query('page', { transform: (val) => parseInt(val, 10) || 1 }) page: number,
    @Query('limit', { transform: (val) => parseInt(val, 10) || 10 }) limit: number,
  ) {
    return this.ffcService.findAllForUser(user.id, { page, limit });
  }

  @Get(':id')
  @UseInterceptors(CacheInterceptor)
  @ApiOperation({ summary: 'Get FFC by ID' })
  @ApiResponse({ status: 200, description: 'FFC details', type: FFC })
  @ApiResponse({ status: 404, description: 'FFC not found' })
  async findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: User,
  ): Promise<FFC> {
    return this.ffcService.findOne(id, user.id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update FFC' })
  @ApiResponse({ status: 200, description: 'FFC updated successfully', type: FFC })
  @ApiResponse({ status: 404, description: 'FFC not found' })
  @Roles('admin', 'owner')
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateFFCDto: UpdateFFCDto,
    @CurrentUser() user: User,
  ): Promise<FFC> {
    return this.ffcService.update(id, updateFFCDto, user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete FFC' })
  @ApiResponse({ status: 204, description: 'FFC deleted successfully' })
  @ApiResponse({ status: 404, description: 'FFC not found' })
  @Roles('owner')
  async remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: User,
  ): Promise<void> {
    await this.ffcService.remove(id, user.id);
  }

  @Post(':id/members')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Invite member to FFC' })
  @ApiResponse({ status: 201, description: 'Invitation sent successfully' })
  @Roles('admin', 'owner')
  async inviteMember(
    @Param('id', ParseUUIDPipe) ffcId: string,
    @Body() inviteMemberDto: InviteMemberDto,
    @CurrentUser() user: User,
  ) {
    return this.ffcService.inviteMember(ffcId, inviteMemberDto, user);
  }
}

// DTOs with class-validator decorators
// create-ffc.dto.ts
import { IsNotEmpty, IsString, MaxLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateFFCDto {
  @ApiProperty({ description: 'Name of the FFC', maxLength: 100 })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: 'Description of the FFC', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}

// Service implementation with database calls
// ffc.service.ts
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectSlonik } from 'nestjs-slonik';
import { DatabasePool, sql } from 'slonik';
import { CreateFFCDto } from './dto/create-ffc.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class FFCService {
  constructor(@InjectSlonik() private readonly pool: DatabasePool) {}

  async create(createFFCDto: CreateFFCDto, user: User) {
    const result = await this.pool.connect(async (connection) => {
      // Set session context for RLS
      await connection.query(sql`
        SELECT sp_set_session_context(${user.tenantId}::int, ${user.id}::uuid)
      `);
      
      // Call stored procedure
      return connection.one(sql`
        SELECT * FROM sp_create_ffc(
          ${user.tenantId}::int,
          ${user.id}::uuid,
          ${createFFCDto.name}::text,
          ${createFFCDto.description || null}::text
        )
      `);
    });

    return result;
  }

  async findAllForUser(userId: string, pagination: { page: number; limit: number }) {
    const offset = (pagination.page - 1) * pagination.limit;
    
    return this.pool.connect(async (connection) => {
      const ffcs = await connection.query(sql`
        SELECT f.*, sp_get_ffc_summary(f.id, ${userId}::uuid) as summary
        FROM fwd_family_circles f
        JOIN ffc_personas fp ON f.id = fp.ffc_id
        JOIN personas p ON fp.persona_id = p.id
        WHERE p.user_id = ${userId}::uuid
        LIMIT ${pagination.limit}
        OFFSET ${offset}
      `);
      
      return ffcs.rows;
    });
  }

  async findOne(id: string, userId: string) {
    const ffc = await this.pool.maybeOne(sql`
      SELECT * FROM sp_get_ffc_summary(${id}::uuid, ${userId}::uuid)
    `);

    if (!ffc) {
      throw new NotFoundException(`FFC with ID ${id} not found`);
    }

    return ffc;
  }
}
```

### AWS Step Functions Document Processing

#### Document Processing Pipeline Overview

```mermaid
flowchart TD
    A[User Uploads Document] --> B[Store in S3 Original Bucket]
    B --> C[Trigger Step Function]
    C --> D[Validate Document]
    D --> E{Valid Document?}
    E -->|No| F[Return Error]
    E -->|Yes| G[Extract Text with Textract]
    G --> H[Detect PII with Comprehend]
    H --> I{PII Found?}
    I -->|No| J[Copy to Processed Bucket]
    I -->|Yes| K[Mask PII Content]
    K --> L[Generate Masked Version]
    L --> M[Store Both Versions]
    M --> N[Update Database Records]
    J --> N
    N --> O[Send Completion Notification]
    
    style A fill:#e1f5fe
    style H fill:#fff3e0
    style K fill:#ffebee
    style N fill:#e8f5e8
```

#### Detailed Step Function State Machine

```mermaid
stateDiagram-v2
    [*] --> ValidateDocument
    ValidateDocument --> CheckFileType
    
    CheckFileType --> TextractDocument: PDF/Image
    CheckFileType --> DirectPIIDetection: Text File
    CheckFileType --> UnsupportedFormat: Other
    
    TextractDocument --> ComprehendPII
    DirectPIIDetection --> ComprehendPII
    UnsupportedFormat --> Failed
    
    ComprehendPII --> AnalyzePII
    AnalyzePII --> HasPII: PII Detected
    AnalyzePII --> NoPII: Clean Document
    
    HasPII --> MaskPII
    MaskPII --> GenerateRedacted
    GenerateRedacted --> StoreBothVersions
    
    NoPII --> StoreSingleVersion
    
    StoreBothVersions --> UpdateDatabase
    StoreSingleVersion --> UpdateDatabase
    UpdateDatabase --> NotifyCompletion
    NotifyCompletion --> [*]
    
    Failed --> NotifyError
    NotifyError --> [*]
```

#### PII Detection and Masking Flow

```mermaid
sequenceDiagram
    participant U as User
    participant S3 as S3 Storage
    participant SF as Step Functions
    participant T as Textract
    participant C as Comprehend
    participant L as Lambda
    participant DB as Database
    participant SQS as Notification Queue

    Note over U,SQS: Document Upload & Processing
    
    U->>S3: Upload document
    S3->>SF: Trigger Step Function
    
    Note over SF: Document Validation
    SF->>S3: Validate file exists
    SF->>SF: Check file type/size
    
    Note over SF,T: Text Extraction
    SF->>T: Extract text from document
    T->>SF: Return extracted text
    
    Note over SF,C: PII Detection
    SF->>C: Analyze text for PII
    C->>SF: Return PII entities
    
    alt PII Found
        Note over SF,L: PII Masking
        SF->>L: Invoke masking function
        L->>L: Replace PII with tokens
        L->>S3: Store masked document
        L->>S3: Store original (encrypted)
        L->>SF: Return success
    else No PII
        SF->>S3: Store document (encrypted)
    end
    
    Note over SF,DB: Update Records
    SF->>DB: Update asset document status
    SF->>SQS: Send completion notification
    SQS->>U: Notify processing complete
```

**Step Function Definition:**

```json
{
  "Comment": "PII Detection and Document Encryption Pipeline",
  "StartAt": "ValidateDocument",
  "States": {
    "ValidateDocument": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:ValidateDocument",
      "Next": "StartComprehendPiiDetection"
    },
    "StartComprehendPiiDetection": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:comprehend:startPiiEntitiesDetectionJob",
      "Parameters": {
        "DataAccessRoleArn": "${ComprehendRole}",
        "InputDataConfig": {
          "S3Uri": "s3://forward-documents-raw/${$.originalS3Key}"
        },
        "OutputDataConfig": {
          "S3Uri": "s3://forward-documents-masked/",
          "KmsKeyId": "${KmsKeyArn}"
        },
        "Mode": "ONLY_REDACTION",
        "RedactionConfig": {
          "PiiEntityTypes": ["SSN", "CREDIT_DEBIT_NUMBER", "BANK_ACCOUNT_NUMBER", "DRIVER_ID", "PASSPORT_NUMBER"]
        },
        "LanguageCode": "en"
      },
      "Next": "WaitForComprehendJob"
    },
    "WaitForComprehendJob": {
      "Type": "Wait",
      "Seconds": 30,
      "Next": "CheckComprehendJobStatus"
    },
    "CheckComprehendJobStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:comprehend:describePiiEntitiesDetectionJob",
      "Next": "IsJobComplete"
    },
    "IsJobComplete": {
      "Type": "Choice",
      "Choices": [{
        "Variable": "$.JobStatus",
        "StringEquals": "COMPLETED",
        "Next": "UpdateDocumentMetadata"
      }],
      "Default": "WaitForComprehendJob"
    },
    "UpdateDocumentMetadata": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:UpdateDocumentMetadata",
      "End": true
    }
  }
}
```

### Database Architecture with Nest.js

> **📋 Foundation**: This section shows NestJS implementation details. For complete database architecture including pgTyped configuration and SQL organization, see [🗄️ Database Access Architecture](#🗄️-database-access-architecture-pgtyped--slonik).

```typescript
// Slonik provider for stored procedure execution
@Injectable()
export class SlonikProvider {
  private readonly pool: DatabasePool;

  constructor(@Inject('DATABASE_CONFIG') private config: DatabaseConfig) {
    this.pool = createPool(config.url, {
      interceptors: [
        ...createInterceptorPreset(),
        {
          beforePoolConnection: async (context, connection) => {
            const tenantId = context.connectionContext?.tenantId;
            const userId = context.connectionContext?.userId;
            if (tenantId && userId) {
              await connection.query(sql`
                SELECT sp_set_session_context(${tenantId}::int, ${userId}::uuid)
              `);
            }
          },
        },
      ],
      maximumPoolSize: 30,
    });
  }

  async executeStoredProcedure<T>(
    procedureName: string,
    params: any[],
    context: RequestContext
  ): Promise<T> {
    return this.pool.connect(async (connection) => {
      await connection.query(sql`
        SELECT sp_set_session_context(${context.tenantId}::int, ${context.userId}::uuid)
      `);
      return connection.one(sql`SELECT * FROM ${sql.identifier([procedureName])}(${sql.join(params, sql`, `)})`);
    });
  }
}
```

### Authentication and Authorization Guards
```typescript
// Multi-tenant isolation guard
@Injectable()
export class TenantIsolationGuard implements CanActivate {
  constructor(
    private readonly cognitoService: CognitoService,
    private readonly tenantsService: TenantsService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    
    const decoded = await this.cognitoService.verifyToken(token);
    const tenant = await this.tenantsService.findByName(decoded['custom:tenant_name']);
    
    request.user = {
      id: decoded.sub,
      tenantId: tenant.id,
      cognitoUserId: decoded.sub,
    };
    
    return true;
  }
}
```

#### Authentication Implementation Reference

> **📝 Complete Implementation**: For detailed authentication flows including user registration, login, MFA setup, and JWT validation, see the comprehensive [🔐 Authentication Architecture](#🔐-authentication-architecture-phased-implementation) section.

The authentication implementation includes:
- User registration and email verification
- Login flows with MFA support  
- JWT token validation and refresh
- Password reset functionality
- Tenant isolation guards
import { Injectable } from '@nestjs/common';

@Injectable()
export class RegistrationService {
  private cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' });
  
  async registerUser(dto: RegisterUserDto) {
    // Step 1: Register user with Cognito
    const signUpCommand = new SignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: dto.email,
      Password: dto.password,
      UserAttributes: [
        { Name: 'email', Value: dto.email },
        { Name: 'phone_number', Value: dto.phoneNumber },
        { Name: 'given_name', Value: dto.firstName },
        { Name: 'family_name', Value: dto.lastName },
        { Name: 'custom:tenant_id', Value: dto.tenantId.toString() },
      ],
    });
    
    const cognitoResponse = await this.cognitoClient.send(signUpCommand);
    
    // Step 2: Create user record in database (after email verification)
    // This happens in the confirmRegistration method below
    
    return {
      userSub: cognitoResponse.UserSub,
      codeDeliveryDetails: cognitoResponse.CodeDeliveryDetails,
    };
  }
  
  async confirmRegistration(email: string, code: string) {
    // Step 1: Confirm signup with Cognito
    const confirmCommand = new ConfirmSignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      ConfirmationCode: code,
    });
    
    await this.cognitoClient.send(confirmCommand);
    
    // Step 2: Get user details from Cognito
    const userDetails = await this.getUserFromCognito(email);
    
    // Step 3: Create user in database
    await this.databaseService.query(sql`
      SELECT * FROM sp_create_user_from_cognito(
        ${userDetails.tenantId}::int,
        ${userDetails.sub}::text,
        ${userDetails.email}::text,
        ${userDetails.email}::text,
        ${userDetails.phoneNumber}::text,
        ${userDetails.firstName}::text,
        ${userDetails.lastName}::text
      )
    `);
    
    return { success: true };
  }
}
```

#### User Login Flow (Standard)
```typescript
// auth.service.ts
import { 
  CognitoIdentityProviderClient, 
  InitiateAuthCommand,
  RespondToAuthChallengeCommand 
} from '@aws-sdk/client-cognito-identity-provider';

@Injectable()
export class AuthService {
  private cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' });
  
  async login(email: string, password: string) {
    try {
      // Step 1: Initiate authentication with Cognito
      const authCommand = new InitiateAuthCommand({
        AuthFlow: 'USER_SRP_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
          USERNAME: email,
          PASSWORD: password,
        },
      });
      
      const authResponse = await this.cognitoClient.send(authCommand);
      
      // Step 2: Handle MFA challenge if required
      if (authResponse.ChallengeName === 'SMS_MFA') {
        return {
          requiresMfa: true,
          session: authResponse.Session,
          challengeType: 'SMS_MFA',
        };
      }
      
      // Step 3: Extract tokens
      const tokens = authResponse.AuthenticationResult;
      
      // Step 4: Decode ID token to get user claims
      const idTokenPayload = this.decodeToken(tokens.IdToken);
      
      // Step 5: Log authentication event
      await this.auditService.logAuthEvent(idTokenPayload.sub, 'LOGIN_SUCCESS');
      
      return {
        accessToken: tokens.AccessToken,
        idToken: tokens.IdToken,
        refreshToken: tokens.RefreshToken,
        expiresIn: tokens.ExpiresIn,
        user: {
          id: idTokenPayload.sub,
          email: idTokenPayload.email,
          tenantId: idTokenPayload['custom:tenant_id'],
        },
      };
    } catch (error) {
      await this.auditService.logAuthEvent(email, 'LOGIN_FAILED');
      throw new UnauthorizedException('Invalid credentials');
    }
  }
  
  async refreshTokens(refreshToken: string) {
    const command = new InitiateAuthCommand({
      AuthFlow: 'REFRESH_TOKEN_AUTH',
      ClientId: process.env.COGNITO_CLIENT_ID,
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
      },
    });
    
    const response = await this.cognitoClient.send(command);
    return response.AuthenticationResult;
  }
  
  async logout(accessToken: string) {
    // Cognito doesn't support token revocation for user pools
    // Instead, use AdminUserGlobalSignOut for force logout
    // Or maintain a token blacklist with short TTL in cache
    await this.cacheService.blacklistToken(accessToken, 3600); // 1 hour TTL
  }
}
```

#### MFA Setup and Authentication Flow
```typescript
// mfa.service.ts
import { 
  AssociateSoftwareTokenCommand,
  VerifySoftwareTokenCommand,
  SetUserMFAPreferenceCommand,
  RespondToAuthChallengeCommand
} from '@aws-sdk/client-cognito-identity-provider';

@Injectable()
export class MfaService {
  private cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' });
  
  // Setup TOTP MFA
  async setupTotpMfa(accessToken: string) {
    // Step 1: Associate software token
    const associateCommand = new AssociateSoftwareTokenCommand({
      AccessToken: accessToken,
    });
    
    const response = await this.cognitoClient.send(associateCommand);
    
    // Step 2: Generate QR code URL for authenticator app
    const otpauthUrl = `otpauth://totp/FWD-INH:${email}?secret=${response.SecretCode}&issuer=FWD-INH`;
    const qrCodeDataUrl = await QRCode.toDataURL(otpauthUrl);
    
    return {
      secretCode: response.SecretCode,
      qrCode: qrCodeDataUrl,
      session: response.Session,
    };
  }
  
  // Verify TOTP token and enable MFA
  async verifyTotpToken(accessToken: string, totpCode: string, session: string) {
    // Step 1: Verify the TOTP code
    const verifyCommand = new VerifySoftwareTokenCommand({
      AccessToken: accessToken,
      UserCode: totpCode,
      Session: session,
    });
    
    await this.cognitoClient.send(verifyCommand);
    
    // Step 2: Set MFA preference
    const preferenceCommand = new SetUserMFAPreferenceCommand({
      AccessToken: accessToken,
      SoftwareTokenMfaSettings: {
        Enabled: true,
        PreferredMfa: true,
      },
    });
    
    await this.cognitoClient.send(preferenceCommand);
    
    return { mfaEnabled: true };
  }
  
  // Complete MFA challenge during login
  async completeMfaChallenge(session: string, mfaCode: string, challengeType: string) {
    const challengeResponses: any = {};
    
    if (challengeType === 'SMS_MFA') {
      challengeResponses.SMS_MFA_CODE = mfaCode;
    } else if (challengeType === 'SOFTWARE_TOKEN_MFA') {
      challengeResponses.SOFTWARE_TOKEN_MFA_CODE = mfaCode;
    }
    
    const command = new RespondToAuthChallengeCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      ChallengeName: challengeType,
      Session: session,
      ChallengeResponses: challengeResponses,
    });
    
    const response = await this.cognitoClient.send(command);
    
    return {
      accessToken: response.AuthenticationResult.AccessToken,
      idToken: response.AuthenticationResult.IdToken,
      refreshToken: response.AuthenticationResult.RefreshToken,
    };
  }
}
```

#### Password Reset Flow
```typescript
// password-reset.service.ts
import { 
  ForgotPasswordCommand,
  ConfirmForgotPasswordCommand 
} from '@aws-sdk/client-cognito-identity-provider';

@Injectable()
export class PasswordResetService {
  private cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' });
  
  async initiatePasswordReset(email: string) {
    const command = new ForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
    });
    
    const response = await this.cognitoClient.send(command);
    
    await this.auditService.logAuthEvent(email, 'PASSWORD_RESET_INITIATED');
    
    return {
      codeDeliveryDetails: response.CodeDeliveryDetails,
    };
  }
  
  async confirmPasswordReset(email: string, code: string, newPassword: string) {
    const command = new ConfirmForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      ConfirmationCode: code,
      Password: newPassword,
    });
    
    await this.cognitoClient.send(command);
    
    await this.auditService.logAuthEvent(email, 'PASSWORD_RESET_COMPLETED');
    
    return { success: true };
  }
}
```

#### JWT Token Validation Middleware
```typescript
// jwt.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { CognitoJwtVerifier } from 'aws-jwt-verify';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private verifier = CognitoJwtVerifier.create({
    userPoolId: process.env.COGNITO_USER_POOL_ID,
    tokenUse: 'access',
    clientId: process.env.COGNITO_CLIENT_ID,
  });
  
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    
    if (!token) {
      return false;
    }
    
    try {
      // Verify token with Cognito public keys
      const payload = await this.verifier.verify(token);
      
      // Add user info to request
      request.user = {
        id: payload.sub,
        email: payload.username,
        tenantId: payload['custom:tenant_id'],
        scope: payload.scope,
      };
      
      return true;
    } catch (error) {
      return false;
    }
  }
  
  private extractTokenFromHeader(request: any): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

### Progressive Caching Strategy (Cost-Optimized)

#### Caching Progression Path
1. **Phase 1 (0-5K families)**: In-memory caching only - $0/month
2. **Phase 2 (5K-20K families)**: DynamoDB for sessions - $5-10/month  
3. **Phase 3 (20K+ families)**: Upstash Redis - $10-30/month pay-per-request
4. **Phase 4 (Enterprise)**: ElastiCache only if required - $150+/month

#### Cost Comparison
- **In-Memory**: $0/month (uses existing compute)
- **DynamoDB**: $0.25/GB/month + minimal request costs
- **Upstash Redis**: $0.20 per 100K commands (serverless pricing)
- **ElastiCache**: $150-500/month (always-on instances)

#### Rationale
- **90% Cost Reduction**: DynamoDB/Upstash costs 10% of ElastiCache
- **Pay-Per-Use**: Only pay for actual usage, not idle capacity
- **Progressive Scaling**: Start free, scale costs with revenue
- **No Operations Overhead**: All options are fully managed

#### Implementation
```typescript
// cache/in-memory-cache.service.ts
@Injectable()
export class InMemoryCacheService implements OnModuleInit {
  private permissionCache = new Map<string, PermissionSet>();
  private ffcMembershipCache = new Map<string, Set<string>>();
  private assetCache = new LRUCache<string, Asset>({
    max: 10000, // Maximum entries
    ttl: 1000 * 60 * 5, // 5 minute TTL
    updateAgeOnGet: true,
  });
  
  constructor(
    @Inject('DATABASE_POOL') private pool: DatabasePool,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async onModuleInit() {
    // Warm cache at startup
    await this.warmCache();
    
    // Refresh critical data every 5 minutes
    setInterval(() => this.refreshPermissions(), 5 * 60 * 1000);
    
    // Listen for cache invalidation events
    this.eventEmitter.on('cache.invalidate.*', (event) => {
      this.handleInvalidation(event);
    });
  }

  private async warmCache() {
    const startTime = Date.now();
    
    // Load frequently accessed permissions
    // Note: Permission system not implemented as stored procedures
    // Use RLS policies or implement custom permission queries
    const permissions = await this.pool.query(sql`
      SELECT * FROM permissions WHERE active = true
    `);
    
    // Build permission cache
    permissions.rows.forEach(p => {
      const key = `perm:${p.tenant_id}:${p.user_id}:${p.resource_id}`;
      this.permissionCache.set(key, {
        permissions: p.permissions,
        expiresAt: Date.now() + 300000, // 5 minutes
      });
    });
    
    // Load FFC memberships
    const memberships = await this.pool.query(sql`
      SELECT fp.ffc_id, p.user_id 
      FROM ffc_personas fp
      JOIN personas p ON fp.persona_id = p.id
    `);
    
    // Build membership cache
    memberships.rows.forEach(m => {
      const key = `ffc:${m.ffc_id}`;
      if (!this.ffcMembershipCache.has(key)) {
        this.ffcMembershipCache.set(key, new Set());
      }
      this.ffcMembershipCache.get(key).add(m.user_id);
    });
    
    this.logger.log(`Cache warmed in ${Date.now() - startTime}ms`);
  }

  async checkPermission(
    tenantId: number,
    userId: string,
    resourceId: string,
    permission: string
  ): Promise<boolean> {
    const key = `perm:${tenantId}:${userId}:${resourceId}`;
    
    // Check cache first
    const cached = this.permissionCache.get(key);
    if (cached && cached.expiresAt > Date.now()) {
      return cached.permissions.includes(permission);
    }
    
    // Cache miss - fetch from DB with tenant context
    const result = await this.pool.connect(async (connection) => {
      await connection.query(sql`
        SELECT sp_set_session_context(${tenantId}::int, ${userId}::uuid)
      `);
      
      // Note: Permission checking not implemented as stored procedure
      // Use RLS policies or implement custom logic
      return connection.one(sql`
        SELECT EXISTS(
          SELECT 1 FROM permissions 
          WHERE user_id = ${userId}::uuid
          AND resource_id = ${resourceId}::uuid
          AND permission_type = ${permission}::text
        ) as has_permission
      `);
    });
    
    // Update cache
    this.permissionCache.set(key, {
      permissions: result.has_permission ? [permission] : [],
      expiresAt: Date.now() + 300000,
    });
    
    return result.has_permission;
  }

  // Invalidation on write operations
  invalidatePermissions(userId: string, resourceId?: string) {
    const pattern = resourceId 
      ? `perm:*:${userId}:${resourceId}`
      : `perm:*:${userId}:*`;
      
    for (const key of this.permissionCache.keys()) {
      if (this.matchesPattern(key, pattern)) {
        this.permissionCache.delete(key);
      }
    }
  }
}
```

#### Memory Management
```typescript
// cache/memory-monitor.service.ts
@Injectable()
export class MemoryMonitorService {
  private readonly maxHeapMB = 512; // Conservative limit for t3.medium
  
  @Cron('*/1 * * * *') // Every minute
  checkMemoryUsage() {
    const usage = process.memoryUsage();
    const heapUsedMB = usage.heapUsed / 1024 / 1024;
    
    if (heapUsedMB > this.maxHeapMB) {
      this.logger.warn(`Memory usage high: ${heapUsedMB}MB`);
      
      // Trigger LRU eviction
      this.cacheService.evictLeastRecentlyUsed(0.2); // Remove 20%
      
      // Alert CloudWatch
      this.metricsService.putMetric('HighMemoryUsage', heapUsedMB);
    }
  }
}
```

#### Sticky Sessions Configuration
```typescript
// AWS ALB Target Group configuration for cache consistency
export const targetGroupConfig = {
  targetGroupAttributes: [
    {
      key: 'stickiness.enabled',
      value: 'true'
    },
    {
      key: 'stickiness.type',
      value: 'app_cookie'
    },
    {
      key: 'stickiness.app_cookie.duration_seconds',
      value: '3600' // 1 hour sticky sessions
    },
    {
      key: 'stickiness.app_cookie.cookie_name',
      value: 'FWDSESSION'
    }
  ]
};
```

#### Progressive Enhancement Path

##### Phase 1: In-Memory Cache (Default)
```typescript
// cache/cache.module.ts - Progressive caching strategy
@Module({
  providers: [
    {
      provide: 'CACHE_SERVICE',
      useFactory: (configService: ConfigService) => {
        const cacheType = configService.get('CACHE_TYPE', 'memory');
        
        switch (cacheType) {
          case 'memory':
            return new InMemoryCacheService(); // MVP - $0/month
          case 'dynamodb':
            return new DynamoDBCacheService();  // Phase 2 - $5-10/month
          case 'upstash':
            return new UpstashRedisService();   // Phase 3 - $10-30/month
          case 'hybrid':
            return new HybridCacheService();    // Memory + DynamoDB fallback
          default:
            return new InMemoryCacheService();
        }
      },
      inject: [ConfigService],
    },
  ],
  exports: ['CACHE_SERVICE'],
})
export class CacheModule {}
```

##### Phase 2: DynamoDB Session Storage
```typescript
// cache/dynamodb-cache.service.ts
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand } from '@aws-sdk/lib-dynamodb';

@Injectable()
export class DynamoDBCacheService implements CacheService {
  private client: DynamoDBDocumentClient;
  private tableName = 'fwd-sessions';
  
  constructor() {
    const ddbClient = new DynamoDBClient({ region: process.env.AWS_REGION });
    this.client = DynamoDBDocumentClient.from(ddbClient);
  }

  async get(key: string): Promise<any> {
    const command = new GetCommand({
      TableName: this.tableName,
      Key: { sessionId: key }
    });
    
    const response = await this.client.send(command);
    if (!response.Item || response.Item.ttl < Date.now() / 1000) {
      return null;
    }
    return response.Item.data;
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    const command = new PutCommand({
      TableName: this.tableName,
      Item: {
        sessionId: key,
        data: value,
        ttl: Math.floor(Date.now() / 1000) + ttl,
        createdAt: new Date().toISOString()
      }
    });
    
    await this.client.send(command);
  }
}
```

##### Phase 3: Upstash Redis (Serverless)
```typescript
// cache/upstash-redis.service.ts
import { Redis } from '@upstash/redis';

@Injectable()
export class UpstashRedisService implements CacheService {
  private redis: Redis;
  
  constructor() {
    this.redis = new Redis({
      url: process.env.UPSTASH_REDIS_URL,
      token: process.env.UPSTASH_REDIS_TOKEN,
    });
  }

  async get(key: string): Promise<any> {
    const value = await this.redis.get(key);
    return value ? JSON.parse(value as string) : null;
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    await this.redis.setex(key, ttl, JSON.stringify(value));
  }
  
  // Pay-per-request: ~$0.20 per 100K commands
  // No idle costs, perfect for variable traffic
}
```

### Real-Time WebSocket Layer with Socket.io

> **📋 Foundation**: This section provides detailed implementation. For WebSocket architecture overview and design rationale, see [🔄 Real-time Communication Architecture](#real-time-communication-architecture-websockets).

#### Architecture Overview
The platform uses Socket.io for real-time collaboration features, enabling families to work together on estate planning with live updates.

```typescript
// websocket/websocket.gateway.ts
import { Server, Socket } from 'socket.io';
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { UseGuards } from '@nestjs/common';
import { WsJwtGuard } from '@/guards/ws-jwt.guard';

@WebSocketGateway({
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(','),
    credentials: true,
  },
  namespace: '/realtime',
  transports: ['websocket', 'polling'], // Fallback to polling if WebSocket fails
})
export class CollaborationGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private userSessions = new Map<string, Set<string>>(); // userId -> socketIds
  private socketMetadata = new Map<string, SocketMetadata>();

  async handleConnection(client: Socket) {
    try {
      // Validate JWT token from handshake
      const token = client.handshake.auth.token;
      const user = await this.authService.validateWebSocketToken(token);
      
      if (!user) {
        client.disconnect();
        return;
      }

      // Store socket metadata
      this.socketMetadata.set(client.id, {
        userId: user.id,
        tenantId: user.tenantId,
        ffcIds: [],
        connectedAt: new Date(),
      });

      // Track user sessions
      if (!this.userSessions.has(user.id)) {
        this.userSessions.set(user.id, new Set());
      }
      this.userSessions.get(user.id).add(client.id);

      // Join tenant room for tenant-wide broadcasts
      client.join(`tenant:${user.tenantId}`);

      // Join user's personal room
      client.join(`user:${user.id}`);

      // Load and join user's FFCs
      const userFFCs = await this.ffcService.getUserFFCs(user.id);
      for (const ffc of userFFCs) {
        client.join(`ffc:${ffc.id}`);
        this.socketMetadata.get(client.id).ffcIds.push(ffc.id);
      }

      // Notify others of user presence
      this.broadcastPresence(user.id, 'online');

      this.logger.log(`User ${user.id} connected via socket ${client.id}`);
    } catch (error) {
      this.logger.error('WebSocket connection error:', error);
      client.disconnect();
    }
  }

  async handleDisconnect(client: Socket) {
    const metadata = this.socketMetadata.get(client.id);
    if (metadata) {
      // Remove socket from user sessions
      const userSockets = this.userSessions.get(metadata.userId);
      if (userSockets) {
        userSockets.delete(client.id);
        
        // If user has no more sockets, they're offline
        if (userSockets.size === 0) {
          this.userSessions.delete(metadata.userId);
          this.broadcastPresence(metadata.userId, 'offline');
        }
      }

      this.socketMetadata.delete(client.id);
    }
  }

  // Asset real-time updates
  @SubscribeMessage('asset:subscribe')
  @UseGuards(WsJwtGuard)
  async handleAssetSubscription(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { assetId: string }
  ) {
    const metadata = this.socketMetadata.get(client.id);
    
    // Check permission to view asset
    const hasAccess = await this.permissionService.checkAssetAccess(
      metadata.userId,
      data.assetId
    );

    if (hasAccess) {
      client.join(`asset:${data.assetId}`);
      
      // Send current viewers
      const viewers = this.getAssetViewers(data.assetId);
      client.emit('asset:viewers', { assetId: data.assetId, viewers });
    }
  }

  @SubscribeMessage('asset:unsubscribe')
  async handleAssetUnsubscription(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { assetId: string }
  ) {
    client.leave(`asset:${data.assetId}`);
  }

  // Broadcast asset changes to all viewers
  async broadcastAssetUpdate(assetId: string, update: AssetUpdate) {
    this.server.to(`asset:${assetId}`).emit('asset:updated', {
      assetId,
      update,
      updatedBy: update.userId,
      timestamp: new Date(),
    });
  }

  // Document collaboration
  @SubscribeMessage('document:upload:progress')
  async handleDocumentUploadProgress(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { documentId: string; progress: number }
  ) {
    const metadata = this.socketMetadata.get(client.id);
    
    // Broadcast to FFC members
    for (const ffcId of metadata.ffcIds) {
      client.to(`ffc:${ffcId}`).emit('document:upload:progress', {
        documentId: data.documentId,
        uploadedBy: metadata.userId,
        progress: data.progress,
      });
    }
  }

  // FFC member presence
  @SubscribeMessage('ffc:presence')
  async handleFFCPresence(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { ffcId: string; status: 'viewing' | 'editing' | 'idle' }
  ) {
    const metadata = this.socketMetadata.get(client.id);
    
    // Broadcast presence to FFC members
    client.to(`ffc:${ffcId}`).emit('member:presence', {
      userId: metadata.userId,
      status: data.status,
      timestamp: new Date(),
    });
  }

  // Invitation notifications
  async notifyInvitation(userId: string, invitation: Invitation) {
    this.server.to(`user:${userId}`).emit('invitation:received', {
      invitation,
      timestamp: new Date(),
    });
  }

  // Asset permission changes
  async notifyPermissionChange(assetId: string, change: PermissionChange) {
    this.server.to(`asset:${assetId}`).emit('permission:changed', {
      assetId,
      change,
      timestamp: new Date(),
    });
  }

  private broadcastPresence(userId: string, status: 'online' | 'offline') {
    // Get user's FFCs and broadcast to members
    this.ffcService.getUserFFCs(userId).then(ffcs => {
      for (const ffc of ffcs) {
        this.server.to(`ffc:${ffc.id}`).emit('member:status', {
          userId,
          status,
          timestamp: new Date(),
        });
      }
    });
  }

  private getAssetViewers(assetId: string): string[] {
    const viewers: string[] = [];
    const room = this.server.sockets.adapter.rooms.get(`asset:${assetId}`);
    
    if (room) {
      for (const socketId of room) {
        const metadata = this.socketMetadata.get(socketId);
        if (metadata) {
          viewers.push(metadata.userId);
        }
      }
    }
    
    return [...new Set(viewers)]; // Unique user IDs
  }
}
```

#### Frontend WebSocket Integration
```typescript
// hooks/useWebSocket.ts
import { useEffect, useRef, useCallback } from 'react';
import { io, Socket } from 'socket.io-client';
import { useAuthStore } from '@/stores/authStore';
import { useNotificationStore } from '@/stores/notificationStore';

export function useWebSocket() {
  const socketRef = useRef<Socket | null>(null);
  const token = useAuthStore((state) => state.token);
  const addNotification = useNotificationStore((state) => state.addNotification);

  useEffect(() => {
    if (!token) return;

    // Initialize socket connection
    socketRef.current = io(import.meta.env.VITE_WS_URL, {
      auth: { token },
      transports: ['websocket', 'polling'],
      path: '/realtime',
    });

    const socket = socketRef.current;

    // Connection event handlers
    socket.on('connect', () => {
      console.log('WebSocket connected');
    });

    socket.on('disconnect', (reason) => {
      console.log('WebSocket disconnected:', reason);
      if (reason === 'io server disconnect') {
        // Server initiated disconnect, try to reconnect
        socket.connect();
      }
    });

    // Real-time event handlers
    socket.on('asset:updated', (data) => {
      // Update local state via React Query
      queryClient.invalidateQueries(['assets', data.assetId]);
      
      addNotification({
        type: 'info',
        message: `Asset ${data.assetId} was updated`,
      });
    });

    socket.on('invitation:received', (data) => {
      addNotification({
        type: 'success',
        message: 'You have a new FFC invitation!',
        action: () => navigate('/invitations'),
      });
    });

    socket.on('member:status', (data) => {
      // Update member presence in UI
      updateMemberPresence(data.userId, data.status);
    });

    socket.on('document:upload:progress', (data) => {
      // Update document upload progress in UI
      updateDocumentProgress(data.documentId, data.progress);
    });

    return () => {
      socket.disconnect();
    };
  }, [token]);

  const subscribeToAsset = useCallback((assetId: string) => {
    socketRef.current?.emit('asset:subscribe', { assetId });
  }, []);

  const unsubscribeFromAsset = useCallback((assetId: string) => {
    socketRef.current?.emit('asset:unsubscribe', { assetId });
  }, []);

  const updatePresence = useCallback((ffcId: string, status: string) => {
    socketRef.current?.emit('ffc:presence', { ffcId, status });
  }, []);

  return {
    socket: socketRef.current,
    subscribeToAsset,
    unsubscribeFromAsset,
    updatePresence,
  };
}

// Usage in component
export function AssetDetail({ assetId }: { assetId: string }) {
  const { subscribeToAsset, unsubscribeFromAsset } = useWebSocket();
  const [viewers, setViewers] = useState<string[]>([]);

  useEffect(() => {
    // Subscribe to real-time updates for this asset
    subscribeToAsset(assetId);

    return () => {
      unsubscribeFromAsset(assetId);
    };
  }, [assetId]);

  return (
    <div>
      {viewers.length > 0 && (
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-500">Currently viewing:</span>
          {viewers.map(userId => (
            <PersonaAvatar key={userId} userId={userId} />
          ))}
        </div>
      )}
      {/* Asset details */}
    </div>
  );
}
```

#### Scaling Considerations

##### Option 1: Sticky Sessions (Simplest, $0/month)
```typescript
// For MVP: Use ALB sticky sessions, no adapter needed
// websocket/websocket.gateway.ts
@WebSocketGateway({
  cors: {
    origin: process.env.FRONTEND_URL,
    credentials: true,
  },
})
export class EventsGateway {
  // No special adapter needed with sticky sessions
  // ALB ensures same client always hits same server
}

// ALB configuration ensures WebSocket affinity
const albConfig = {
  targetGroup: {
    protocol: 'HTTP',
    stickiness: {
      enabled: true,
      duration: 86400, // 24 hours
      type: 'app_cookie',
      cookieName: 'AWSALBAPP'
    }
  }
};
```

##### Option 2: DynamoDB Adapter (Scaling, $5-10/month)
```typescript
// websocket/dynamodb-adapter.ts - Cost-effective horizontal scaling
import { IoAdapter } from '@nestjs/platform-socket.io';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';

export class DynamoDBAdapter extends IoAdapter {
  private dynamodb: DynamoDBClient;
  private tableName = 'websocket-connections';

  constructor(app: any) {
    super(app);
    this.dynamodb = new DynamoDBClient({ region: process.env.AWS_REGION });
  }

  async storeConnection(connectionId: string, serverId: string): Promise<void> {
    // Store connection-to-server mapping in DynamoDB
    // Cost: ~$0.25/GB/month + minimal request costs
  }

  createIOServer(port: number, options?: any): any {
    const server = super.createIOServer(port, options);
    // Use DynamoDB for connection state, not pub/sub
    return server;
  }
}
```

##### Option 3: Upstash Redis Adapter (High Scale, $10-30/month)
```typescript
// websocket/upstash-adapter.ts - Pay-per-request WebSocket scaling
import { IoAdapter } from '@nestjs/platform-socket.io';
import { Redis } from '@upstash/redis';

export class UpstashAdapter extends IoAdapter {
  private redis: Redis;

  constructor(app: any) {
    super(app);
    this.redis = new Redis({
      url: process.env.UPSTASH_REDIS_URL,
      token: process.env.UPSTASH_REDIS_TOKEN,
    });
  }

  // Upstash charges $0.20 per 100K commands
  // Perfect for variable traffic patterns
}
```

#### Real-Time Features Enabled
1. **Live Asset Updates** - See changes as family members edit
2. **Presence Indicators** - Know who's viewing/editing what
3. **Upload Progress** - Real-time document upload status
4. **Instant Notifications** - Invitations, approvals, changes
5. **Collaborative Editing** - Multiple users working together
6. **Activity Feed** - Live stream of FFC activities

### API Gateway Pattern Implementation

#### Overview
AWS API Gateway provides centralized API management with rate limiting, authentication, caching, and usage plans for the Forward Inheritance Platform.

#### API Gateway Configuration
```typescript
// infrastructure/api-gateway.ts - Pulumi Definition
import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

// Create HTTP API Gateway
const httpApi = new aws.apigatewayv2.Api("forward-inheritance-api", {
    name: "forward-inheritance-api",
    description: "Forward Inheritance Platform API Gateway",
    protocolType: "HTTP",
    corsConfiguration: {
        allowOrigins: ["https://app.forward-inheritance.com"],
        allowMethods: ["*"],
        allowHeaders: ["Content-Type", "Authorization", "X-Api-Key"],
        allowCredentials: true,
    },
});

// VPC Link for private ALB integration
const vpcLink = new aws.apigatewayv2.VpcLink("api-vpc-link", {
    name: "forward-inheritance-vpc-link",
    subnetIds: privateSubnetIds,
    securityGroupIds: [apiSecurityGroupId],
});

// JWT Authorizer for AWS Cognito
const authorizer = new aws.apigatewayv2.Authorizer("jwt-authorizer", {
    apiId: httpApi.id,
    authorizerType: "JWT",
    identitySources: ["$request.header.Authorization"],
    jwtConfiguration: {
        audiences: [userPoolClientId],
        issuer: pulumi.interpolate`https://cognito-idp.${aws.getRegion().then(r => r.name)}.amazonaws.com/${userPoolId}`,
    },
});

// ALB Integration
const albIntegration = new aws.apigatewayv2.Integration("alb-integration", {
    apiId: httpApi.id,
    integrationType: "HTTP_PROXY",
    connectionType: "VPC_LINK",
    connectionId: vpcLink.id,
    integrationMethod: "ANY",
    integrationUri: albArn,
    payloadFormatVersion: "1.0",
});

// Routes with rate limiting
const authRoutes = [
    { path: "/api/auth/login", method: "POST", requireAuth: false },
    { path: "/api/auth/register", method: "POST", requireAuth: false },
    { path: "/api/auth/callback", method: "GET", requireAuth: false },
    { path: "/api/auth/refresh", method: "POST", requireAuth: false },
];

const protectedRoutes = [
    { path: "/api/assets/{proxy+}", method: "ANY", requireAuth: true },
    { path: "/api/documents/{proxy+}", method: "ANY", requireAuth: true },
    { path: "/api/integrations/{proxy+}", method: "ANY", requireAuth: true },
    { path: "/api/user/{proxy+}", method: "ANY", requireAuth: true },
];

// Create routes
[...authRoutes, ...protectedRoutes].forEach((route, index) => {
    new aws.apigatewayv2.Route(`route-${index}`, {
        apiId: httpApi.id,
        routeKey: `${route.method} ${route.path}`,
        target: pulumi.interpolate`integrations/${albIntegration.id}`,
        authorizationType: route.requireAuth ? "JWT" : "NONE",
        authorizerId: route.requireAuth ? authorizer.id : undefined,
    });
});

// Throttling configuration
const throttleConfig = new aws.apigatewayv2.RouteResponse("throttle-config", {
    apiId: httpApi.id,
    routeId: "ANY /{proxy+}",
    routeResponseKey: "$default",
});

// Usage Plan for API rate limiting
const usagePlan = new aws.apigateway.UsagePlan("api-usage-plan", {
    name: "forward-inheritance-usage-plan",
    description: "Usage plan for Forward Inheritance API",
    throttleSettings: {
        rateLimit: 1000,    // requests per second
        burstLimit: 2000,   // burst capacity
    },
    quotaSettings: {
        limit: 100000,      // requests per day
        period: "DAY",
    },
});

// API Key for partners
const partnerApiKey = new aws.apigateway.ApiKey("partner-api-key", {
    name: "partner-integration-key",
    description: "API key for partner integrations",
});

const usagePlanKey = new aws.apigateway.UsagePlanKey("usage-plan-key", {
    keyId: partnerApiKey.id,
    keyType: "API_KEY",
    usagePlanId: usagePlan.id,
});

// WAF Web ACL
const webAcl = new aws.wafv2.WebAcl("api-waf", {
    name: "forward-inheritance-api-waf",
    description: "WAF for Forward Inheritance API Gateway",
    scope: "REGIONAL",
    defaultAction: { allow: {} },
    rules: [
        {
            name: "RateLimitRule",
            priority: 1,
            statement: {
                rateBasedStatement: {
                    limit: 2000,
                    aggregateKeyType: "IP",
                },
            },
            action: { block: {} },
            visibilityConfig: {
                sampledRequestsEnabled: true,
                cloudwatchMetricsEnabled: true,
                metricName: "RateLimitRule",
            },
        },
        {
            name: "AWSManagedRulesSQLiRuleSet",
            priority: 2,
            statement: {
                managedRuleGroupStatement: {
                    vendorName: "AWS",
                    name: "AWSManagedRulesSQLiRuleSet",
                },
            },
            action: { block: {} },
            visibilityConfig: {
                sampledRequestsEnabled: true,
                cloudwatchMetricsEnabled: true,
                metricName: "SQLiRule",
            },
            overrideAction: { none: {} },
        },
        {
            name: "AWSManagedRulesKnownBadInputsRuleSet",
            priority: 3,
            statement: {
                managedRuleGroupStatement: {
                    vendorName: "AWS",
                    name: "AWSManagedRulesKnownBadInputsRuleSet",
                },
            },
            action: { block: {} },
            visibilityConfig: {
                sampledRequestsEnabled: true,
                cloudwatchMetricsEnabled: true,
                metricName: "XSSRule",
            },
            overrideAction: { none: {} },
        },
    ],
    visibilityConfig: {
        sampledRequestsEnabled: true,
        cloudwatchMetricsEnabled: true,
        metricName: "ForwardInheritanceApiWaf",
    },
});

// Associate WAF with API Gateway
const webAclAssociation = new aws.wafv2.WebAclAssociation("api-waf-association", {
    resourceArn: pulumi.interpolate`${httpApi.arn}/*/*`,
    webAclArn: webAcl.arn,
});

// Custom domain
const apiDomainName = new aws.apigatewayv2.DomainName("api-domain", {
    domainName: "api.forward-inheritance.com",
    domainNameConfiguration: {
        certificateArn: certificateArn,
        endpointType: "REGIONAL",
        securityPolicy: "TLS_1_2",
    },
});

const apiMapping = new aws.apigatewayv2.ApiMapping("api-mapping", {
    apiId: httpApi.id,
    domainName: apiDomainName.id,
    stage: deploymentStage.id,
});

// Stage and deployment
const deploymentStage = new aws.apigatewayv2.Stage("api-stage", {
    apiId: httpApi.id,
    name: "v1",
    description: "Production API stage",
    autoDeploy: true,
    throttleConfig: {
        rateLimit: 1000,
        burstLimit: 2000,
    },
    accessLogSettings: {
        destinationArn: cloudwatchLogGroup.arn,
        format: pulumi.interpolate`{
            "requestId": "$context.requestId",
            "ip": "$context.identity.sourceIp",
            "requestTime": "$context.requestTime",
            "httpMethod": "$context.httpMethod",
            "routeKey": "$context.routeKey",
            "status": "$context.status",
            "protocol": "$context.protocol",
            "responseLength": "$context.responseLength",
            "responseLatency": "$context.responseLatency"
        }`,
    },
});

export const apiGatewayUrl = httpApi.apiEndpoint;
export const apiGatewayId = httpApi.id;
export const customDomainUrl = pulumi.interpolate`https://${apiDomainName.domainName}`;
```

#### Nest.js Rate Limiting (Application Layer)
```typescript
// app.module.ts - Additional application-level rate limiting
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    // Global rate limiting as backup to API Gateway
    ThrottlerModule.forRoot({
      ttl: 60,        // Time window in seconds
      limit: 100,     // Max requests per ttl window
      skipIf: (context) => {
        // Skip rate limiting for health checks
        const request = context.switchToHttp().getRequest();
        return request.url === '/health';
      },
    }),
    // Other modules...
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}

// Custom rate limits for specific endpoints
@Controller('auth')
export class AuthController {
  @Post('login')
  @Throttle(5, 900)  // 5 requests per 15 minutes
  async login(@Body() dto: LoginDto) {
    // Login logic
  }

  @Post('register')
  @Throttle(3, 3600) // 3 requests per hour
  async register(@Body() dto: RegisterDto) {
    // Registration logic
  }

  @Post('password-reset')
  @Throttle(3, 900)  // 3 requests per 15 minutes
  async resetPassword(@Body() dto: ResetPasswordDto) {
    // Password reset logic
  }
}

// Per-user rate limiting for expensive operations
@Injectable()
export class UserRateLimitGuard implements CanActivate {
  private userLimits = new Map<string, { count: number; resetTime: number }>();

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id;
    
    if (!userId) return false;

    const now = Date.now();
    const userLimit = this.userLimits.get(userId);

    if (!userLimit || now > userLimit.resetTime) {
      // Reset limit
      this.userLimits.set(userId, {
        count: 1,
        resetTime: now + 60000, // 1 minute window
      });
      return true;
    }

    if (userLimit.count >= 10) { // 10 requests per minute per user
      throw new TooManyRequestsException(
        'Rate limit exceeded. Please wait before trying again.'
      );
    }

    userLimit.count++;
    return true;
  }
}
```

#### API Key Management for B2B
```typescript
// services/api-key.service.ts
@Injectable()
export class ApiKeyService {
  constructor(
    @Inject('DATABASE_POOL') private pool: DatabasePool,
    private readonly cryptoService: CryptoService,
  ) {}

  async createApiKey(tenantId: number, name: string): Promise<ApiKeyResponse> {
    // Generate secure API key
    const apiKey = this.cryptoService.generateApiKey();
    const hashedKey = await this.cryptoService.hashApiKey(apiKey);
    
    // Store in database
    const result = await this.pool.one(sql`
      INSERT INTO api_keys (
        tenant_id,
        name,
        key_hash,
        key_prefix,
        usage_plan,
        rate_limit,
        expires_at
      ) VALUES (
        ${tenantId},
        ${name},
        ${hashedKey},
        ${apiKey.substring(0, 8)},
        'pro',
        100,
        NOW() + INTERVAL '1 year'
      )
      RETURNING id, key_prefix, created_at
    `);

    return {
      id: result.id,
      apiKey,  // Only returned once
      keyPrefix: result.key_prefix,
      createdAt: result.created_at,
    };
  }

  async validateApiKey(apiKey: string): Promise<ApiKeyValidation> {
    const hashedKey = await this.cryptoService.hashApiKey(apiKey);
    
    const result = await this.pool.maybeOne(sql`
      SELECT 
        ak.*,
        t.name as tenant_name
      FROM api_keys ak
      JOIN tenants t ON t.id = ak.tenant_id
      WHERE ak.key_hash = ${hashedKey}
        AND ak.is_active = true
        AND (ak.expires_at IS NULL OR ak.expires_at > NOW())
    `);

    if (!result) {
      return { valid: false };
    }

    // Update last used timestamp
    await this.pool.query(sql`
      UPDATE api_keys 
      SET 
        last_used_at = NOW(),
        usage_count = usage_count + 1
      WHERE id = ${result.id}
    `);

    return {
      valid: true,
      tenantId: result.tenant_id,
      tenantName: result.tenant_name,
      rateLimit: result.rate_limit,
      usagePlan: result.usage_plan,
    };
  }
}

// Middleware for API key authentication
@Injectable()
export class ApiKeyAuthGuard implements CanActivate {
  constructor(private readonly apiKeyService: ApiKeyService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const apiKey = request.headers['x-api-key'];
    
    if (!apiKey) {
      throw new UnauthorizedException('API key required');
    }

    const validation = await this.apiKeyService.validateApiKey(apiKey);
    
    if (!validation.valid) {
      throw new UnauthorizedException('Invalid API key');
    }

    // Attach tenant context to request
    request.apiKeyContext = {
      tenantId: validation.tenantId,
      tenantName: validation.tenantName,
      rateLimit: validation.rateLimit,
    };

    return true;
  }
}
```

#### Response Caching at Gateway
```typescript
// API Gateway caching configuration
const cachedRoutes = [
  {
    path: '/api/assets/categories',
    method: 'GET',
    cacheTtl: 3600,        // 1 hour
    cacheKeyParameters: [],
  },
  {
    path: '/api/ffcs/{ffcId}/summary',
    method: 'GET',
    cacheTtl: 300,         // 5 minutes
    cacheKeyParameters: ['ffcId'],
  },
  {
    path: '/api/reports/wealth-summary',
    method: 'GET',
    cacheTtl: 600,         // 10 minutes
    cacheKeyParameters: ['userId', 'date'],
  },
];

cachedRoutes.forEach(route => {
  httpApi.addRoutes({
    path: route.path,
    methods: [route.method],
    integration: new apigateway.HttpAlbIntegration({
      listener: props.albListener,
      requestParameters: {
        'header.Cache-Control': `public, max-age=${route.cacheTtl}`,
      },
    }),
    // Enable caching
    cachePolicy: new apigateway.CachePolicy({
      cacheTtl: Duration.seconds(route.cacheTtl),
      cacheKeyParameters: route.cacheKeyParameters,
    }),
  });
});
```

#### Monitoring and Alerting
```typescript
// monitoring/api-gateway-alarms.ts
const highErrorRateAlarm = new cloudwatch.Alarm(this, 'HighErrorRate', {
  metric: httpApi.metric4XXError(),
  threshold: 100,
  evaluationPeriods: 2,
  treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
});

const highLatencyAlarm = new cloudwatch.Alarm(this, 'HighLatency', {
  metric: httpApi.metricLatency({ statistic: 'P99' }),
  threshold: 1000, // 1 second
  evaluationPeriods: 3,
});

const throttlingAlarm = new cloudwatch.Alarm(this, 'ExcessiveThrottling', {
  metric: new cloudwatch.Metric({
    namespace: 'AWS/ApiGateway',
    metricName: 'Throttle',
    dimensions: {
      ApiName: httpApi.apiId,
    },
  }),
  threshold: 50,
  evaluationPeriods: 1,
});

// SNS notifications
const topic = new sns.Topic(this, 'ApiAlerts');
topic.addSubscription(new subscriptions.EmailSubscription('ops@forward-inheritance.com'));

highErrorRateAlarm.addAlarmAction(new actions.SnsAction(topic));
highLatencyAlarm.addAlarmAction(new actions.SnsAction(topic));
throttlingAlarm.addAlarmAction(new actions.SnsAction(topic));
```

### Event Sourcing Architecture (PostgreSQL-Based)

#### Overview
Event sourcing provides immutable audit trails by storing all state changes as events, enabling time-travel queries, complete audit history, and SOC 2 compliance for the Forward Inheritance Platform.

#### Database Schema for Event Store
```sql
-- Core event store table
CREATE TABLE event_store (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_id UUID NOT NULL,           -- ID of the entity (asset, FFC, user)
  aggregate_type TEXT NOT NULL,         -- Type of entity
  event_type TEXT NOT NULL,             -- Type of event
  event_data JSONB NOT NULL,           -- Event payload
  event_metadata JSONB,                 -- Context (user, IP, reason)
  event_version INTEGER NOT NULL,       -- Order of events for an aggregate
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL,
  tenant_id INTEGER NOT NULL,
  
  -- Indexes for performance
  INDEX idx_aggregate_lookup (aggregate_id, event_version),
  INDEX idx_event_type (event_type, created_at),
  INDEX idx_tenant_events (tenant_id, created_at),
  INDEX idx_created_by (created_by, created_at),
  
  -- Ensure events are immutable
  CHECK (event_version > 0),
  UNIQUE (aggregate_id, event_version)
);

-- Event snapshots for performance
CREATE TABLE event_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_id UUID NOT NULL,
  aggregate_type TEXT NOT NULL,
  snapshot_data JSONB NOT NULL,
  event_version INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  INDEX idx_snapshot_lookup (aggregate_id, event_version DESC)
);

-- Materialized view for current asset state
CREATE MATERIALIZED VIEW asset_current_state AS
WITH latest_events AS (
  SELECT DISTINCT ON (aggregate_id)
    aggregate_id,
    event_data,
    event_type,
    created_at,
    event_version
  FROM event_store
  WHERE aggregate_type = 'Asset'
  ORDER BY aggregate_id, event_version DESC
)
SELECT 
  aggregate_id as asset_id,
  event_data->>'name' as asset_name,
  (event_data->>'estimatedValue')::DECIMAL as estimated_value,
  event_data->>'status' as status,
  created_at as last_updated
FROM latest_events;

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION refresh_asset_state()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY asset_current_state;
END;
$$ LANGUAGE plpgsql;
```

#### Event Store Service Implementation
```typescript
// event-store/event-store.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { sql, DatabasePool } from 'slonik';

export interface DomainEvent {
  id: string;
  aggregateId: string;
  aggregateType: string;
  eventType: string;
  eventData: Record<string, any>;
  eventMetadata: {
    userId: string;
    tenantId: number;
    correlationId?: string;
    causationId?: string;
    ipAddress?: string;
    userAgent?: string;
    reason?: string;
  };
  eventVersion: number;
  createdAt: Date;
}

@Injectable()
export class EventStoreService {
  private readonly logger = new Logger(EventStoreService.name);

  constructor(
    @Inject('DATABASE_POOL') private pool: DatabasePool,
    private eventEmitter: EventEmitter2,
  ) {}

  async append(event: DomainEvent): Promise<void> {
    const startTime = Date.now();
    
    try {
      // Get next version number
      const version = await this.getNextVersion(event.aggregateId);
      
      // Store event
      await this.pool.query(sql`
        INSERT INTO event_store (
          id,
          aggregate_id,
          aggregate_type,
          event_type,
          event_data,
          event_metadata,
          event_version,
          created_at,
          created_by,
          tenant_id
        ) VALUES (
          ${event.id}::uuid,
          ${event.aggregateId}::uuid,
          ${event.aggregateType},
          ${event.eventType},
          ${sql.json(event.eventData)},
          ${sql.json(event.eventMetadata)},
          ${version},
          ${event.createdAt},
          ${event.eventMetadata.userId}::uuid,
          ${event.eventMetadata.tenantId}
        )
      `);

      // Emit for projections and real-time updates
      this.eventEmitter.emit(`event.${event.eventType}`, event);
      
      // Emit to WebSocket for real-time updates
      this.eventEmitter.emit('websocket.broadcast', {
        channel: `aggregate:${event.aggregateId}`,
        event: event.eventType,
        data: event.eventData,
      });

      this.logger.debug(
        `Event stored: ${event.eventType} for ${event.aggregateType}:${event.aggregateId} in ${Date.now() - startTime}ms`
      );
    } catch (error) {
      this.logger.error('Failed to append event', error);
      throw error;
    }
  }

  async getEvents(
    aggregateId: string,
    fromVersion?: number,
    toVersion?: number
  ): Promise<DomainEvent[]> {
    const query = sql`
      SELECT * FROM event_store
      WHERE aggregate_id = ${aggregateId}::uuid
      ${fromVersion ? sql`AND event_version >= ${fromVersion}` : sql``}
      ${toVersion ? sql`AND event_version <= ${toVersion}` : sql``}
      ORDER BY event_version ASC
    `;

    const events = await this.pool.query(query);
    return events.rows.map(this.mapToDomainEvent);
  }

  async getEventsByType(
    eventType: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<DomainEvent[]> {
    const query = sql`
      SELECT * FROM event_store
      WHERE event_type = ${eventType}
      ${startDate ? sql`AND created_at >= ${startDate}` : sql``}
      ${endDate ? sql`AND created_at <= ${endDate}` : sql``}
      ORDER BY created_at DESC
      LIMIT 1000
    `;

    const events = await this.pool.query(query);
    return events.rows.map(this.mapToDomainEvent);
  }

  async replayAggregate(
    aggregateId: string,
    toDate?: Date
  ): Promise<any> {
    // Get latest snapshot if exists
    const snapshot = await this.getLatestSnapshot(aggregateId, toDate);
    
    // Get events after snapshot
    const events = await this.getEvents(
      aggregateId,
      snapshot?.eventVersion || 0
    );

    // Filter by date if specified
    const relevantEvents = toDate
      ? events.filter(e => e.createdAt <= toDate)
      : events;

    // Rebuild aggregate state
    return this.rebuildAggregate(
      snapshot?.snapshotData || {},
      relevantEvents
    );
  }

  private async getNextVersion(aggregateId: string): Promise<number> {
    const result = await this.pool.maybeOne(sql`
      SELECT MAX(event_version) as max_version
      FROM event_store
      WHERE aggregate_id = ${aggregateId}::uuid
    `);

    return (result?.max_version || 0) + 1;
  }

  private rebuildAggregate(
    initialState: any,
    events: DomainEvent[]
  ): any {
    return events.reduce((state, event) => {
      return this.applyEvent(state, event);
    }, initialState);
  }

  private applyEvent(state: any, event: DomainEvent): any {
    // Event-specific state transitions
    switch (event.eventType) {
      case 'AssetCreated':
        return {
          ...state,
          ...event.eventData,
          created: true,
        };
      
      case 'AssetValueUpdated':
        return {
          ...state,
          currentValue: event.eventData.newValue,
          previousValue: state.currentValue,
          lastValuationDate: event.createdAt,
        };
      
      case 'AssetOwnershipTransferred':
        return {
          ...state,
          ownerId: event.eventData.newOwnerId,
          previousOwnerId: event.eventData.previousOwnerId,
          transferDate: event.createdAt,
        };
      
      case 'AssetDeleted':
        return {
          ...state,
          deleted: true,
          deletedAt: event.createdAt,
        };
      
      default:
        return { ...state, ...event.eventData };
    }
  }

  async createSnapshot(aggregateId: string): Promise<void> {
    const currentState = await this.replayAggregate(aggregateId);
    const version = await this.getNextVersion(aggregateId) - 1;

    await this.pool.query(sql`
      INSERT INTO event_snapshots (
        aggregate_id,
        aggregate_type,
        snapshot_data,
        event_version
      ) VALUES (
        ${aggregateId}::uuid,
        ${currentState.aggregateType},
        ${sql.json(currentState)},
        ${version}
      )
    `);
  }

  private mapToDomainEvent(row: any): DomainEvent {
    return {
      id: row.id,
      aggregateId: row.aggregate_id,
      aggregateType: row.aggregate_type,
      eventType: row.event_type,
      eventData: row.event_data,
      eventMetadata: row.event_metadata,
      eventVersion: row.event_version,
      createdAt: row.created_at,
    };
  }
}
```

#### Asset Service with Event Sourcing
```typescript
// assets/assets.service.ts
@Injectable()
export class AssetsService {
  constructor(
    private eventStore: EventStoreService,
    @Inject('DATABASE_POOL') private pool: DatabasePool,
  ) {}

  async createAsset(dto: CreateAssetDto, context: RequestContext): Promise<Asset> {
    const assetId = uuid();
    
    // Create event
    const event: DomainEvent = {
      id: uuid(),
      aggregateId: assetId,
      aggregateType: 'Asset',
      eventType: 'AssetCreated',
      eventData: {
        ...dto,
        id: assetId,
        createdBy: context.userId,
      },
      eventMetadata: {
        userId: context.userId,
        tenantId: context.tenantId,
        ipAddress: context.ipAddress,
        reason: 'User created new asset',
      },
      eventVersion: 1,
      createdAt: new Date(),
    };

    // Store event
    await this.eventStore.append(event);

    // Update read model (traditional table for queries)
    await this.pool.query(sql`
      INSERT INTO assets (id, name, value, ...)
      VALUES (${assetId}, ${dto.name}, ${dto.value}, ...)
    `);

    return this.getAsset(assetId);
  }

  async updateAssetValue(
    assetId: string,
    newValue: number,
    reason: string,
    context: RequestContext
  ): Promise<void> {
    // Get current value for event
    const currentAsset = await this.getAsset(assetId);
    
    // Create event
    const event: DomainEvent = {
      id: uuid(),
      aggregateId: assetId,
      aggregateType: 'Asset',
      eventType: 'AssetValueUpdated',
      eventData: {
        previousValue: currentAsset.value,
        newValue,
        changeAmount: newValue - currentAsset.value,
        changePercentage: ((newValue - currentAsset.value) / currentAsset.value) * 100,
      },
      eventMetadata: {
        userId: context.userId,
        tenantId: context.tenantId,
        reason,
      },
      eventVersion: await this.eventStore.getNextVersion(assetId),
      createdAt: new Date(),
    };

    // Store event
    await this.eventStore.append(event);

    // Update read model
    await this.pool.query(sql`
      UPDATE assets 
      SET 
        estimated_value = ${newValue},
        last_valued_date = NOW()
      WHERE id = ${assetId}::uuid
    `);
  }

  async getAssetHistory(assetId: string): Promise<AssetHistory> {
    const events = await this.eventStore.getEvents(assetId);
    
    return {
      assetId,
      events: events.map(e => ({
        type: e.eventType,
        data: e.eventData,
        user: e.eventMetadata.userId,
        reason: e.eventMetadata.reason,
        timestamp: e.createdAt,
      })),
      currentState: await this.eventStore.replayAggregate(assetId),
    };
  }

  async getAssetValueAtDate(assetId: string, date: Date): Promise<number> {
    const state = await this.eventStore.replayAggregate(assetId, date);
    return state.currentValue || 0;
  }

  async getEstateValueAtDeath(personaId: string, deathDate: Date): Promise<EstateValue> {
    // Get all assets owned by persona
    const assets = await this.getPersonaAssets(personaId);
    
    // Get value of each asset at death date
    const assetValues = await Promise.all(
      assets.map(async (asset) => ({
        assetId: asset.id,
        name: asset.name,
        valueAtDeath: await this.getAssetValueAtDate(asset.id, deathDate),
      }))
    );

    return {
      personaId,
      deathDate,
      assets: assetValues,
      totalValue: assetValues.reduce((sum, a) => sum + a.valueAtDeath, 0),
    };
  }
}
```

#### Projection Service for Read Models
```typescript
// event-store/projection.service.ts
@Injectable()
export class ProjectionService {
  constructor(
    @Inject('DATABASE_POOL') private pool: DatabasePool,
  ) {}

  @OnEvent('event.AssetCreated')
  async handleAssetCreated(event: DomainEvent) {
    // Update materialized view
    await this.pool.query(sql`
      REFRESH MATERIALIZED VIEW CONCURRENTLY asset_current_state
    `);
    
    // Update statistics
    await this.updateAssetStatistics(event.eventMetadata.tenantId);
  }

  @OnEvent('event.AssetValueUpdated')
  async handleAssetValueUpdated(event: DomainEvent) {
    // Update total wealth calculations
    await this.updateWealthCalculations(event.aggregateId);
    
    // Check for significant changes
    if (event.eventData.changePercentage > 10) {
      await this.notifySignificantChange(event);
    }
  }

  @Cron('0 */6 * * *') // Every 6 hours
  async createSnapshots() {
    // Create snapshots for frequently accessed aggregates
    const activeAggregates = await this.pool.query(sql`
      SELECT DISTINCT aggregate_id
      FROM event_store
      WHERE created_at > NOW() - INTERVAL '7 days'
      GROUP BY aggregate_id
      HAVING COUNT(*) > 50  -- More than 50 events
    `);

    for (const row of activeAggregates.rows) {
      await this.eventStore.createSnapshot(row.aggregate_id);
    }
  }
}
```

#### Benefits for Forward Inheritance
1. **Complete Audit Trail** - Every change is recorded forever
2. **Time Travel Queries** - Asset values at any point in time
3. **Estate Settlement** - Exact values at time of death
4. **Dispute Resolution** - Who changed what and when
5. **SOC 2 Compliance** - Immutable audit logs
6. **Tax Reporting** - Historical valuations for tax purposes

### Queue Processing with AWS SQS
```typescript
// Application-level async tasks using AWS SQS
import { SQSClient, SendMessageCommand, ReceiveMessageCommand } from '@aws-sdk/client-sqs';
import { Injectable } from '@nestjs/common';

@Injectable()
export class NotificationProcessor {
  private sqsClient: SQSClient;
  private queueUrl: string;

  constructor(
    private readonly websocketGateway: CollaborationGateway,
    private readonly emailService: EmailService,
  ) {
    this.sqsClient = new SQSClient({ region: process.env.AWS_REGION });
    this.queueUrl = process.env.NOTIFICATION_QUEUE_URL;
  }

  async sendNotification(type: string, data: any) {
    const command = new SendMessageCommand({
      QueueUrl: this.queueUrl,
      MessageBody: JSON.stringify({ type, data }),
      MessageAttributes: {
        type: { DataType: 'String', StringValue: type }
      }
    });
    
    await this.sqsClient.send(command);
  }

  async processMessages() {
    const command = new ReceiveMessageCommand({
      QueueUrl: this.queueUrl,
      MaxNumberOfMessages: 10,
      WaitTimeSeconds: 20, // Long polling
    });

    const response = await this.sqsClient.send(command);
    
    for (const message of response.Messages || []) {
      const { type, data } = JSON.parse(message.Body);
      
      if (type === 'document-ready') {
        await this.websocketGateway.notifyUser(data.userId, {
          type: 'document:ready',
          documentId: data.documentId,
        });
        
        await this.emailService.sendDocumentReadyEmail(data.userId, data.documentId);
      }
    }
  }
}
```

## Unified Project Structure

```plaintext
fwd-inh/
├── .github/                        # CI/CD workflows
├── apps/                           # Application packages
│   ├── web/                        # Frontend React application
│   └── api/                        # Backend Node.js application
├── packages/                       # Shared packages
│   ├── shared/                     # Shared types/utilities
│   ├── ui/                        # Shared UI components (future)
│   └── config/                    # Shared configuration
├── infrastructure/                # Infrastructure as Code
│   ├── aws/                       # Pulumi AWS definitions
│   └── docker/                    # Docker configurations
├── scripts/                       # Build/deploy scripts
├── docs/                          # Documentation
├── tests/                         # E2E and integration tests
├── .env.example                   # Environment template
├── package.json                   # Root package.json
└── README.md
```

Monorepo managed with npm workspaces for simplicity in MVP.

## Development Workflow

### Local Development Setup
- Prerequisites: Node.js 20+, Docker, PostgreSQL 14+
- Initial setup with migrations and type generation
- Development commands for frontend/backend/testing

### Environment Configuration
- Separate .env files for frontend and backend
- Required variables for database, JWT, AWS, and external services

### Development Patterns
- Feature development flow
- Database change flow with migrations
- API development flow
- Debugging and troubleshooting guides

## Cost Optimization Strategy

### Progressive Infrastructure Scaling

#### Phase 1: MVP (0-5K families) - $50-100/month
- **Compute**: 1-2 ECS Fargate tasks (0.5 vCPU, 1GB RAM)
- **Database**: RDS t3.micro PostgreSQL
- **Caching**: In-memory only (no additional cost)
- **Sessions**: JWT tokens (stateless, no storage)
- **Queue**: SQS (pay-per-message)
- **WebSockets**: Single instance with sticky sessions

#### Phase 2: Growth (5K-20K families) - $200-400/month
- **Compute**: 2-4 ECS Fargate tasks (1 vCPU, 2GB RAM)
- **Database**: RDS t3.small PostgreSQL with read replica
- **Caching**: DynamoDB for sessions ($5-10/month)
- **Sessions**: DynamoDB with TTL ($0.25/GB/month)
- **Queue**: SQS with DLQ
- **WebSockets**: Multiple instances with DynamoDB state

#### Phase 3: Scale (20K+ families) - $500-1000/month
- **Compute**: Auto-scaling ECS (2-8 tasks)
- **Database**: RDS m5.large with Multi-AZ
- **Caching**: Upstash Redis ($10-30/month pay-per-request)
- **Sessions**: Upstash Redis (serverless pricing)
- **Queue**: SQS with fan-out to SNS
- **WebSockets**: Upstash Redis adapter

#### Phase 4: Enterprise (Custom pricing)
- **Compute**: EKS or dedicated ECS cluster
- **Database**: Aurora PostgreSQL Serverless v2
- **Caching**: ElastiCache only if required ($150+/month)
- **Sessions**: Dedicated session store
- **Queue**: EventBridge with Step Functions
- **WebSockets**: Managed WebSocket API Gateway

### Cost Comparison: Traditional vs Optimized

| Component | Traditional Approach | Optimized Approach | Monthly Savings |
|-----------|---------------------|-------------------|-----------------|
| Caching | ElastiCache ($150-500) | DynamoDB/Upstash ($5-30) | $145-470 |
| Queue | Self-managed Redis ($50-100) | AWS SQS ($0-20) | $50-80 |
| Sessions | Redis Cluster ($100-200) | DynamoDB ($5-10) | $95-190 |
| WebSockets | Redis Pub/Sub ($50-100) | Sticky Sessions/DynamoDB ($0-10) | $50-90 |
| **Total** | **$350-900/month** | **$10-70/month** | **$340-830/month** |

### Key Cost Optimization Principles

1. **Start with Zero-Cost Solutions**: In-memory caching, JWT tokens, sticky sessions
2. **Use Serverless When Possible**: SQS, DynamoDB, Lambda for one-off tasks
3. **Pay-Per-Use Over Always-On**: Upstash Redis vs ElastiCache
4. **Progressive Enhancement**: Only add infrastructure when revenue justifies it
5. **Monitor and Right-Size**: Use CloudWatch to track actual usage

### Break-Even Analysis

- **In-Memory Only**: Supports up to 5,000 families at $0 additional cost
- **DynamoDB Sessions**: Adds $5-10/month, supports 20,000 families
- **Upstash Redis**: Adds $10-30/month, supports 50,000+ families
- **ElastiCache**: Only justified at 100,000+ families or enterprise requirements

### Environment-Specific Cost Strategy

**Development Environment Optimization:**
- **NAT Gateways**: 0 until Phase 7, then 1 for entire VPC ($45/month savings)
- **RDS**: Single-AZ, small instances (t4g.small) instead of Multi-AZ
- **ECS**: Fargate Spot for non-critical workers (60% cost reduction)
- **WAF**: Delayed until Phase 7 (cost consideration - $5/month + usage)
- **Monitoring**: Basic CloudWatch vs enhanced monitoring

**Production Environment:**
- **NAT Gateways**: 1 per AZ for high availability ($90/month total)
- **RDS**: Multi-AZ with larger instances (m5.large+)
- **ECS**: Standard Fargate for critical services
- **Full security and monitoring suite**
- **Reserved Instance strategy for predictable workloads**

## Deployment Architecture

### Deployment Strategy
- **Frontend:** AWS Amplify with automatic CI/CD
- **Backend:** ECS Fargate with Docker containers
- **Database:** RDS PostgreSQL

### CI/CD Pipeline
- GitHub Actions for testing and deployment
- Separate workflows for staging and production
- Automated database migrations

### Environments
- Development (local)
- Staging (pre-production testing)
- Production (live environment)

### Infrastructure as Code
- Pulumi for infrastructure definition
- ECS task definitions and services
- Auto-scaling configuration
- Health checks and monitoring

---

## Security and Performance

### Security Requirements

#### Frontend Security

**Content Security Policy (CSP)**
```http
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://cdn.amplify.aws;
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' https://api.forward-inheritance.com wss://;
  font-src 'self' data:;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

**XSS Prevention**
- React's built-in XSS protection through JSX escaping
- DOMPurify for sanitizing user-generated HTML content
- Input validation on all form fields before submission
- HttpOnly cookies for session management
- SameSite cookie attributes set to 'Strict'

**Secure Storage Strategy**
- JWT tokens stored in memory, not localStorage
- Refresh tokens in HttpOnly, Secure, SameSite cookies
- Sensitive data encrypted using Web Crypto API before storage
- Session timeout after 30 minutes of inactivity
- Automatic token refresh with sliding expiration

#### Backend Security

**Input Validation**
- Joi schema validation on all API endpoints
- SQL injection prevention through stored procedures only
- Parameterized queries for any dynamic SQL (limited use)
- Request body size limits (10MB max)
- File upload restrictions by MIME type and extension

**Rate Limiting Configuration**
```javascript
// API Gateway rate limits
{
  burstLimit: 5000,      // requests
  rateLimit: 2000,       // requests per second
  
  // Per-endpoint limits
  '/api/auth/login': { rateLimit: 5, windowMs: 15 * 60 * 1000 }, // 5 attempts per 15 min
  '/api/auth/register': { rateLimit: 3, windowMs: 60 * 60 * 1000 }, // 3 per hour
  '/api/assets/*': { rateLimit: 100, windowMs: 60 * 1000 }, // 100 per minute
}
```

**CORS Policy**
```javascript
{
  origin: [
    'https://app.forward-inheritance.com',
    'https://staging.forward-inheritance.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  exposedHeaders: ['X-Request-ID'],
  maxAge: 86400 // 24 hours
}
```

#### Authentication Security

**Token Management (AWS Cognito)**
- JWT Access tokens (1 hour expiry - Cognito default)
- JWT ID tokens (1 hour expiry - contains user claims)
- Refresh tokens (30 days default, configurable up to 10 years)
- Token refresh handled via Cognito RefreshToken API
- Multi-device support with device tracking in Cognito

**Session Management (Cognito-Based)**
- Stateless JWT-based authentication (no database sessions)
- Device fingerprinting via Cognito device tracking
- Concurrent device limits enforced by Cognito
- Global sign-out via AdminUserGlobalSignOut API
- Session activity tracked in CloudWatch Logs
- No session tables required in database

**Password Requirements (Managed by AWS Cognito)**
- Minimum 12 characters (configured in User Pool)
- Requires uppercase, lowercase, number, special character (Cognito policy)
- Password history tracking (last 5 passwords - Cognito managed)
- Secure Remote Password (SRP) protocol for authentication
- Password expiry after 90 days (configured in Cognito)
- Temporary passwords for admin-created users
- Self-service password reset via email/SMS

#### PII Protection (AWS Architecture)

**Tokenization Pipeline**
1. Document upload to S3 staging bucket
2. Lambda triggered for PII detection (AWS Comprehend)
3. Identified PII tokenized and stored in separate encrypted vault
4. Original document with tokens stored in S3 production bucket
5. Mapping stored in RDS with encryption at rest

**Encryption Strategy**
- **AWS KMS**: Customer-managed keys with automatic rotation
- **RDS Encryption**: AES-256 encryption at rest
- **S3 Encryption**: SSE-KMS for all buckets
- **Transit Encryption**: TLS 1.3 for all API communications
- **Application-Level**: Field-level encryption for SSN, credit cards

### Performance Optimization

#### Frontend Performance

**Bundle Size Targets**
- Initial JS bundle: < 200KB (gzipped)
- Initial CSS: < 50KB (gzipped)
- Code splitting by route
- Lazy loading for non-critical components
- Tree shaking and dead code elimination

**Loading Strategy**
```javascript
// Progressive enhancement approach
1. Critical CSS inlined in <head>
2. Preload critical fonts and assets
3. Prefetch next likely navigation routes
4. Service Worker for offline capability
5. Image optimization with WebP/AVIF formats
```

**Caching Strategy**
- CloudFront CDN with 1-year cache for static assets
- Cache busting through content hash in filenames
- Service Worker caching for offline access
- LocalStorage for user preferences
- IndexedDB for offline data sync

**Performance Metrics Targets**
- First Contentful Paint (FCP): < 1.0s
- Largest Contentful Paint (LCP): < 2.5s
- First Input Delay (FID): < 100ms
- Cumulative Layout Shift (CLS): < 0.1
- Time to Interactive (TTI): < 3.5s

#### Backend Performance

**Response Time Targets**
- API response time p50: < 100ms
- API response time p95: < 500ms
- API response time p99: < 1000ms
- Database query time p95: < 50ms
- Lambda cold start: < 1s

**Database Optimization**
```sql
-- Connection pooling configuration
{
  min: 10,
  max: 100,
  idle: 10000,
  acquire: 30000,
  evict: 60000
}

-- Query optimization
- All operations through stored procedures
- Proper indexing on foreign keys and search columns
- Partial indexes for filtered queries
- Query result pagination (max 100 records)
- Read replicas for reporting queries
```

**Caching Strategy**
- In-memory caching for hot data (MVP), DynamoDB/Upstash for scale
- 5-minute cache for user permissions
- 1-hour cache for asset listings
- API Gateway caching for GET requests
- Database query result caching in memory (MVP), DynamoDB/Upstash for scale
- CloudFront caching for static API responses

**Auto-scaling Configuration**
```yaml
# ECS Fargate auto-scaling
targetCPUUtilization: 70
minTasks: 2
maxTasks: 100
scaleUpCooldown: 60
scaleDownCooldown: 300

# RDS Aurora auto-scaling
minCapacity: 2
maxCapacity: 16
targetCPUUtilization: 75
targetConnectionsPercent: 80
```

### Security Monitoring

**AWS Security Services**
- AWS WAF for application firewall
- AWS Shield for DDoS protection
- AWS GuardDuty for threat detection
- AWS Security Hub for compliance monitoring
- AWS CloudTrail for audit logging
- AWS Config for configuration compliance

**Security Events to Monitor**
- Failed login attempts (> 5 in 15 minutes)
- Password reset requests (> 3 per hour)
- Unusual data access patterns
- API rate limit violations
- JWT token anomalies
- Geographic access anomalies

## 🧪 Testing Strategy

> **🎯 Core Strategy**: Comprehensive testing pyramid with emphasis on unit tests, strategic integration tests, and focused E2E coverage for critical user workflows.

**🔗 Related Sections:**
- 🔧 [Tech Stack](#tech-stack) - Testing tools and frameworks
- 📚 [Quick Reference Guide](#-quick-reference-guide) - Testing commands
- 🏗️ [Architecture Patterns](#architectural-patterns) - Testable design patterns
- 💰 [Cost Optimization Strategy](#cost-optimization-strategy) - Test infrastructure costs

**🚀 Quick Commands:**
```bash
npm run test              # Run all tests
npm run test:unit         # Unit tests only
npm run test:e2e          # E2E tests only
npm run test:coverage     # Generate coverage report
```

---

### Testing Pyramid

```
         /\
        /E2E\        5% - Critical user journeys
       /------\
      /Integra-\     20% - API & service integration
     /  tion    \
    /------------\
   /   Unit Tests \  75% - Component & function level
  /________________\
```

**Test Distribution Goals**
- Unit Tests: 75% coverage minimum
- Integration Tests: All API endpoints and database operations
- E2E Tests: Critical user workflows only

### Test Organization

#### Frontend Tests Structure

```
apps/web/
├── src/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   └── Button.test.tsx
│   │   └── AssetCard/
│   │       ├── AssetCard.tsx
│   │       └── AssetCard.test.tsx
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   └── useAuth.test.ts
│   ├── pages/
│   │   ├── Dashboard/
│   │   │   ├── Dashboard.tsx
│   │   │   └── Dashboard.test.tsx
│   └── services/
│       ├── api.ts
│       └── api.test.ts
├── tests/
│   ├── setup.ts
│   ├── utils/
│   │   └── test-utils.tsx
│   └── e2e/
│       ├── auth.spec.ts
│       └── asset-management.spec.ts
└── jest.config.js
```

#### Backend Tests Structure

```
apps/api/
├── src/
│   ├── routes/
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   └── auth.controller.test.ts
│   │   └── assets/
│   │       ├── assets.controller.ts
│   │       └── assets.controller.test.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   └── auth.service.test.ts
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   └── auth.middleware.test.ts
│   └── utils/
│       ├── validators.ts
│       └── validators.test.ts
├── tests/
│   ├── setup.ts
│   ├── fixtures/
│   │   └── test-data.ts
│   ├── integration/
│   │   ├── auth.integration.test.ts
│   │   └── assets.integration.test.ts
│   └── helpers/
│       └── db-helper.ts
└── jest.config.js
```

#### E2E Tests Structure

```
tests/e2e/
├── fixtures/
│   ├── users.json
│   └── assets.json
├── page-objects/
│   ├── LoginPage.ts
│   ├── DashboardPage.ts
│   └── AssetPage.ts
├── specs/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── registration.spec.ts
│   │   └── password-reset.spec.ts
│   ├── ffc/
│   │   ├── create-ffc.spec.ts
│   │   └── invite-members.spec.ts
│   └── assets/
│       ├── add-asset.spec.ts
│       └── manage-permissions.spec.ts
├── support/
│   ├── commands.ts
│   └── helpers.ts
└── playwright.config.ts
```

### Test Configuration

#### Frontend Test Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/**/*.stories.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75,
    },
  },
};
```

#### Backend Test Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  testMatch: ['**/*.test.ts', '**/*.integration.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  globalSetup: '<rootDir>/tests/globalSetup.ts',
  globalTeardown: '<rootDir>/tests/globalTeardown.ts',
};
```

### Test Examples

#### Frontend Component Test

```typescript
// Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button Component', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button loading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByTestId('spinner')).toBeInTheDocument();
  });

  it('applies variant styles', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-primary');
    
    rerender(<Button variant="danger">Danger</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-danger');
  });
});

// useAuth.test.ts - Hook Test
import { renderHook, act } from '@testing-library/react';
import { useAuth } from './useAuth';
import { AuthProvider } from '@/contexts/AuthContext';

describe('useAuth Hook', () => {
  const wrapper = ({ children }) => <AuthProvider>{children}</AuthProvider>;

  it('provides authentication state', () => {
    const { result } = renderHook(() => useAuth(), { wrapper });
    
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('handles login', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });
    
    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });
    
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).toMatchObject({
      email: 'test@example.com',
    });
  });
});
```

#### Backend API Test

```typescript
// auth.controller.spec.ts - NestJS Unit Test
import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { CognitoService } from '../cognito/cognito.service';
import { LoginDto } from './dto/login.dto';
import { UnauthorizedException } from '@nestjs/common';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;
  let cognitoService: CognitoService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            validateCredentials: jest.fn(),
            generateTokens: jest.fn(),
            createUser: jest.fn(),
          },
        },
        {
          provide: CognitoService,
          useValue: {
            authenticateUser: jest.fn(),
            signUp: jest.fn(),
            verifyToken: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
    cognitoService = module.get<CognitoService>(CognitoService);
  });

  describe('login', () => {
    it('should return tokens on successful login', async () => {
      const loginDto: LoginDto = { 
        email: 'test@example.com', 
        password: 'password123' 
      };
      
      const mockUser = {
        userId: 'user-123',
        email: 'test@example.com',
        tenantId: 1,
      };

      const mockTokens = {
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        idToken: 'id-token',
      };

      jest.spyOn(cognitoService, 'authenticateUser').mockResolvedValue(mockTokens);
      jest.spyOn(authService, 'validateCredentials').mockResolvedValue(mockUser);

      const result = await controller.login(loginDto);

      expect(result).toEqual({
        accessToken: mockTokens.accessToken,
        refreshToken: mockTokens.refreshToken,
        user: mockUser,
      });
      expect(cognitoService.authenticateUser).toHaveBeenCalledWith(
        loginDto.email,
        loginDto.password
      );
    });

    it('should throw UnauthorizedException on invalid credentials', async () => {
      const loginDto: LoginDto = { 
        email: 'test@example.com', 
        password: 'wrong' 
      };
      
      jest.spyOn(cognitoService, 'authenticateUser').mockRejectedValue(
        new UnauthorizedException('Invalid credentials')
      );

      await expect(controller.login(loginDto)).rejects.toThrow(
        UnauthorizedException
      );
      
      expect(cognitoService.authenticateUser).toHaveBeenCalledWith(
        loginDto.email,
        loginDto.password
      );
    });
  });
});

// auth.integration.test.ts - Integration Test
import request from 'supertest';
import { app } from '@/app';
import { db } from '@/db';
import { generateTestUser } from '../fixtures/test-data';

describe('Auth API Integration', () => {
  beforeEach(async () => {
    await db.query('BEGIN');
  });

  afterEach(async () => {
    await db.query('ROLLBACK');
  });

  describe('POST /api/auth/register', () => {
    it('creates new user account', async () => {
      const userData = generateTestUser();
      
      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body).toMatchObject({
        user: {
          email: userData.email,
          firstName: userData.firstName,
          lastName: userData.lastName,
        },
      });

      // Verify user in database
      const result = await db.query(
        'SELECT * FROM users WHERE primary_email_id = (SELECT id FROM email_address WHERE email_address = $1)',
        [userData.email]
      );
      
      expect(result.rows).toHaveLength(1);
    });

    it('prevents duplicate email registration', async () => {
      const userData = generateTestUser();
      
      // First registration
      await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      // Duplicate registration
      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(409);

      expect(response.body.error).toBe('Email already registered');
    });
  });
});
```

#### E2E Test

```typescript
// login.spec.ts - Playwright E2E Test
import { test, expect } from '@playwright/test';
import { LoginPage } from '../../page-objects/LoginPage';
import { DashboardPage } from '../../page-objects/DashboardPage';

test.describe('Authentication Flow', () => {
  let loginPage: LoginPage;
  let dashboardPage: DashboardPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    dashboardPage = new DashboardPage(page);
    await loginPage.goto();
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    await loginPage.fillEmail('test@forward-inheritance.com');
    await loginPage.fillPassword('Test123!@#');
    await loginPage.clickSubmit();

    await expect(page).toHaveURL('/dashboard');
    await expect(dashboardPage.welcomeMessage).toContainText('Welcome back');
  });

  test('displays error for invalid credentials', async () => {
    await loginPage.fillEmail('wrong@example.com');
    await loginPage.fillPassword('wrongpassword');
    await loginPage.clickSubmit();

    await expect(loginPage.errorMessage).toBeVisible();
    await expect(loginPage.errorMessage).toContainText('Invalid credentials');
  });

  test('enforces dual-channel verification for new device', async ({ page }) => {
    await loginPage.fillEmail('newdevice@forward-inheritance.com');
    await loginPage.fillPassword('Test123!@#');
    await loginPage.clickSubmit();

    // Should redirect to verification page
    await expect(page).toHaveURL('/verify');
    
    // Verify both email and SMS code inputs are present
    await expect(page.locator('[data-testid="email-code-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="sms-code-input"]')).toBeVisible();
  });
});

// create-ffc.spec.ts - FFC Creation E2E Test
import { test, expect } from '@playwright/test';
import { authenticateUser } from '../../support/helpers';

test.describe('FFC Creation', () => {
  test.beforeEach(async ({ page }) => {
    await authenticateUser(page);
  });

  test('creates new Forward Family Circle', async ({ page }) => {
    await page.click('[data-testid="create-ffc-button"]');
    
    // Fill FFC details
    await page.fill('[name="ffcName"]', 'Smith Family Trust');
    await page.fill('[name="description"]', 'Family estate planning');
    
    // Add family members
    await page.click('[data-testid="add-member-button"]');
    await page.fill('[name="memberEmail"]', 'spouse@example.com');
    await page.fill('[name="memberPhone"]', '+1234567890');
    await page.selectOption('[name="role"]', 'beneficiary');
    
    await page.click('[type="submit"]');

    // Verify FFC created
    await expect(page.locator('[data-testid="ffc-card"]')).toContainText('Smith Family Trust');
    
    // Verify invitation sent
    await expect(page.locator('[data-testid="toast-notification"]')).toContainText(
      'Invitation sent to spouse@example.com'
    );
  });
});
```

### Test Data Management

```typescript
// test-data-builder.ts
export class TestDataBuilder {
  static user(overrides = {}) {
    return {
      email: `test-${Date.now()}@example.com`,
      password: 'Test123!@#',
      firstName: 'John',
      lastName: 'Doe',
      phone: '+11234567890',
      ...overrides,
    };
  }

  static asset(overrides = {}) {
    return {
      name: 'Test Asset',
      category: 'real_estate',
      value: 500000,
      description: 'Test property',
      ...overrides,
    };
  }

  static ffc(overrides = {}) {
    return {
      name: 'Test Family Circle',
      description: 'Test FFC for automated tests',
      ...overrides,
    };
  }
}
```

### Continuous Integration Testing

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:unit
      - uses: codecov/codecov-action@v3

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: testpass
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
      # Note: For production, use DynamoDB ($5-10/month) or Upstash Redis ($10-30/month)
      # Both provide pay-per-use pricing vs ElastiCache's $150+/month always-on cost
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run db:migrate:test
      - run: npm run test:integration

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npx playwright install
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

## Coding Standards

### Critical Fullstack Rules

These are MANDATORY rules that prevent common mistakes and ensure consistency across the codebase:

#### Database Access Rules
- **NEVER access tables directly** - All database operations MUST use stored procedures
- **Use parameterized calls** - Never concatenate SQL strings
- **Handle connection pooling** - Always release connections in finally blocks
- **Transaction boundaries** - Wrap related operations in transactions

```typescript
// ❌ WRONG - Direct table access
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// ✅ CORRECT - Using proper database query (no sp_get_user_by_id procedure exists)
const user = await db.query('SELECT * FROM users WHERE id = $1 AND tenant_id = current_tenant_id()', [userId]);
```

#### Type Safety Rules
- **Define all types in packages/shared** - Never duplicate type definitions
- **Use strict TypeScript** - No `any` types without explicit justification
- **Validate at boundaries** - Input validation on all API endpoints
- **Type all API responses** - Including error responses

```typescript
// packages/shared/types/user.ts
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
}

// ❌ WRONG - Local type definition
interface User { /* ... */ }

// ✅ CORRECT - Import from shared
import { User } from '@fwd/shared/types';
```

#### API Communication Rules
- **No direct HTTP calls in components** - Always use service layer
- **Centralized error handling** - Use standard error interceptor
- **Request/response logging** - All API calls must be logged
- **Timeout configuration** - 30s default, configurable per endpoint

```typescript
// ❌ WRONG - Direct fetch in component
const data = await fetch('/api/assets');

// ✅ CORRECT - Using service layer
import { assetService } from '@/services';
const data = await assetService.getAssets();
```

#### State Management Rules
- **Immutable updates only** - Never mutate state directly
- **Single source of truth** - One store per domain
- **Async actions in services** - Keep stores synchronous
- **Normalize complex data** - Use entity adapters for collections

```typescript
// ❌ WRONG - Direct mutation
state.users.push(newUser);

// ✅ CORRECT - Immutable update
state.users = [...state.users, newUser];
```

#### Security Rules
- **Never store sensitive data in localStorage** - Use secure cookies or memory
- **Sanitize all user input** - Use DOMPurify for HTML content
- **Environment variables only through config** - Never access process.env directly
- **No secrets in code** - Use AWS Secrets Manager

```typescript
// ❌ WRONG - Direct env access
const apiKey = process.env.API_KEY;

// ✅ CORRECT - Through config module
import { config } from '@/config';
const apiKey = config.get('apiKey');
```

### Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| **Files** | | |
| React Components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase | `useAuth.ts` |
| Services | camelCase | `authService.ts` |
| Utils | kebab-case | `date-formatter.ts` |
| Tests | .test or .spec | `Button.test.tsx` |
| **Code** | | |
| Components | PascalCase | `function UserCard() {}` |
| Functions | camelCase | `function calculateTotal() {}` |
| Constants | UPPER_SNAKE | `const MAX_RETRIES = 3` |
| Interfaces | PascalCase with I prefix | `interface IUserService {}` |
| Types | PascalCase | `type UserRole = 'admin' \| 'user'` |
| Enums | PascalCase | `enum Status { Active, Inactive }` |
| **Database** | | |
| Tables | snake_case | `user_sessions` |
| Columns | snake_case | `created_at` |
| Stored Procedures | sp_ prefix | `sp_create_user` |
| Indexes | idx_ prefix | `idx_users_email` |
| Constraints | valid_ or chk_ prefix | `valid_email_format` |
| **API** | | |
| Routes | kebab-case | `/api/user-profile` |
| Query params | camelCase | `?userId=123&includeAssets=true` |
| Request body | camelCase | `{ firstName: 'John' }` |
| Response fields | camelCase | `{ userId: '123' }` |

### File Organization Standards

#### Component Files
```typescript
// UserProfile.tsx - Component file structure
import React from 'react';
import { useAuth } from '@/hooks';
import { Button } from '@/components';
import type { User } from '@fwd/shared/types';
import styles from './UserProfile.module.css';

interface UserProfileProps {
  user: User;
  onEdit?: () => void;
}

export function UserProfile({ user, onEdit }: UserProfileProps) {
  // Hooks first
  const { isAdmin } = useAuth();
  
  // State declarations
  const [isEditing, setIsEditing] = useState(false);
  
  // Computed values
  const fullName = `${user.firstName} ${user.lastName}`;
  
  // Event handlers
  const handleEdit = () => {
    setIsEditing(true);
    onEdit?.();
  };
  
  // Render
  return (
    <div className={styles.container}>
      {/* Component JSX */}
    </div>
  );
}
```

#### Service Files
```typescript
// assetService.ts - Service file structure
import { apiClient } from '@/lib/api-client';
import type { Asset, CreateAssetDto } from '@fwd/shared/types';

class AssetService {
  private readonly basePath = '/api/assets';

  async getAssets(ffcId: string): Promise<Asset[]> {
    return apiClient.get(`${this.basePath}`, { params: { ffcId } });
  }

  async createAsset(data: CreateAssetDto): Promise<Asset> {
    return apiClient.post(this.basePath, data);
  }

  async updateAsset(id: string, data: Partial<Asset>): Promise<Asset> {
    return apiClient.patch(`${this.basePath}/${id}`, data);
  }

  async deleteAsset(id: string): Promise<void> {
    return apiClient.delete(`${this.basePath}/${id}`);
  }
}

export const assetService = new AssetService();
```

### Code Quality Standards

#### Function Complexity
- Maximum cyclomatic complexity: 10
- Maximum function length: 50 lines
- Maximum file length: 300 lines
- Maximum function parameters: 4 (use object for more)

#### Import Organization
```typescript
// 1. External imports
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

// 2. Internal absolute imports
import { Button, Card } from '@/components';
import { useAuth } from '@/hooks';

// 3. Relative imports
import { LocalComponent } from './LocalComponent';

// 4. Type imports
import type { User, Asset } from '@fwd/shared/types';

// 5. Style imports
import styles from './Component.module.css';
```

#### Error Handling Standards
```typescript
// Always use custom error classes
class ValidationError extends Error {
  constructor(message: string, public field?: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

// Always handle errors explicitly
try {
  const result = await riskyOperation();
} catch (error) {
  // Log error with context
  logger.error('Operation failed', { error, context: { userId } });
  
  // Re-throw or handle appropriately
  if (error instanceof ValidationError) {
    return { error: error.message, field: error.field };
  }
  
  throw new Error('An unexpected error occurred');
}
```

### Documentation Standards (JSDoc)

All code documentation MUST use JSDoc style comments for consistency and tooling support.

#### Component Documentation
```typescript
/**
 * UserProfile displays user information and provides edit capabilities
 * 
 * @component
 * @example
 * <UserProfile user={currentUser} onEdit={handleEdit} />
 * 
 * @param {Object} props - Component props
 * @param {User} props.user - User object to display
 * @param {Function} [props.onEdit] - Optional callback when edit is clicked
 * @returns {JSX.Element} Rendered user profile component
 */
export function UserProfile({ user, onEdit }: UserProfileProps): JSX.Element {
  // Implementation
}
```

#### Function Documentation
```typescript
/**
 * Calculates the total value of assets in a Forward Family Circle
 * 
 * @param {Asset[]} assets - Array of assets to calculate
 * @param {string} [currency='USD'] - Target currency for conversion
 * @returns {number} Total value in specified currency
 * @throws {ValidationError} If assets array is empty
 * 
 * @example
 * const total = calculateTotalValue(assets, 'EUR');
 */
function calculateTotalValue(assets: Asset[], currency = 'USD'): number {
  // Implementation
}
```

#### Class Documentation
```typescript
/**
 * Service for managing asset operations
 * 
 * @class AssetService
 * @description Handles all asset-related API calls and business logic
 */
class AssetService {
  /**
   * Retrieves all assets for a given FFC
   * 
   * @param {string} ffcId - Forward Family Circle ID
   * @returns {Promise<Asset[]>} Array of assets
   * @throws {ApiError} If request fails
   */
  async getAssets(ffcId: string): Promise<Asset[]> {
    // Implementation
  }
}
```

#### Interface/Type Documentation
```typescript
/**
 * Represents a user in the system
 * 
 * @interface User
 * @property {string} id - Unique identifier
 * @property {string} email - User's email address
 * @property {string} firstName - User's first name
 * @property {string} lastName - User's last name
 * @property {UserRole} role - User's role in the system
 */
interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
}
```

#### Hook Documentation
```typescript
/**
 * Custom hook for authentication state and operations
 * 
 * @returns {Object} Auth context value
 * @returns {boolean} returns.isAuthenticated - Whether user is logged in
 * @returns {User|null} returns.user - Current user object
 * @returns {Function} returns.login - Login function
 * @returns {Function} returns.logout - Logout function
 * 
 * @example
 * const { user, login, logout } = useAuth();
 */
export function useAuth() {
  // Implementation
}
```

#### API Endpoint Documentation
```typescript
/**
 * Creates a new asset in the system
 * 
 * @route POST /api/assets
 * @group Assets - Asset management operations
 * @param {CreateAssetDto} request.body.required - Asset creation data
 * @param {string} request.headers.authorization - Bearer token
 * @returns {Asset} 201 - Created asset object
 * @returns {Error} 400 - Validation error
 * @returns {Error} 401 - Unauthorized
 * @returns {Error} 500 - Server error
 * 
 * @security Bearer
 */
async function createAsset(req: Request, res: Response) {
  // Implementation
}
```

### Git Commit Standards

Follow Conventional Commits specification:

```bash
# Format: <type>(<scope>): <subject>

# Types:
feat: New feature
fix: Bug fix
docs: Documentation changes
style: Code style changes (formatting, etc)
refactor: Code refactoring
test: Test additions or fixes
chore: Build process or auxiliary tool changes

# Examples:
feat(auth): implement dual-channel verification
fix(assets): correct value calculation for foreign currency
docs(api): update asset endpoint documentation
test(ffc): add integration tests for member invitation
```

### Code Review Checklist

Before submitting PR, ensure:

- [ ] All tests pass
- [ ] Code coverage meets minimum (75%)
- [ ] No console.log statements
- [ ] No commented-out code
- [ ] All TODO comments have ticket numbers
- [ ] Types are properly defined
- [ ] Error handling is comprehensive
- [ ] Security implications considered
- [ ] Performance impact assessed
- [ ] Documentation updated (JSDoc format)

## Error Handling Strategy

### Error Flow

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant API Gateway
    participant Backend
    participant Database
    participant Monitoring

    User->>Frontend: Performs action
    Frontend->>Frontend: Client-side validation
    alt Validation fails
        Frontend-->>User: Show validation error
    else Validation passes
        Frontend->>API Gateway: API request
        API Gateway->>Backend: Forward request
        Backend->>Database: Execute stored procedure
        
        alt Database error
            Database-->>Backend: Error response
            Backend->>Backend: Log error details
            Backend->>Monitoring: Send error metrics
            Backend-->>API Gateway: Formatted error
            API Gateway-->>Frontend: Error response
            Frontend->>Frontend: Handle error
            Frontend-->>User: Display user-friendly message
        else Success
            Database-->>Backend: Success response
            Backend-->>API Gateway: Success response
            API Gateway-->>Frontend: Success response
            Frontend-->>User: Update UI
        end
    end
```

### Error Response Format

All API errors follow a consistent format for predictable client-side handling:

```typescript
/**
 * Standard error response structure
 * 
 * @interface ApiError
 */
interface ApiError {
  error: {
    code: string;           // Machine-readable error code
    message: string;        // Human-readable message
    details?: Record<string, any>; // Additional error context
    field?: string;         // Field that caused the error (validation)
    timestamp: string;      // ISO 8601 timestamp
    requestId: string;      // Unique request identifier for tracing
    retryable: boolean;     // Whether client should retry
  };
  statusCode: number;       // HTTP status code
}

// Example error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "field": "email",
    "details": {
      "pattern": "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
      "provided": "invalid.email"
    },
    "timestamp": "2025-01-06T10:30:00Z",
    "requestId": "req_abc123xyz",
    "retryable": false
  },
  "statusCode": 400
}
```

### Error Codes and Categories

```typescript
/**
 * Centralized error codes for the platform
 */
enum ErrorCode {
  // Authentication Errors (401)
  AUTH_TOKEN_EXPIRED = 'AUTH_TOKEN_EXPIRED',
  AUTH_TOKEN_INVALID = 'AUTH_TOKEN_INVALID',
  AUTH_CREDENTIALS_INVALID = 'AUTH_CREDENTIALS_INVALID',
  AUTH_SESSION_EXPIRED = 'AUTH_SESSION_EXPIRED',
  AUTH_MFA_REQUIRED = 'AUTH_MFA_REQUIRED',
  AUTH_MFA_INVALID = 'AUTH_MFA_INVALID',
  
  // Authorization Errors (403)
  AUTHZ_INSUFFICIENT_PERMISSIONS = 'AUTHZ_INSUFFICIENT_PERMISSIONS',
  AUTHZ_RESOURCE_FORBIDDEN = 'AUTHZ_RESOURCE_FORBIDDEN',
  AUTHZ_FFC_ACCESS_DENIED = 'AUTHZ_FFC_ACCESS_DENIED',
  AUTHZ_ASSET_ACCESS_DENIED = 'AUTHZ_ASSET_ACCESS_DENIED',
  
  // Validation Errors (400)
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  VALIDATION_REQUIRED_FIELD = 'VALIDATION_REQUIRED_FIELD',
  VALIDATION_INVALID_FORMAT = 'VALIDATION_INVALID_FORMAT',
  VALIDATION_OUT_OF_RANGE = 'VALIDATION_OUT_OF_RANGE',
  
  // Business Logic Errors (400/409)
  BUSINESS_DUPLICATE_ENTRY = 'BUSINESS_DUPLICATE_ENTRY',
  BUSINESS_INVALID_STATE = 'BUSINESS_INVALID_STATE',
  BUSINESS_LIMIT_EXCEEDED = 'BUSINESS_LIMIT_EXCEEDED',
  BUSINESS_INVITATION_EXPIRED = 'BUSINESS_INVITATION_EXPIRED',
  
  // Resource Errors (404)
  RESOURCE_NOT_FOUND = 'RESOURCE_NOT_FOUND',
  RESOURCE_DELETED = 'RESOURCE_DELETED',
  
  // Rate Limiting (429)
  RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED',
  
  // Server Errors (500)
  SERVER_INTERNAL_ERROR = 'SERVER_INTERNAL_ERROR',
  SERVER_DATABASE_ERROR = 'SERVER_DATABASE_ERROR',
  SERVER_EXTERNAL_SERVICE_ERROR = 'SERVER_EXTERNAL_SERVICE_ERROR',
  
  // Service Unavailable (503)
  SERVICE_MAINTENANCE = 'SERVICE_MAINTENANCE',
  SERVICE_OVERLOADED = 'SERVICE_OVERLOADED',
}
```

### Frontend Error Handling

#### Global Error Boundary

```typescript
/**
 * Global error boundary for catching React errors
 * 
 * @component
 */
class GlobalErrorBoundary extends React.Component<Props, State> {
  state = { hasError: false, error: null };
  
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log to monitoring service
    logger.error('React error boundary caught error', {
      error: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
    });
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    
    return this.props.children;
  }
}
```

#### API Error Interceptor

```typescript
/**
 * Axios interceptor for handling API errors globally
 */
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ApiError>) => {
    const { response, config } = error;
    
    if (!response) {
      // Network error
      showNotification({
        type: 'error',
        message: 'Network error. Please check your connection.',
      });
      return Promise.reject(error);
    }
    
    const { statusCode, error: errorData } = response.data;
    
    // Handle specific error codes
    switch (errorData.code) {
      case ErrorCode.AUTH_TOKEN_EXPIRED:
        // Try to refresh token
        const refreshed = await authService.refreshToken();
        if (refreshed && config) {
          // Retry original request
          return apiClient(config);
        }
        // Redirect to login
        window.location.href = '/login';
        break;
        
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        showNotification({
          type: 'warning',
          message: 'Too many requests. Please slow down.',
          duration: 5000,
        });
        break;
        
      case ErrorCode.SERVER_INTERNAL_ERROR:
        showNotification({
          type: 'error',
          message: 'Something went wrong. Please try again later.',
        });
        // Log to monitoring
        logger.error('Server error', { 
          requestId: errorData.requestId,
          endpoint: config?.url,
        });
        break;
        
      default:
        // Show error message from server
        showNotification({
          type: 'error',
          message: errorData.message,
        });
    }
    
    return Promise.reject(error);
  }
);
```

#### Component-Level Error Handling

```typescript
/**
 * Custom hook for handling async operations with error handling
 */
function useAsyncOperation<T>() {
  const [state, setState] = useState<{
    loading: boolean;
    error: Error | null;
    data: T | null;
  }>({
    loading: false,
    error: null,
    data: null,
  });
  
  const execute = useCallback(async (asyncFunction: () => Promise<T>) => {
    setState({ loading: true, error: null, data: null });
    
    try {
      const data = await asyncFunction();
      setState({ loading: false, error: null, data });
      return data;
    } catch (error) {
      const err = error instanceof Error ? error : new Error('Unknown error');
      setState({ loading: false, error: err, data: null });
      throw err;
    }
  }, []);
  
  return { ...state, execute };
}

// Usage in component
function AssetList() {
  const { loading, error, data, execute } = useAsyncOperation<Asset[]>();
  
  useEffect(() => {
    execute(() => assetService.getAssets(ffcId))
      .catch((err) => {
        // Component-specific error handling
        if (err.code === ErrorCode.AUTHZ_FFC_ACCESS_DENIED) {
          navigate('/access-denied');
        }
      });
  }, [ffcId]);
  
  if (error) {
    return <ErrorMessage error={error} retry={() => execute(...)} />;
  }
  
  // Render component
}
```

### Backend Error Handling

#### Custom Error Classes

```typescript
/**
 * Base application error class
 */
abstract class AppError extends Error {
  public readonly code: ErrorCode;
  public readonly statusCode: number;
  public readonly details?: Record<string, any>;
  public readonly retryable: boolean;
  
  constructor(
    code: ErrorCode,
    message: string,
    statusCode: number,
    details?: Record<string, any>,
    retryable = false
  ) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
    this.retryable = retryable;
    Error.captureStackTrace(this, this.constructor);
  }
  
  toJSON(): ApiError {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
        timestamp: new Date().toISOString(),
        requestId: getCurrentRequestId(),
        retryable: this.retryable,
      },
      statusCode: this.statusCode,
    };
  }
}

/**
 * Validation error class
 */
class ValidationError extends AppError {
  constructor(message: string, field?: string, details?: Record<string, any>) {
    super(
      ErrorCode.VALIDATION_ERROR,
      message,
      400,
      { field, ...details },
      false
    );
  }
}

/**
 * Authentication error class
 */
class AuthenticationError extends AppError {
  constructor(code: ErrorCode = ErrorCode.AUTH_CREDENTIALS_INVALID, message = 'Authentication failed') {
    super(code, message, 401, undefined, false);
  }
}

/**
 * Database error wrapper
 */
class DatabaseError extends AppError {
  constructor(originalError: any) {
    const message = 'Database operation failed';
    const details = {
      code: originalError.code,
      detail: originalError.detail,
    };
    super(ErrorCode.SERVER_DATABASE_ERROR, message, 500, details, true);
  }
}
```

#### NestJS Exception Filter

```typescript
/**
 * Global exception filter for NestJS
 */
import { 
  ExceptionFilter, 
  Catch, 
  ArgumentsHost, 
  HttpException,
  HttpStatus,
  Logger 
} from '@nestjs/common';
import { Response } from 'express';
import { SlonikError, InvalidInputError, DataIntegrityError } from 'slonik';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let error: any = {};

    // Handle HTTP exceptions
    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      message = exception.message;
      
      if (typeof exceptionResponse === 'object') {
        error = exceptionResponse;
      }
    }
    // Handle Slonik database errors
    else if (exception instanceof SlonikError) {
      if (exception instanceof InvalidInputError) {
        status = HttpStatus.BAD_REQUEST;
        message = 'Invalid database input';
      } else if (exception instanceof DataIntegrityError) {
        status = HttpStatus.CONFLICT;
        message = 'Data integrity violation';
      } else {
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        message = 'Database operation failed';
      }
      error = {
        code: exception.code,
        message: exception.message,
      };
      
      // Handle specific PostgreSQL errors
      if ((exception as any).code?.startsWith('23')) {
        if ((exception as any).code === '23505') {
          message = 'Duplicate entry detected';
          status = HttpStatus.CONFLICT;
        } else if ((exception as any).code === '23503') {
          message = 'Foreign key constraint violation';
        }
      }
    }
    // Handle validation errors
    else if ((exception as any)?.name === 'ValidationError') {
      status = HttpStatus.BAD_REQUEST;
      message = 'Validation failed';
      error = {
        errors: (exception as any).details || (exception as any).errors,
      };
    }
    // Handle custom AppError
    else if (exception instanceof AppError) {
      status = exception.statusCode;
      message = exception.message;
      error = exception.toJSON();
    }
    
    // Log the error
    this.logger.error(
      `${request.method} ${request.url} - ${status} - ${message}`,
      {
        error: exception,
        stack: (exception as any)?.stack,
        userId: request.user?.id,
        requestId: request.id,
        body: request.body,
      }
    );

    // Send response
    response.status(status).json({
      statusCode: status,
      message,
      error,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }
}

// Register in main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Register global exception filter
  app.useGlobalFilters(new AllExceptionsFilter());
  
  await app.listen(3000);
}
```

#### Service Layer Error Handling

```typescript
/**
 * Service method with comprehensive error handling
 */
class AssetService {
  async createAsset(data: CreateAssetDto, userId: string): Promise<Asset> {
    // Input validation
    const validation = assetSchema.validate(data);
    if (validation.error) {
      throw new ValidationError(validation.error.message);
    }
    
    // Start transaction
    const client = await db.getClient();
    
    try {
      await client.query('BEGIN');
      
      // Check permissions
      const hasPermission = await this.checkFFCPermission(data.ffcId, userId);
      if (!hasPermission) {
        throw new AuthorizationError('No permission to add assets to this FFC');
      }
      
      // Execute stored procedure
      const result = await client.func('sp_create_asset', [
        data.tenantId,
        data.ownerPersonaId,
        data.assetType,
        data.name,
        data.description,
        data.ownershipPercentage || 100.00,
        userId,
      ]);
      
      if (!result || result.length === 0) {
        throw new AppError(
          ErrorCode.SERVER_DATABASE_ERROR,
          'Failed to create asset',
          500
        );
      }
      
      await client.query('COMMIT');
      
      // Audit log
      await auditService.log({
        action: 'CREATE_ASSET',
        entityType: 'asset',
        entityId: result[0].id,
        userId,
      });
      
      return result[0];
      
    } catch (error) {
      await client.query('ROLLBACK');
      
      // Re-throw known errors
      if (error instanceof AppError) {
        throw error;
      }
      
      // Wrap unknown errors
      throw new DatabaseError(error);
      
    } finally {
      client.release();
    }
  }
}
```

### Error Recovery Strategies

#### Retry Logic

```typescript
/**
 * Retry decorator for transient failures
 */
function retryable(maxAttempts = 3, backoffMs = 1000) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = async function (...args: any[]) {
      let lastError: Error;
      
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          return await originalMethod.apply(this, args);
        } catch (error) {
          lastError = error;
          
          // Don't retry non-retryable errors
          if (error instanceof AppError && !error.retryable) {
            throw error;
          }
          
          // Don't retry on last attempt
          if (attempt === maxAttempts) {
            throw error;
          }
          
          // Exponential backoff
          const delay = backoffMs * Math.pow(2, attempt - 1);
          await new Promise(resolve => setTimeout(resolve, delay));
          
          logger.warn(`Retrying operation ${propertyKey}, attempt ${attempt}/${maxAttempts}`);
        }
      }
      
      throw lastError!;
    };
    
    return descriptor;
  };
}

// Usage
class ExternalService {
  @retryable(3, 1000)
  async fetchData(): Promise<Data> {
    // Implementation that might fail transiently
  }
}
```

#### Circuit Breaker

```typescript
/**
 * Circuit breaker for external service calls
 */
class CircuitBreaker {
  private failures = 0;
  private lastFailureTime?: Date;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  
  constructor(
    private threshold = 5,
    private timeout = 60000, // 1 minute
    private resetTimeout = 30000 // 30 seconds
  ) {}
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime!.getTime() > this.resetTimeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new AppError(
          ErrorCode.SERVICE_UNAVAILABLE,
          'Service temporarily unavailable',
          503,
          undefined,
          true
        );
      }
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }
  
  private onFailure() {
    this.failures++;
    this.lastFailureTime = new Date();
    
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
      logger.error('Circuit breaker opened', {
        failures: this.failures,
        threshold: this.threshold,
      });
    }
  }
}
```

### Error Monitoring and Alerting

```typescript
/**
 * Error tracking integration
 */
class ErrorMonitor {
  /**
   * Track error occurrence
   */
  trackError(error: Error | AppError, context: Record<string, any>) {
    // Send to monitoring service (e.g., Sentry, DataDog)
    if (process.env.NODE_ENV === 'production') {
      Sentry.captureException(error, {
        tags: {
          code: error instanceof AppError ? error.code : 'UNKNOWN',
        },
        extra: context,
      });
    }
    
    // Increment metrics
    metrics.increment('errors.total', {
      code: error instanceof AppError ? error.code : 'UNKNOWN',
      statusCode: error instanceof AppError ? error.statusCode : 500,
    });
    
    // Alert on critical errors
    if (error instanceof AppError && error.statusCode >= 500) {
      this.sendAlert(error, context);
    }
  }
  
  /**
   * Send alert for critical errors
   */
  private sendAlert(error: AppError, context: Record<string, any>) {
    // Send to PagerDuty, Slack, etc.
    alertService.send({
      severity: 'critical',
      title: `Critical error: ${error.code}`,
      description: error.message,
      details: {
        ...context,
        stack: error.stack,
      },
    });
  }
}

export const errorMonitor = new ErrorMonitor();
```

## Monitoring and Observability

### Monitoring Stack

#### AWS Native Monitoring
```yaml
CloudWatch:
  - Metrics: System and application metrics
  - Logs: Centralized log aggregation
  - Alarms: Threshold-based alerting
  - Dashboards: Real-time visualization
  - Insights: Log analysis and querying

X-Ray:
  - Distributed tracing
  - Service map visualization
  - Performance bottleneck identification
  - Request flow analysis

CloudTrail:
  - API activity logging
  - Security audit trail
  - Compliance reporting
  - Change tracking
```

#### Application Performance Monitoring (APM)

**Frontend Monitoring - Datadog RUM**
```typescript
/**
 * Initialize Datadog Real User Monitoring
 */
import { datadogRum } from '@datadog/browser-rum';

datadogRum.init({
  applicationId: process.env.REACT_APP_DD_APP_ID,
  clientToken: process.env.REACT_APP_DD_CLIENT_TOKEN,
  site: 'datadoghq.com',
  service: 'forward-inheritance-frontend',
  env: process.env.NODE_ENV,
  version: process.env.REACT_APP_VERSION,
  sessionSampleRate: 100,
  sessionReplaySampleRate: 20,
  trackUserInteractions: true,
  trackResources: true,
  trackLongTasks: true,
  defaultPrivacyLevel: 'mask-user-input',
});

// Track custom user actions
datadogRum.addAction('asset_created', {
  assetType: 'real_estate',
  value: 500000,
});
```

**Backend Monitoring - Datadog APM**
```typescript
/**
 * Initialize Datadog tracing
 */
import tracer from 'dd-trace';

tracer.init({
  service: 'forward-inheritance-api',
  env: process.env.NODE_ENV,
  version: process.env.API_VERSION,
  logInjection: true,
  runtimeMetrics: true,
  profiling: true,
  analytics: true,
});

// Custom span tracking
export function trackDatabaseOperation<T>(
  operation: string,
  fn: () => Promise<T>
): Promise<T> {
  const span = tracer.startSpan('db.query', {
    'db.operation': operation,
    'db.system': 'postgresql',
  });
  
  return fn()
    .then(result => {
      span.setTag('db.rows_affected', result.rowCount);
      return result;
    })
    .catch(error => {
      span.setTag('error', true);
      span.setTag('error.message', error.message);
      throw error;
    })
    .finally(() => {
      span.finish();
    });
}
```

#### Compliance Monitoring - Vanta

```typescript
/**
 * Vanta compliance monitoring integration
 * API Docs: /docs/requirements/API/Vanta/vanta-api-documentation.md
 */
import { VantaAPIClient } from './integrations/vanta';

const vantaClient = new VantaAPIClient(
  process.env.VANTA_CLIENT_ID!,
  process.env.VANTA_CLIENT_SECRET!
);

// Monitor SOC 2 control status
async function checkComplianceStatus() {
  const soc2Status = await vantaClient.getSOC2Status();
  const failingComputers = await vantaClient.getFailingComputers();
  
  // Alert on compliance issues
  if (failingComputers.data.length > 0) {
    alertService.send({
      severity: 'high',
      title: 'SOC 2 Compliance Issue',
      description: `${failingComputers.data.length} computers failing security checks`,
    });
  }
}
```

#### Error Tracking - Sentry

```typescript
/**
 * Sentry configuration for error tracking
 */
import * as Sentry from '@sentry/node';
import { ProfilingIntegration } from '@sentry/profiling-node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.API_VERSION,
  integrations: [
    new Sentry.Integrations.Http({ tracing: true }),
    new Sentry.Integrations.Express({ app }),
    new Sentry.Integrations.Postgres(),
    new ProfilingIntegration(),
  ],
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  profilesSampleRate: 0.1,
  beforeSend(event) {
    // Scrub PII from error events
    if (event.request?.data) {
      event.request.data = scrubPII(event.request.data);
    }
    return event;
  },
});

// Enhanced error context
Sentry.configureScope((scope) => {
  scope.setTag('tenant_id', getTenantId());
  scope.setContext('session', {
    userId: getUserId(),
    ffcId: getCurrentFFCId(),
  });
});
```

### Key Metrics

#### Frontend Metrics

**Core Web Vitals**
```typescript
/**
 * Track Core Web Vitals
 */
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics(metric: Metric) {
  // Send to monitoring service
  datadogRum.addTiming(metric.name, metric.value);
  
  // Log to console in development
  if (process.env.NODE_ENV === 'development') {
    console.log(`${metric.name}: ${metric.value}`);
  }
}

// Largest Contentful Paint (LCP) - Target: < 2.5s
getLCP(sendToAnalytics);

// First Input Delay (FID) - Target: < 100ms
getFID(sendToAnalytics);

// Cumulative Layout Shift (CLS) - Target: < 0.1
getCLS(sendToAnalytics);

// First Contentful Paint (FCP) - Target: < 1.0s
getFCP(sendToAnalytics);

// Time to First Byte (TTFB) - Target: < 600ms
getTTFB(sendToAnalytics);
```

**Custom Frontend Metrics**
```typescript
/**
 * Application-specific frontend metrics
 */
class FrontendMetrics {
  // User engagement metrics
  trackUserAction(action: string, metadata?: Record<string, any>) {
    metrics.increment('user.actions', {
      action,
      page: window.location.pathname,
      ...metadata,
    });
  }
  
  // Feature usage metrics
  trackFeatureUsage(feature: string) {
    metrics.increment('feature.usage', { feature });
  }
  
  // Performance metrics
  trackApiCallDuration(endpoint: string, duration: number) {
    metrics.histogram('api.call.duration', duration, { endpoint });
  }
  
  // Business metrics
  trackAssetCreated(assetType: string, value: number) {
    metrics.increment('assets.created', { type: assetType });
    metrics.gauge('assets.total_value', value);
  }
  
  // Error metrics
  trackError(error: Error, context: Record<string, any>) {
    metrics.increment('frontend.errors', {
      type: error.name,
      page: window.location.pathname,
      ...context,
    });
  }
}
```

#### Backend Metrics

**System Metrics**
```typescript
/**
 * System and infrastructure metrics
 */
interface SystemMetrics {
  // Resource utilization
  cpu_usage: number;           // Target: < 70%
  memory_usage: number;         // Target: < 80%
  disk_usage: number;          // Target: < 75%
  
  // Network
  network_in: number;          // bytes/sec
  network_out: number;         // bytes/sec
  active_connections: number;   // Target: < 1000
  
  // Database
  db_connections_active: number;     // Target: < 80
  db_connections_idle: number;       // Target: > 10
  db_replication_lag: number;        // Target: < 1s
}
```

**Application Metrics**
```typescript
/**
 * Application-level metrics collection
 */
class BackendMetrics {
  // Request metrics
  trackRequest(method: string, path: string, statusCode: number, duration: number) {
    metrics.increment('http.requests', {
      method,
      path,
      status: statusCode,
    });
    
    metrics.histogram('http.request.duration', duration, {
      method,
      path,
    });
    
    // Track error rates
    if (statusCode >= 500) {
      metrics.increment('http.errors.5xx', { path });
    } else if (statusCode >= 400) {
      metrics.increment('http.errors.4xx', { path });
    }
  }
  
  // Database metrics
  trackDatabaseQuery(operation: string, table: string, duration: number) {
    metrics.histogram('db.query.duration', duration, {
      operation,
      table,
    });
    
    metrics.increment('db.queries', {
      operation,
      table,
    });
  }
  
  // Business metrics
  trackUserRegistration(source: string) {
    metrics.increment('users.registered', { source });
  }
  
  trackFFCCreated(memberCount: number) {
    metrics.increment('ffc.created');
    metrics.gauge('ffc.members', memberCount);
  }
  
  // Cache metrics
  trackCacheHit(key: string) {
    metrics.increment('cache.hits', { key });
  }
  
  trackCacheMiss(key: string) {
    metrics.increment('cache.misses', { key });
  }
}
```

### Distributed Tracing

```typescript
/**
 * OpenTelemetry setup for distributed tracing
 */
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'forward-inheritance-api',
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.API_VERSION,
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-fs': {
        enabled: false, // Reduce noise
      },
    }),
  ],
});

sdk.start();

// Custom span creation
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('forward-inheritance');

export async function tracedOperation<T>(
  name: string,
  fn: () => Promise<T>,
  attributes?: Record<string, any>
): Promise<T> {
  const span = tracer.startSpan(name, { attributes });
  
  try {
    const result = await fn();
    span.setStatus({ code: SpanStatusCode.OK });
    return result;
  } catch (error) {
    span.setStatus({
      code: SpanStatusCode.ERROR,
      message: error.message,
    });
    span.recordException(error);
    throw error;
  } finally {
    span.end();
  }
}
```

### Logging Strategy

#### Structured Logging

```typescript
/**
 * Winston logger configuration with structured logging
 */
import winston from 'winston';
import { ElasticsearchTransport } from 'winston-elasticsearch';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json(),
  ),
  defaultMeta: {
    service: 'forward-inheritance-api',
    environment: process.env.NODE_ENV,
    version: process.env.API_VERSION,
  },
  transports: [
    // Console for development
    new winston.transports.Console({
      format: winston.format.simple(),
      level: 'debug',
    }),
    
    // CloudWatch for production
    new winston.transports.CloudWatch({
      logGroupName: '/aws/forward-inheritance/api',
      logStreamName: `${process.env.NODE_ENV}-${new Date().toISOString().split('T')[0]}`,
      level: 'info',
    }),
    
    // Elasticsearch for searching
    new ElasticsearchTransport({
      level: 'info',
      clientOpts: {
        node: process.env.ELASTICSEARCH_URL,
      },
      index: 'forward-inheritance-logs',
    }),
  ],
});

// Correlation ID middleware
export function correlationIdMiddleware(req: Request, res: Response, next: NextFunction) {
  const correlationId = req.headers['x-correlation-id'] || uuidv4();
  req.correlationId = correlationId;
  res.setHeader('X-Correlation-ID', correlationId);
  
  // Add to logger context
  logger.defaultMeta.correlationId = correlationId;
  next();
}
```

#### Log Levels and Standards

```typescript
/**
 * Logging standards and examples
 */

// ERROR - System errors requiring immediate attention
logger.error('Database connection failed', {
  error: error.message,
  stack: error.stack,
  query: sanitizedQuery,
  attempt: retryCount,
});

// WARN - Potential issues that don't stop operation
logger.warn('Rate limit approaching', {
  userId,
  currentRate: 95,
  limit: 100,
  endpoint: '/api/assets',
});

// INFO - Important business events
logger.info('Asset created', {
  assetId,
  assetType: 'real_estate',
  value: 500000,
  ffcId,
  userId,
});

// DEBUG - Detailed diagnostic information
logger.debug('Cache lookup', {
  key: cacheKey,
  hit: true,
  ttl: remainingTTL,
});

// AUDIT - Security and compliance events
logger.info('AUDIT: Permission granted', {
  userId,
  resource: 'asset',
  resourceId: assetId,
  permission: 'edit',
  granted: true,
});
```

### Alerting Rules

```yaml
# CloudWatch Alarms Configuration
Alarms:
  # High Error Rate
  - Name: HighErrorRate
    Metric: http.errors.5xx
    Threshold: 10
    Period: 300  # 5 minutes
    EvaluationPeriods: 2
    Action: 
      - SNS: critical-alerts
      - PagerDuty: on-call
  
  # Database Connection Pool Exhaustion
  - Name: DatabaseConnectionPoolExhaustion
    Metric: db.connections_active
    Threshold: 90
    Period: 60
    EvaluationPeriods: 3
    Action:
      - SNS: database-alerts
      - AutoScale: increase-connection-pool
  
  # High Response Time
  - Name: HighAPIResponseTime
    Metric: http.request.duration.p95
    Threshold: 2000  # 2 seconds
    Period: 300
    EvaluationPeriods: 2
    Action:
      - SNS: performance-alerts
  
  # Failed Login Attempts
  - Name: SuspiciousLoginActivity
    Metric: auth.failed_attempts
    Threshold: 50
    Period: 300
    EvaluationPeriods: 1
    Action:
      - SNS: security-alerts
      - Lambda: trigger-security-review
  
  # Low Disk Space
  - Name: LowDiskSpace
    Metric: disk_usage_percent
    Threshold: 85
    Period: 300
    EvaluationPeriods: 1
    Action:
      - SNS: infrastructure-alerts
      - Lambda: cleanup-old-logs
```

### Custom Dashboards

```typescript
/**
 * Dashboard configuration for key metrics
 */
const dashboards = {
  // Executive Dashboard
  executive: {
    widgets: [
      { type: 'number', metric: 'users.total', title: 'Total Users' },
      { type: 'number', metric: 'ffc.total', title: 'Total FFCs' },
      { type: 'number', metric: 'assets.total_value', title: 'Total Asset Value' },
      { type: 'line', metric: 'users.registered', title: 'User Growth' },
      { type: 'pie', metric: 'assets.by_type', title: 'Asset Distribution' },
    ],
  },
  
  // Operations Dashboard
  operations: {
    widgets: [
      { type: 'line', metric: 'http.request.rate', title: 'Request Rate' },
      { type: 'line', metric: 'http.request.duration.p95', title: 'Response Time (p95)' },
      { type: 'number', metric: 'http.errors.rate', title: 'Error Rate' },
      { type: 'gauge', metric: 'cpu_usage', title: 'CPU Usage' },
      { type: 'gauge', metric: 'memory_usage', title: 'Memory Usage' },
      { type: 'table', metric: 'top_errors', title: 'Top Errors' },
    ],
  },
  
  // Security Dashboard
  security: {
    widgets: [
      { type: 'number', metric: 'auth.failed_attempts', title: 'Failed Logins' },
      { type: 'map', metric: 'auth.login_locations', title: 'Login Locations' },
      { type: 'table', metric: 'suspicious_activity', title: 'Suspicious Activity' },
      { type: 'line', metric: 'api.rate_limit_violations', title: 'Rate Limit Violations' },
    ],
  },
};
```

### Health Checks

```typescript
/**
 * Comprehensive health check endpoints
 */
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/health/detailed', async (req, res) => {
  const checks = {
    api: 'ok',
    database: 'unknown',
    cache: 'unknown',
    s3: 'unknown',
    external_apis: {},
  };
  
  // Database check
  try {
    await db.query('SELECT 1');
    checks.database = 'ok';
  } catch (error) {
    checks.database = 'error';
  }
  
  // Cache check (in-memory for MVP, ElastiCache for scale)
  try {
    await cacheService.healthCheck();
    checks.cache = 'ok';
  } catch (error) {
    checks.cache = 'error';
  }
  
  // S3 check
  try {
    await s3.headBucket({ Bucket: process.env.S3_BUCKET }).promise();
    checks.s3 = 'ok';
  } catch (error) {
    checks.s3 = 'error';
  }
  
  // External API checks
  for (const [name, url] of Object.entries(externalAPIs)) {
    try {
      const response = await axios.get(`${url}/health`, { timeout: 5000 });
      checks.external_apis[name] = response.status === 200 ? 'ok' : 'degraded';
    } catch (error) {
      checks.external_apis[name] = 'error';
    }
  }
  
  const overallStatus = Object.values(checks).every(v => v === 'ok') ? 'healthy' : 'degraded';
  const statusCode = overallStatus === 'healthy' ? 200 : 503;
  
  res.status(statusCode).json({
    status: overallStatus,
    checks,
    timestamp: new Date().toISOString(),
    version: process.env.API_VERSION,
  });
});
```

### SLIs, SLOs, and SLAs

```yaml
# Service Level Indicators (SLIs)
SLIs:
  availability:
    metric: (successful_requests / total_requests) * 100
    measurement_window: 5_minutes
  
  latency:
    metric: http.request.duration.p95
    measurement_window: 5_minutes
  
  error_rate:
    metric: (error_requests / total_requests) * 100
    measurement_window: 5_minutes

# Service Level Objectives (SLOs)
SLOs:
  availability:
    target: 99.9%  # Three nines
    window: 30_days
  
  latency:
    target: 95% of requests < 1000ms
    window: 30_days
  
  error_rate:
    target: < 0.1%
    window: 30_days

# Service Level Agreements (SLAs)
SLAs:
  uptime:
    guarantee: 99.5%
    measurement_period: monthly
    credits:
      - below_99.5: 10%
      - below_99.0: 25%
      - below_95.0: 50%
  
  support_response:
    critical: 1_hour
    high: 4_hours
    medium: 1_business_day
    low: 3_business_days
```

## 📚 Quick Reference Guide

### 🚀 Essential Commands

#### Development Commands
```bash
# Start local development
npm run dev                    # Start both frontend and backend
npm run dev:frontend           # Start React app only  
npm run dev:backend           # Start Nest.js server only

# Database operations
npm run db:migrate            # Run database migrations
npm run db:types              # Generate pgTyped types
npm run db:seed               # Seed development data
npm run db:reset              # Reset database (dev only)

# Testing
npm run test                  # Run all tests
npm run test:unit             # Unit tests only
npm run test:e2e              # E2E tests only
npm run test:coverage         # Generate coverage report

# Build and deployment
npm run build                 # Build for production
npm run deploy:staging        # Deploy to staging
npm run deploy:production     # Deploy to production
```

#### Database Commands
```bash
# pgTyped operations
npx pgtyped -c pgtyped.config.json    # Generate types
npx pgtyped -w                         # Watch mode

# PostgreSQL direct access
psql -h localhost -d fwd_db -U fwd_user
```

### 🔧 Environment Variables Reference

#### Required Environment Variables
| Variable | Purpose | Example | Environment |
|----------|---------|---------|-------------|
| `DATABASE_URL` | PostgreSQL connection | `postgresql://user:pass@localhost:5432/fwd_db` | All |
| `AWS_REGION` | AWS services region | `us-west-1` | All |
| `COGNITO_USER_POOL_ID` | Authentication | `us-west-1_abc123` | All |
| `COGNITO_CLIENT_ID` | Client application | `1234567890abcdef` | All |
| `STRIPE_SECRET_KEY` | Payment processing | `sk_test_...` | All |
| `TWILIO_ACCOUNT_SID` | SMS service | `AC1234...` | All |
| `SENDGRID_API_KEY` | Email service | `SG.abc...` | All |

#### Optional Environment Variables
| Variable | Purpose | Default | Notes |
|----------|---------|---------|-------|
| `PORT` | Backend server port | `3001` | Development only |
| `NODE_ENV` | Environment mode | `development` | Auto-set in deployments |
| `LOG_LEVEL` | Logging verbosity | `info` | Use `debug` for development |
| `CACHE_TTL` | Cache timeout (seconds) | `300` | In-memory cache duration |

### 🏗️ Architecture Patterns Quick Reference

#### Database Query Patterns
```typescript
// Type-safe query with pgTyped
async getUserById(id: string): Promise<User | null> {
  const query = sql.type(getUserByIdQuery)`
    SELECT * FROM users WHERE id = ${id}
  `;
  const result = await this.pool.one(query);
  return result.rows[0] || null;
}

// Multi-tenant query pattern
async getAssetsByFFC(ffcId: string, tenantId: number): Promise<Asset[]> {
  return this.pool.any(sql.type(getAssetsByFFCQuery)`
    SELECT * FROM assets 
    WHERE ffc_id = ${ffcId} 
    AND tenant_id = ${tenantId}
  `);
}
```

#### Error Handling Patterns
```typescript
// Service layer error handling
async createAsset(data: CreateAssetDto): Promise<Asset> {
  try {
    return await this.assetRepository.create(data);
  } catch (error) {
    if (error.code === '23505') { // Unique violation
      throw new ConflictException('Asset already exists');
    }
    throw new InternalServerErrorException('Failed to create asset');
  }
}

// Controller error handling
@Post('assets')
async createAsset(@Body() data: CreateAssetDto) {
  try {
    return await this.assetService.createAsset(data);
  } catch (error) {
    this.logger.error('Asset creation failed', error.stack);
    throw error; // Re-throw for global exception filter
  }
}
```

#### Authentication Guard Patterns
```typescript
// Multi-tenant isolation guard
@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const tenantId = request.params.tenantId;
    
    return user.tenantId === parseInt(tenantId);
  }
}

// FFC membership guard
@UseGuards(FFCMembershipGuard)
@Get('ffc/:ffcId/assets')
async getFFCAssets(@Param('ffcId') ffcId: string) {
  // User membership verified by guard
}
```

### 🔍 Troubleshooting Guide

#### Common Development Issues

**Database Connection Issues**
```bash
# Check PostgreSQL service
sudo systemctl status postgresql

# Test connection
psql -h localhost -p 5432 -U fwd_user -d fwd_db

# Reset connection pool
# Restart backend service
```

**pgTyped Type Generation Issues**
```bash
# Ensure database is running and accessible
npm run db:types

# If types are stale, regenerate
rm -rf src/generated/db-types
npm run db:types
```

**Authentication Issues**
```bash
# Verify Cognito configuration
aws cognito-idp describe-user-pool --user-pool-id YOUR_POOL_ID

# Check environment variables
echo $COGNITO_USER_POOL_ID
echo $COGNITO_CLIENT_ID
```

**Build Issues**
```bash
# Clear all caches
npm run clean
npm install
npm run build

# Check for TypeScript errors
npx tsc --noEmit
```

#### Performance Debugging

**Database Query Performance**
```sql
-- Enable query timing
\timing

-- Analyze slow queries
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;

-- Check active connections
SELECT count(*) FROM pg_stat_activity;
```

**Memory Usage**
```bash
# Check Node.js memory usage
node --max-old-space-size=4096 dist/main.js

# Monitor memory in production
pm2 monit
```

#### Advanced Troubleshooting Scenarios

**Nest.js Application Issues**
```bash
# Service dependency injection errors
npm run build  # Check for circular dependencies
npm run lint   # Check for decorator issues

# Module import errors
# Check @Module() imports array
# Verify all services are in providers array
# Check file paths in imports

# Guard/Interceptor not working
# Verify @UseGuards() or @UseInterceptors() decorators
# Check execution context in guards
# Verify return values match expected types
```

**WebSocket Connection Issues**
```bash
# Socket.io connection failures
# Check CORS configuration in Nest.js
# Verify client/server Socket.io versions match
# Test with simple socket.io client

# Real-time updates not working
# Check room subscription logic
# Verify user authentication in socket middleware
# Test with socket.io admin UI
```

**AWS Services Debugging**
```bash
# Step Functions execution failures
aws stepfunctions describe-execution --execution-arn "arn:aws:..."
aws stepfunctions get-execution-history --execution-arn "arn:aws:..."

# Cognito authentication issues
aws cognito-idp admin-get-user --user-pool-id "pool-id" --username "user"
aws cognito-idp describe-user-pool-client --user-pool-id "pool" --client-id "client"

# SQS message processing issues
aws sqs get-queue-attributes --queue-url "url" --attribute-names All
aws sqs receive-message --queue-url "url" --max-number-of-messages 10
```

**Frontend Debugging**
```bash
# React component rendering issues
# Check React DevTools for component state
# Verify props are being passed correctly
# Check for key prop warnings in console

# State management debugging
# Use Zustand DevTools
# Check React Query DevTools for cache status
# Verify WebSocket connection status

# Build/Bundle issues
npm run analyze  # Analyze bundle size
# Check for circular imports
# Verify all dependencies are installed
```

**Performance Troubleshooting**
```typescript
// Database query performance
// Add query timing to Slonik
const pool = createPool(connectionString, {
  interceptors: [
    createQueryLoggingInterceptor(),
    createBenchmarkingInterceptor()
  ]
});

// API response time debugging
// Add timing middleware to Nest.js
@Injectable()
export class TimingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const start = Date.now();
    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - start;
        console.log(`${context.getHandler().name}: ${duration}ms`);
      })
    );
  }
}
```

**Production Issues Debugging**

**High Memory Usage**
```bash
# Node.js memory debugging
node --inspect dist/main.js
# Connect Chrome DevTools for heap snapshots

# PostgreSQL memory analysis
SELECT * FROM pg_stat_activity WHERE state = 'active';
SELECT query, mean_time, calls FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;
```

**High CPU Usage**
```bash
# Profile Node.js application
node --prof dist/main.js
node --prof-process isolate-*.log > processed.txt

# Database query analysis
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) your_slow_query;
```

**Container Issues**
```bash
# ECS task debugging
aws ecs describe-tasks --cluster cluster-name --tasks task-arn

# Docker container logs
aws logs get-log-events --log-group-name "/ecs/fwd-backend" 
--log-stream-name "stream-name"

# Resource utilization
aws cloudwatch get-metric-statistics --namespace "AWS/ECS" 
--metric-name CPUUtilization --dimensions Name=ServiceName,Value=fwd-backend
```

**Common Error Patterns and Solutions**

| Error Pattern | Likely Cause | Solution |
|---------------|--------------|----------|
| `Cannot read property 'id' of undefined` | Missing null checks | Add optional chaining: `user?.id` |
| `Connection terminated unexpectedly` | Database connection pool exhausted | Check pool configuration, add connection limits |
| `401 Unauthorized` | Token expired or invalid | Implement token refresh logic |
| `403 Forbidden` | Missing permissions | Check user roles and guards |
| `500 Internal Server Error` | Unhandled exception | Add proper error handling and logging |
| `CORS error` | Cross-origin request blocked | Configure CORS in API Gateway and Nest.js |
| `WebSocket connection failed` | Authentication or network issue | Check socket middleware and client configuration |
| `PII processing timeout` | Large document or AWS service limit | Increase timeout, implement chunking |

**Emergency Response Procedures**

**Database Connection Loss**
1. Check RDS instance status in AWS Console
2. Verify security group configuration
3. Check connection pool settings
4. Restart application if needed
5. Monitor CloudWatch metrics

**Authentication Service Down**
1. Check AWS Cognito service status
2. Verify user pool configuration
3. Test with AWS CLI commands
4. Check API Gateway integration
5. Implement graceful degradation

**High Error Rate**
1. Check application logs in CloudWatch
2. Verify database performance metrics
3. Check external service dependencies
4. Review recent deployments
5. Scale resources if needed

### 📊 Decision Trees

#### When to Use Different Caching Strategies
```
Start: Need caching?
├─ Yes: Single instance deployment?
│  ├─ Yes: Use in-memory caching → Cost: $0
│  └─ No: Multiple instances?
│     ├─ Yes: Use Redis → Cost: $200-500/month
│     └─ No: Consider DynamoDB → Cost: Pay per use
└─ No: Direct database access
```

#### Database Query Strategy Selection
```
Start: Need database access?
├─ Simple CRUD: Use typed queries with pgTyped
├─ Complex business logic: Use stored procedures
├─ Reporting/Analytics: Use direct SQL with aggregations
└─ Cross-entity operations: Use transactions with Slonik
```

#### Error Handling Strategy Selection
```
Start: Error occurred?
├─ Client error (4xx): 
│  ├─ Validation: Return detailed field errors
│  ├─ Authentication: Return 401 with refresh instructions
│  └─ Authorization: Return 403 with permission context
├─ Server error (5xx):
│  ├─ Database: Log details, return generic message
│  ├─ External API: Implement retry with backoff
│  └─ Unknown: Log full stack, alert monitoring
└─ Success: Return data with proper status codes
```

#### API Design Pattern Selection
```
Start: Building new API endpoint?
├─ Data retrieval only?
│  ├─ Simple entity: GET /entities/:id
│  ├─ Collection with filters: GET /entities?filter=value
│  ├─ Complex search: POST /entities/search
│  └─ Real-time updates: WebSocket subscription
├─ Data modification?
│  ├─ Create: POST /entities
│  ├─ Full update: PUT /entities/:id
│  ├─ Partial update: PATCH /entities/:id
│  └─ Delete: DELETE /entities/:id
├─ Bulk operations?
│  ├─ Batch create: POST /entities/batch
│  ├─ Batch update: PATCH /entities/batch
│  └─ Batch delete: DELETE /entities/batch
└─ File operations?
   ├─ Upload: POST /entities/:id/documents
   ├─ Download: GET /entities/:id/documents/:docId
   └─ Process: POST /entities/:id/documents/:docId/process
```

#### State Management Strategy Selection
```
Start: Need to manage state?
├─ Server state (API data)?
│  ├─ Use React Query/SWR
│  ├─ Cache with stale-while-revalidate
│  └─ Optimistic updates for mutations
├─ Client state (UI only)?
│  ├─ Component-local: useState/useReducer
│  ├─ Cross-component: Zustand store
│  ├─ Form state: React Hook Form
│  └─ URL state: React Router params/search
├─ Real-time state?
│  ├─ WebSocket connection: Custom hook
│  ├─ Live updates: Socket.io integration
│  └─ Presence: Real-time user status
└─ Persistent state?
   ├─ User preferences: localStorage + Zustand
   ├─ Session data: sessionStorage
   └─ Offline data: IndexedDB + service worker
```

#### Database Schema Design Decisions
```
Start: Designing database schema?
├─ Multi-tenancy approach?
│  ├─ Row-level security (RLS): Include tenant_id in all tables
│  ├─ Schema-per-tenant: Separate schemas (not recommended)
│  └─ Database-per-tenant: Separate databases (complex)
├─ Relationship type?
│  ├─ One-to-many: Foreign key with index
│  ├─ Many-to-many: Junction table with composite index
│  ├─ One-to-one: Foreign key with unique constraint
│  └─ Polymorphic: Use type + id columns
├─ Data type selection?
│  ├─ JSON data: Use JSONB with GIN indexes
│  ├─ Large text: TEXT with full-text search
│  ├─ Money/currency: DECIMAL with precision
│  ├─ Timestamps: TIMESTAMPTZ with timezone
│  └─ UUIDs: UUID type with index
└─ Performance optimization?
   ├─ Add indexes for WHERE clauses
   ├─ Composite indexes for multi-column queries
   ├─ Partial indexes for filtered data
   └─ Consider materialized views for complex queries
```

#### Testing Strategy Decision Tree
```
Start: What to test?
├─ Business logic?
│  ├─ Pure functions: Unit tests (Jest)
│  ├─ Service classes: Unit tests with mocks
│  ├─ Database operations: Integration tests
│  └─ External APIs: Contract tests
├─ UI components?
│  ├─ Isolated components: Unit tests (React Testing Library)
│  ├─ Component interactions: Integration tests
│  ├─ User workflows: E2E tests (Playwright)
│  └─ Visual regression: Screenshot tests
├─ API endpoints?
│  ├─ Success cases: Integration tests
│  ├─ Error cases: Unit tests for error handling
│  ├─ Authentication: Security tests
│  └─ Performance: Load tests
└─ System integration?
   ├─ End-to-end workflows: E2E tests
   ├─ Data consistency: Database tests
   ├─ Security: Penetration tests
   └─ Performance: Stress tests
```

#### Deployment Strategy Selection
```
Start: Ready to deploy?
├─ Environment type?
│  ├─ Development: Local Docker + hot reload
│  ├─ Staging: AWS ECS + real integrations
│  ├─ Production: AWS ECS + monitoring
│  └─ Demo: Lightweight ECS setup
├─ Scaling requirements?
│  ├─ Low traffic (<1K users): Single ECS task
│  ├─ Medium traffic (1K-10K): Auto-scaling ECS
│  ├─ High traffic (10K+): ECS + Redis + CDN
│  └─ Enterprise: EKS + advanced monitoring
├─ Database deployment?
│  ├─ Development: Local PostgreSQL
│  ├─ Staging: RDS PostgreSQL
│  ├─ Production: Aurora PostgreSQL
│  └─ High availability: Aurora Multi-AZ
└─ Monitoring needs?
   ├─ Basic: CloudWatch + health checks
   ├─ Advanced: CloudWatch + Sentry + custom metrics
   ├─ Enterprise: Full observability stack
   └─ Compliance: SOC 2 monitoring + Vanta
```

---

## 📋 PRD Requirements Traceability Matrix

This section maps Product Requirements Document (PRD) requirements to specific architectural implementations, ensuring complete coverage and traceability.

### Core Business Requirements Implementation

#### Forward Family Circles (FFCs) - PRD Section 3.3
**Requirement**: "Complete FFC onboarding flow with unlimited member invitations"

**Architecture Implementation**:
- **Database Schema**: Multi-tenant `forward_family_circles` table → [Database Schema](#database-schema)
- **Authentication**: AWS Cognito user pools with role-based access → [Authentication Architecture](#authentication-architecture-aws-cognito--api-gateway)
- **Invitation System**: Dual-channel verification (email + SMS) → [External APIs](#external-apis)
- **Member Management**: Unlimited seats with Free Plan → [Subscription & Payment Entities](#subscription--payment-entities)

**Code Location**: `src/modules/ffc/` in backend, `src/features/ffc/` in frontend

---

#### Asset Management (14 Categories) - PRD Section 3.3
**Requirement**: "All 14 asset categories implemented from Day 1 with individual ownership rights"

**Architecture Implementation**:
- **Asset Categories**: Complete type system for all 14 categories → [Data Models](#data-models)
- **Ownership Model**: Asset-persona direct ownership links → [Complete Example: RealEstateAsset](#complete-example-realestateasset)
- **Permissions**: Granular asset-level permissions independent of FFC ownership → [Authentication and Authorization Guards](#authentication-and-authorization-guards)
- **Database Design**: Polymorphic asset tables with category-specific schemas → [Database Schema](#database-schema)

**Code Location**: `src/modules/assets/` in backend, `src/features/assets/` in frontend

---

#### PII Protection & Document Processing - PRD Section 3.3 & Epic 3
**Requirement**: "AWS Step Functions orchestrates serverless pipeline using S3, Lambda, and Comprehend for PII detection and masking"

**Architecture Implementation**:
- **Workflow Orchestration**: AWS Step Functions state machine → [AWS Step Functions Document Processing](#aws-step-functions-document-processing)
- **PII Detection**: AWS Comprehend integration with confidence scoring → [AWS Services (Native Integration)](#aws-services-native-integration)
- **Dual Storage**: Original encrypted + masked versions → [Document Processing Pipeline](#document-processing-pipeline-overview)
- **Security**: KMS encryption and access controls → [Security Requirements](#security-requirements)

**Code Location**: `infrastructure/step-functions/` and `src/modules/documents/`

---

#### Subscription & Payment System - PRD Section 2.3
**Requirement**: "Free Unlimited Plan as default, one-time services, dynamic plan configuration"

**Architecture Implementation**:
- **Plan Management**: Database-driven plan configuration → [Subscription & Payment Entities](#subscription--payment-entities)
- **Payment Processing**: Stripe integration with webhook handling → [Queue Processing with AWS SQS](#queue-processing-with-aws-sqs)
- **Dynamic UI**: Plan-based feature visibility → [State Management Architecture](#state-management-architecture)
- **Zero Payment Barrier**: Automatic free plan assignment → [Progressive Caching Strategy](#progressive-caching-strategy-cost-optimized)

**Code Location**: `src/modules/subscriptions/` and `src/modules/payments/`

---

### Technical Requirements Implementation

#### Type-Safe Database Operations - PRD Section 5 & ADR-002
**Requirement**: "Type-safe database architecture with pgTyped and Slonik (84% of stored procedures converted)"

**Architecture Implementation**:
- **Compile-time Safety**: pgTyped generates TypeScript types from SQL → [Database Access Architecture](#database-access-architecture-pgtyped--slonik)
- **Runtime Safety**: Slonik with parameterized queries → [Slonik Runtime Client](#slonik-runtime-client)
- **Query Organization**: 99 SQL files + 10 procedure wrappers → [SQL Query Organization](#sql-query-organization)
- **Multi-tenant Isolation**: RLS context in every query → [Multi-Tenant Security Context](#multi-tenant-security-context)

**Code Location**: `docs/requirements/DB/sql scripts/5_SQL_files/` and `src/database/`

---

#### Marketing Independence - PRD Section 3.2 & Epic 1
**Requirement**: "Builder.io CMS integration for marketing team independence"

**Architecture Implementation**:
- **CMS Integration**: Headless Builder.io for landing pages → [High Level Architecture Diagram](#high-level-architecture-diagram)
- **CDN Delivery**: CloudFront distribution → [Platform and Infrastructure Choice](#platform-and-infrastructure-choice)
- **A/B Testing**: Built-in Builder.io capabilities → [Tech Stack](#tech-stack)
- **SEO Optimization**: Server-side rendering considerations → [SEO Optimization for Public Pages](#seo-optimization-for-public-pages)

**Code Location**: Marketing pages in Builder.io, integration in `apps/web/src/pages/marketing/`

---

#### Multi-Language Support - PRD Epic 5
**Requirement**: "Native Spanish support with expansion roadmap for underserved US communities"

**Architecture Implementation**:
- **Translation System**: Simple English/Spanish implementation → [Translation System](#translation-system-simple-englishspanish)
- **User Preferences**: Language selection storage → [Data Models](#data-models)
- **Content Management**: Localized email templates → [SendGrid API](#sendgrid-api)
- **Cultural Adaptations**: Hispanic family structure considerations → [Internationalization Strategy](#internationalization-i18n-strategy)

**Code Location**: `src/i18n/` and `apps/web/src/locales/`

---

### Security & Compliance Requirements

#### SOC 2 Compliance - PRD Epic 6
**Requirement**: "SOC 2 Type II certification with Vanta integration for automated compliance"

**Architecture Implementation**:
- **Compliance Automation**: Vanta API integration → [Vanta Integration for SOC 2 Compliance](#vanta-integration-for-soc-2-compliance)
- **Evidence Collection**: Automated audit trail generation → [Monitoring and Observability](#monitoring-and-observability)
- **Security Controls**: Comprehensive monitoring and alerting → [Security Monitoring](#security-monitoring)
- **Access Controls**: Role-based permissions with audit logging → [Authentication and Authorization Guards](#authentication-and-authorization-guards)

**Code Location**: `src/modules/compliance/` and `infrastructure/monitoring/`

---

#### Enhanced Security - PRD Section 3.1
**Requirement**: "Mandatory dual-channel verification (email + SMS) with owner approval"

**Architecture Implementation**:
- **Dual Verification**: Email + SMS verification flow → [Twilio API](#twilio-api) + [SendGrid API](#sendgrid-api)
- **Owner Approval**: Workflow with notification system → [Real-Time WebSocket Layer](#real-time-websocket-layer-with-socketio)
- **Session Management**: Secure httpOnly cookies → [Security Best Practices](#security-best-practices)
- **Token Security**: JWT validation with short lifetimes → [Authentication Flow](#authentication-flow)

**Code Location**: `src/modules/verification/` and `src/modules/invitations/`

---

### Performance & Scale Requirements

#### Performance Targets - PRD Section 5.4
**Requirement**: "API response times p50 < 100ms, p95 < 200ms, support 10,000 concurrent users"

**Architecture Implementation**:
- **Caching Strategy**: Progressive caching (in-memory → Redis) → [Progressive Caching Strategy](#progressive-caching-strategy-cost-optimized)
- **Database Optimization**: Indexed queries and connection pooling → [Database Architecture with Nest.js](#database-architecture-with-nestjs)
- **API Gateway**: Rate limiting and throttling → [API Gateway Pattern Implementation](#api-gateway-pattern-implementation)
- **Monitoring**: Real-time performance metrics → [Key Metrics](#key-metrics)

**Code Location**: `src/interceptors/caching/` and `infrastructure/monitoring/`

---

#### Cost Optimization - PRD Section 4.3
**Requirement**: "Progressive infrastructure scaling with cost-effective MVP approach"

**Architecture Implementation**:
- **Scaling Strategy**: Phase-based infrastructure growth → [Cost Optimization Strategy](#cost-optimization-strategy)
- **Smart Caching**: In-memory first to minimize AWS costs → [Progressive Infrastructure Scaling](#progressive-infrastructure-scaling)
- **Serverless Components**: Step Functions and Lambda for variable loads → [AWS Step Functions Document Processing](#aws-step-functions-document-processing)
- **Resource Monitoring**: Cost tracking and alerts → [Break-Even Analysis](#break-even-analysis)

**Code Location**: `infrastructure/` and cost monitoring in CloudWatch

---

### Feature Coverage Matrix

| PRD Epic | Architecture Section | Implementation Status | Code Location |
|----------|---------------------|----------------------|---------------|
| Epic 1: Marketing Foundation | [High Level Architecture Diagram](#high-level-architecture-diagram) | ✅ Specified | Marketing pages + CDN |
| Epic 2: FFC Onboarding | [Authentication Architecture](#authentication-architecture-aws-cognito--api-gateway) | ✅ Specified | `src/modules/ffc/` |
| Epic 3: Asset Management | [Persona-Based Ownership Model](#persona-based-ownership-model) | ✅ Specified | `src/modules/assets/` |
| Epic 4: Advanced Features | [Message Queue Architecture](#message-queue-architecture-aws-sqs) | ✅ Specified | `src/modules/integrations/` |
| Epic 5: Multi-Language | [Translation System](#translation-system-simple-englishspanish) | ✅ Specified | `src/i18n/` |
| Epic 6: SOC 2 Compliance | [Vanta API](#vanta-api) | ✅ Specified | `src/modules/compliance/` |
| Epic 7: Performance Optimization | [Epic 7: Performance Optimization & Advanced Caching](#epic-7-performance-optimization--advanced-caching) | ✅ Specified | Performance optimization |

---

## 🌍 Additional Considerations

### Internationalization (i18n) Strategy

#### Language Support
Based on the PRD requirements, the platform will support:
- **Phase 1**: English (default), Spanish
- **Phase 2**: Chinese (Simplified), Korean
- **Future**: Additional languages based on market demand

#### Implementation Approach

**Frontend i18n with react-i18next**
```typescript
/**
 * i18n configuration
 */
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: enTranslations },
      es: { translation: esTranslations },
      'zh-CN': { translation: zhTranslations },
      ko: { translation: koTranslations },
    },
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false, // React already escapes
    },
    detection: {
      order: ['localStorage', 'navigator', 'htmlTag'],
      caches: ['localStorage'],
    },
  });

// Usage in components
import { useTranslation } from 'react-i18next';

function AssetCard() {
  const { t, i18n } = useTranslation();
  
  return (
    <Card>
      <h2>{t('assets.title')}</h2>
      <p>{t('assets.value', { value: formatCurrency(asset.value, i18n.language) })}</p>
    </Card>
  );
}
```

**Backend i18n Strategy**
```typescript
/**
 * Database-driven translations for dynamic content
 */
// Using the translations table already in schema
interface TranslationService {
  async getTranslation(key: string, language: string): Promise<string> {
    const result = await db.func('sp_get_translations', ['text', key, language]);
    return result[0]?.translated_text || key;
  }
  
  async bulkTranslate(keys: string[], language: string): Promise<Record<string, string>> {
    // sp_get_translations can handle multiple lookups
    const results = await db.func('sp_get_translations', ['text', null, language]);
    return results.reduce((acc, row) => {
      acc[row.translation_key] = row.translated_text;
      return acc;
    }, {});
  }
}

// Middleware for API responses
export function i18nMiddleware(req: Request, res: Response, next: NextFunction) {
  const lang = req.headers['accept-language']?.split(',')[0] || 'en';
  req.language = lang;
  res.locals.t = (key: string) => translationService.getTranslation(key, lang);
  next();
}
```

### Accessibility (a11y) Requirements

#### WCAG 2.1 Level AA Compliance

**Component Accessibility Standards**
```typescript
/**
 * Accessible component example
 */
function AccessibleButton({ 
  onClick, 
  children, 
  ariaLabel,
  disabled = false,
  loading = false 
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled || loading}
      aria-label={ariaLabel || children}
      aria-busy={loading}
      aria-disabled={disabled}
      role="button"
      tabIndex={disabled ? -1 : 0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onClick?.(e);
        }
      }}
    >
      {loading && <span className="sr-only">Loading...</span>}
      {children}
    </button>
  );
}
```

**Accessibility Testing**
```typescript
/**
 * Automated accessibility testing
 */
// jest-axe for unit tests
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('should not have accessibility violations', async () => {
  const { container } = render(<AssetCard asset={mockAsset} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});

// Playwright for E2E accessibility testing
test('page should be accessible', async ({ page }) => {
  await page.goto('/dashboard');
  const accessibilitySnapshot = await page.accessibility.snapshot();
  expect(accessibilitySnapshot).toMatchSnapshot();
});
```

**Key Accessibility Features**
- Keyboard navigation for all interactive elements
- Screen reader announcements for dynamic content
- High contrast mode support
- Focus management for modals and overlays
- Skip navigation links
- Proper heading hierarchy
- Alt text for all images
- ARIA labels and descriptions
- Form field validation announcements
- Loading and error state announcements

### SEO Optimization for Public Pages

**Next.js SEO Configuration**
```typescript
/**
 * SEO metadata configuration
 */
import { NextSeo } from 'next-seo';

const SEOConfig = {
  defaultTitle: 'Forward Inheritance - Secure Family Wealth Management',
  titleTemplate: '%s | Forward Inheritance',
  description: 'Secure platform for managing family inheritance and wealth transfer',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://forward-inheritance.com',
    site_name: 'Forward Inheritance',
    images: [
      {
        url: 'https://forward-inheritance.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Forward Inheritance Platform',
      },
    ],
  },
  twitter: {
    handle: '@fwdinheritance',
    site: '@fwdinheritance',
    cardType: 'summary_large_image',
  },
};

// Structured data for rich snippets
const structuredData = {
  '@context': 'https://schema.org',
  '@type': 'FinancialService',
  name: 'Forward Inheritance',
  description: 'Family wealth management and inheritance planning platform',
  url: 'https://forward-inheritance.com',
  areaServed: 'US',
  serviceType: 'Estate Planning',
};
```

### Analytics and Tracking Implementation

**Google Analytics 4 + Custom Events**
```typescript
/**
 * Analytics service with privacy-first approach
 */
class AnalyticsService {
  initialize() {
    // Only track with user consent
    if (this.hasConsent()) {
      gtag('config', process.env.NEXT_PUBLIC_GA_ID, {
        anonymize_ip: true,
        cookie_flags: 'SameSite=Strict;Secure',
      });
    }
  }
  
  trackEvent(action: string, category: string, label?: string, value?: number) {
    if (!this.hasConsent()) return;
    
    gtag('event', action, {
      event_category: category,
      event_label: label,
      value: value,
      custom_dimensions: {
        user_type: getUserType(),
        ffc_count: getFFCCount(),
      },
    });
  }
  
  trackConversion(type: 'signup' | 'ffc_created' | 'asset_added', value?: number) {
    this.trackEvent(`conversion_${type}`, 'Conversion', type, value);
    
    // Also send to backend for business metrics
    metricsAPI.trackConversion(type, value);
  }
  
  private hasConsent(): boolean {
    return localStorage.getItem('analytics_consent') === 'true';
  }
}
```

### Backup and Disaster Recovery

**Backup Strategy**
```yaml
Database Backups:
  Type: Automated snapshots
  Frequency: 
    - Full: Daily at 2 AM UTC
    - Incremental: Every 6 hours
  Retention:
    - Daily: 7 days
    - Weekly: 4 weeks
    - Monthly: 12 months
  Location:
    - Primary: Same region
    - Cross-region: US-West-2 (if primary is US-East-1)
  Encryption: AES-256 with AWS KMS

File Storage Backups:
  S3 Versioning: Enabled
  Cross-Region Replication: Enabled
  Lifecycle Policy:
    - Current version: Retain indefinitely
    - Previous versions: 
      - Transition to IA after 30 days
      - Transition to Glacier after 90 days
      - Delete after 7 years

Application State:
  Infrastructure as Code: Pulumi
  Container Images: ECR with immutable tags
  Configuration: AWS Systems Manager Parameter Store
```

**Disaster Recovery Plan**
```typescript
/**
 * Recovery Time Objective (RTO): 4 hours
 * Recovery Point Objective (RPO): 1 hour
 */
const disasterRecoveryPlan = {
  scenarios: {
    'aws-region-failure': {
      detection: 'CloudWatch Synthetics + Route53 Health Checks',
      response: 'Automatic failover to secondary region',
      rto: '15 minutes',
      rpo: '5 minutes',
    },
    'database-corruption': {
      detection: 'Data integrity checks',
      response: 'Restore from latest snapshot',
      rto: '2 hours',
      rpo: '6 hours',
    },
    'application-failure': {
      detection: 'ECS health checks',
      response: 'Auto-rollback to previous version',
      rto: '5 minutes',
      rpo: '0 minutes',
    },
    'security-breach': {
      detection: 'GuardDuty + Security Hub',
      response: 'Isolate affected resources, restore from clean backup',
      rto: '4 hours',
      rpo: '1 hour',
    },
  },
};
```

### Data Retention Policies

```typescript
/**
 * Data retention configuration
 */
const dataRetentionPolicies = {
  // User data
  active_users: 'Indefinite',
  inactive_users: '7 years after last activity',
  deleted_accounts: '30 days (soft delete) then permanent',
  
  // Asset data
  asset_records: 'Indefinite while FFC active',
  asset_history: '7 years',
  deleted_assets: '7 years (archived)',
  
  // Documents
  legal_documents: 'Indefinite',
  financial_statements: '7 years',
  uploaded_files: 'As per retention_policy field',
  
  // Audit logs
  security_logs: '7 years',
  access_logs: '1 year',
  change_logs: '7 years',
  
  // Communications
  invitations: '90 days after expiration',
  notifications: '1 year',
  
  // Backups
  database_backups: 'See backup strategy',
  file_backups: 'See backup strategy',
};

// Implementation
class DataRetentionService {
  @Scheduled('0 0 * * *') // Daily at midnight
  async enforceRetention() {
    await this.archiveInactiveUsers();
    await this.purgeExpiredData();
    await this.compressOldLogs();
    await this.moveToArchivalStorage();
  }
}
```

### GDPR/CCPA Compliance Measures

**Privacy Rights Implementation**
```typescript
/**
 * Privacy rights service
 */
class PrivacyService {
  // Right to Access (GDPR Article 15, CCPA)
  async exportUserData(userId: string): Promise<UserDataExport> {
    // Note: Data export not implemented as stored procedure
    // Implement using direct queries with proper joins
    const personalInfo = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
    const assets = await db.query('SELECT * FROM assets WHERE owner_user_id = $1', [userId]);
    const auditLogs = await db.func('sp_get_audit_trail', [null, 'user', userId, null, null]);
    
    return {
      personal_info: personalInfo.rows,
      assets: assets.rows,
      documents: [], // Fetch from document storage
      audit_logs: auditLogs,
      format: 'json',
      generated_at: new Date(),
    };
  }
  
  // Right to Erasure (GDPR Article 17)
  async deleteUserData(userId: string, confirmation: string): Promise<void> {
    if (confirmation !== 'DELETE') {
      throw new Error('Invalid confirmation');
    }
    
    // Soft delete not implemented as stored procedure
    // Implement soft delete in application layer
    await db.query('UPDATE users SET deleted_at = NOW() WHERE id = $1', [userId]);
    
    // Schedule hard delete after retention period
    await scheduleJob('hard_delete', { userId }, '30 days');
    
    // Log for compliance
    await auditLog.record({
      action: 'USER_DATA_DELETION_REQUESTED',
      userId,
      timestamp: new Date(),
    });
  }
  
  // Right to Rectification (GDPR Article 16)
  async updateUserData(userId: string, updates: Partial<UserData>): Promise<void> {
    await db.func('sp_update_user_profile', [userId, updates.first_name, updates.last_name, updates.display_name, updates.profile_picture_url, updates.preferred_language, updates.timezone]);
    await auditLog.record({
      action: 'USER_DATA_UPDATED',
      userId,
      changes: updates,
    });
  }
  
  // Right to Data Portability (GDPR Article 20)
  async exportPortableData(userId: string): Promise<Buffer> {
    const data = await this.exportUserData(userId);
    return Buffer.from(JSON.stringify(data, null, 2));
  }
  
  // Consent Management
  async updateConsent(userId: string, consents: ConsentUpdate): Promise<void> {
    // Note: Consent management not implemented as stored procedure
    // Store consent in application layer or add to user preferences
    await db.query(
      'UPDATE users SET consent_preferences = $2 WHERE id = $1',
      [userId, JSON.stringify(consents)]
    );
  }
}
```

**Cookie Consent Banner**
```typescript
/**
 * Cookie consent component
 */
function CookieConsent() {
  const [show, setShow] = useState(false);
  
  useEffect(() => {
    const consent = localStorage.getItem('cookie_consent');
    if (!consent) {
      setShow(true);
    }
  }, []);
  
  const handleAccept = (level: 'essential' | 'analytics' | 'all') => {
    const consent = {
      essential: true,
      analytics: level === 'analytics' || level === 'all',
      marketing: level === 'all',
      timestamp: new Date().toISOString(),
    };
    
    localStorage.setItem('cookie_consent', JSON.stringify(consent));
    
    // Initialize services based on consent
    if (consent.analytics) {
      analytics.initialize();
    }
    
    setShow(false);
  };
  
  if (!show) return null;
  
  return (
    <div className="cookie-banner">
      <p>We use cookies to improve your experience.</p>
      <button onClick={() => handleAccept('essential')}>Essential Only</button>
      <button onClick={() => handleAccept('analytics')}>Accept Analytics</button>
      <button onClick={() => handleAccept('all')}>Accept All</button>
      <Link href="/privacy">Privacy Policy</Link>
    </div>
  );
}
```

### Vanta Integration for SOC 2 Compliance

**API Documentation:** See `/docs/requirements/API/Vanta/vanta-api-documentation.md` for complete API reference.

**Automated Compliance Monitoring**
```typescript
/**
 * Vanta integration for SOC 2 automation
 * Full API documentation: /docs/requirements/API/Vanta/vanta-api-documentation.md
 */
class VantaIntegration {
  private vantaClient: VantaClient;
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;
  
  constructor() {
    // OAuth 2.0 authentication as per Vanta API docs
    this.vantaClient = new VantaClient({
      clientId: process.env.VANTA_CLIENT_ID,
      clientSecret: process.env.VANTA_CLIENT_SECRET,
      baseUrl: 'https://api.vanta.com',
    });
  }
  
  /**
   * Authenticate using OAuth 2.0 Client Credentials flow
   * Token expires after 1 hour (3599 seconds)
   */
  private async authenticate(): Promise<void> {
    if (this.accessToken && this.tokenExpiry && this.tokenExpiry > new Date()) {
      return; // Token still valid
    }
    
    const response = await axios.post('https://api.vanta.com/oauth/token', {
      client_id: process.env.VANTA_CLIENT_ID,
      client_secret: process.env.VANTA_CLIENT_SECRET,
      scope: 'vanta-api.all:read vanta-api.all:write',
      grant_type: 'client_credentials'
    });
    
    this.accessToken = response.data.access_token;
    this.tokenExpiry = new Date(Date.now() + (response.data.expires_in * 1000));
  }
  
  // Employee device monitoring
  async syncEmployeeDevices() {
    const devices = await this.getEmployeeDevices();
    await this.vantaClient.updateDevices(devices);
  }
  
  // Security controls evidence
  async reportSecurityControls() {
    const controls = {
      mfa_enabled: await this.checkMFACompliance(),
      encryption_at_rest: true, // AWS RDS encryption
      encryption_in_transit: true, // TLS 1.3
      access_logging: await this.checkAuditLogging(),
      vulnerability_scanning: await this.getLastScanDate(),
      incident_response: await this.getIncidentMetrics(),
      backup_testing: await this.getLastBackupTest(),
      access_reviews: await this.getLastAccessReview(),
    };
    
    await this.vantaClient.updateControls(controls);
  }
  
  // Vendor management
  async syncVendors() {
    const vendors = [
      { name: 'AWS', critical: true, reviewed: true },
      { name: 'Twilio', critical: true, reviewed: true },
      { name: 'SendGrid', critical: false, reviewed: true },
      { name: 'Quiltt', critical: false, reviewed: true },
    ];
    
    await this.vantaClient.updateVendors(vendors);
  }
  
  // Schedule daily sync
  @Scheduled('0 0 * * *')
  async dailyComplianceSync() {
    await this.syncEmployeeDevices();
    await this.reportSecurityControls();
    await this.syncVendors();
    
    logger.info('Vanta compliance sync completed', {
      timestamp: new Date(),
      status: 'success',
    });
  }
}
```

**SOC 2 Control Mappings**
```yaml
SOC2_Controls:
  CC1_Control_Environment:
    - Employee background checks
    - Security awareness training
    - Code of conduct acknowledgment
    
  CC2_Communication_and_Information:
    - Security policies documented
    - Incident response procedures
    - Customer communication channels
    
  CC3_Risk_Assessment:
    - Annual risk assessment
    - Vendor risk management
    - Threat modeling
    
  CC4_Monitoring:
    - Continuous monitoring (CloudWatch)
    - Security scanning (AWS Inspector)
    - Log aggregation and analysis
    
  CC5_Control_Activities:
    - Change management process
    - Code review requirements
    - Deployment approvals
    
  CC6_Logical_Access:
    - MFA enforcement
    - Role-based access control
    - Regular access reviews
    - Password policies
    
  CC7_System_Operations:
    - Vulnerability management
    - Patch management
    - Capacity monitoring
    - Incident detection
    
  CC8_Change_Management:
    - Development lifecycle
    - Testing procedures
    - Deployment controls
    - Rollback procedures
    
  CC9_Risk_Mitigation:
    - Business continuity plan
    - Disaster recovery testing
    - Data backup procedures
    - Insurance coverage
```

## Microservices Architecture (Future Decomposition)

### Overview
While the Forward Inheritance Platform currently operates as a modular monolith using Nest.js, the architecture is designed to support future decomposition into microservices as the platform scales. This section outlines the service boundaries and migration strategy for when business requirements justify the additional operational complexity.

### Service Boundaries

#### Core Services

**1. Identity & Access Service**
```yaml
Responsibilities:
  - User authentication (AWS Cognito integration)
  - User registration and profile management
  - Session management
  - MFA configuration
  - Password reset flows

Database Tables:
  - users (synchronized from Cognito)
  - user_profiles (additional app-specific data)
  # Note: Authentication state managed by Cognito, not database
  # No session, MFA, or password tables needed

API Gateway Routes:
  - /auth/*
  - /users/profile
  - /sessions/*

Event Types:
  - UserRegistered
  - UserAuthenticated
  - SessionCreated
  - MFAEnabled
  - PasswordReset
```

**2. Family Circle Service**
```yaml
Responsibilities:
  - FFC creation and management
  - Persona management
  - Family member invitations
  - Role assignments within FFCs

Database Tables:
  - fwd_family_circles
  - personas
  - ffc_personas
  - ffc_invitations
  - invitation_verification_attempts

API Gateway Routes:
  - /ffc/*
  - /personas/*
  - /invitations/*

Event Types:
  - FFCCreated
  - PersonaAdded
  - MemberInvited
  - RoleChanged
  - MemberRemoved
```

**3. Asset Management Service**
```yaml
Responsibilities:
  - Asset CRUD operations
  - Asset categorization
  - Asset valuation tracking
  - Asset-persona relationships
  - Asset permissions

Database Tables:
  - assets
  - asset_categories
  - asset_persona
  - asset_permissions
  - asset_valuation_history

API Gateway Routes:
  - /assets/*
  - /categories/*
  - /valuations/*

Event Types:
  - AssetCreated
  - AssetUpdated
  - AssetDeleted
  - OwnershipTransferred
  - ValuationUpdated
```

**4. Document Processing Service**
```yaml
Responsibilities:
  - Document upload and storage
  - PII detection and masking
  - Document metadata extraction
  - OCR processing
  - Document search

Database Tables:
  - media_storage
  - document_metadata
  - pii_detection_rules
  - pii_processing_jobs
  - pii_access_logs

API Gateway Routes:
  - /documents/*
  - /upload/*
  - /search/documents

AWS Services:
  - S3 for storage
  - Step Functions for orchestration
  - Comprehend for PII detection
  - Textract for OCR

Event Types:
  - DocumentUploaded
  - PIIDetected
  - DocumentProcessed
  - DocumentAccessed
```

#### Domain-Specific Services

**5. Financial Assets Service**
```yaml
Responsibilities:
  - Bank account management
  - Investment portfolio tracking
  - Retirement account management
  - Financial account synchronization

Database Tables:
  - financial_accounts
  - bank_accounts
  - investment_accounts
  - retirement_accounts

API Gateway Routes:
  - /financial/*
  - /accounts/bank/*
  - /accounts/investment/*

External Integrations:
  - Quiltt for account aggregation
  - Plaid as backup provider

Event Types:
  - AccountLinked
  - BalanceUpdated
  - TransactionImported
```

**6. Real Estate Service**
```yaml
Responsibilities:
  - Property management
  - Valuation tracking
  - Tax assessment integration
  - Market data synchronization

Database Tables:
  - real_estate
  - property_valuations
  - real_estate_sync_logs
  - real_estate_provider_integrations

API Gateway Routes:
  - /real-estate/*
  - /properties/*
  - /valuations/real-estate/*

External Integrations:
  - Zillow API
  - County assessor APIs
  - MLS data feeds

Event Types:
  - PropertyAdded
  - ValuationUpdated
  - TaxAssessmentReceived
```

**7. Insurance Service**
```yaml
Responsibilities:
  - Life insurance policy management
  - Policy beneficiary tracking
  - Premium payment reminders
  - Policy document storage

Database Tables:
  - life_insurance
  - insurance_beneficiaries
  - premium_payments

API Gateway Routes:
  - /insurance/*
  - /policies/*
  - /beneficiaries/*

Event Types:
  - PolicyAdded
  - BeneficiaryUpdated
  - PremiumDue
  - PolicyMatured
```

#### Supporting Services

**8. Notification Service**
```yaml
Responsibilities:
  - Email notifications
  - SMS notifications
  - In-app notifications
  - Notification preferences
  - Template management

Database Tables:
  - notification_templates
  - notification_logs
  - user_notification_preferences

API Gateway Routes:
  - /notifications/*
  - /preferences/notifications

AWS Services:
  - SES for email
  - SNS for SMS
  - Pinpoint for campaigns

Event Types:
  - NotificationSent
  - NotificationFailed
  - PreferencesUpdated
```

**9. Audit & Compliance Service**
```yaml
Responsibilities:
  - Audit log management
  - Compliance reporting
  - Event sourcing management
  - Data retention policies

Database Tables:
  - audit_log
  - audit_events
  - event_store
  - event_snapshots
  - event_projections

API Gateway Routes:
  - /audit/*
  - /compliance/*
  - /reports/audit

Event Types:
  - AuditEventLogged
  - ComplianceReportGenerated
  - RetentionPolicyApplied
```

**10. Integration Hub Service**
```yaml
Responsibilities:
  - Third-party API management
  - Webhook processing
  - Data synchronization
  - API credential management

Database Tables:
  - integration_credentials
  - quiltt_integrations
  - quiltt_webhook_logs
  - builder_io_integrations
  - advisor_companies

API Gateway Routes:
  - /integrations/*
  - /webhooks/*
  - /sync/*

Event Types:
  - IntegrationConfigured
  - WebhookReceived
  - SyncCompleted
  - IntegrationFailed
```

### Inter-Service Communication

#### Synchronous Communication
```typescript
// API Gateway pattern for service-to-service calls
interface ServiceClient {
  baseUrl: string;
  timeout: number;
  retryPolicy: RetryPolicy;
  circuitBreaker: CircuitBreakerConfig;
}

// Example: Asset Service calling Identity Service
class AssetService {
  async validateUserPermission(userId: string, assetId: string) {
    return await this.identityClient.get(`/users/${userId}/permissions`, {
      params: { resource: `asset:${assetId}` }
    });
  }
}
```

#### Asynchronous Communication
```typescript
// Event-driven architecture using AWS EventBridge
interface DomainEvent {
  eventId: string;
  eventType: string;
  aggregateId: string;
  aggregateType: string;
  timestamp: Date;
  payload: any;
  metadata: EventMetadata;
}

// Example: Publishing asset creation event
class AssetEventPublisher {
  async publishAssetCreated(asset: Asset) {
    await this.eventBridge.putEvents({
      Entries: [{
        Source: 'asset.service',
        DetailType: 'AssetCreated',
        Detail: JSON.stringify({
          assetId: asset.id,
          categoryId: asset.categoryId,
          ownerId: asset.ownerId,
          value: asset.currentValue
        })
      }]
    });
  }
}
```

### Data Management Strategy

#### Database per Service
```yaml
Asset Service DB:
  - Primary: PostgreSQL (write model)
  - Read replicas: 2 instances
  - Cache: Service-specific in-memory cache (DynamoDB/Upstash when scaled)
  
Document Service DB:
  - Primary: PostgreSQL (metadata)
  - Object storage: S3 (documents)
  - Search: OpenSearch (full-text)
  
Financial Service DB:
  - Primary: PostgreSQL (accounts)
  - Time-series: TimescaleDB (transactions)
  - Cache: In-memory (balances), DynamoDB/Upstash for scale
```

#### Data Consistency Patterns
```typescript
// Saga pattern for distributed transactions
class AssetTransferSaga {
  steps = [
    { service: 'asset', action: 'lockAsset' },
    { service: 'identity', action: 'validatePermission' },
    { service: 'asset', action: 'transferOwnership' },
    { service: 'audit', action: 'logTransfer' },
    { service: 'notification', action: 'notifyParties' }
  ];
  
  compensations = [
    { service: 'asset', action: 'unlockAsset' },
    { service: 'asset', action: 'revertOwnership' },
    { service: 'audit', action: 'logReversal' }
  ];
}
```

### Migration Strategy

#### Phase 1: Modular Monolith (Current)
- All modules within single Nest.js application
- Shared database with schema separation
- In-memory caching for MVP
- Single deployment unit

#### Phase 2: Service Extraction Preparation
```yaml
Timeline: 6-12 months after launch
Triggers:
  - User base > 10,000 active families
  - API calls > 1M per day
  - Team size > 15 developers

Actions:
  - Implement event sourcing fully
  - Add distributed tracing (OpenTelemetry)
  - Create service interfaces
  - Implement API Gateway
  - Add message queue (SQS/EventBridge)
```

#### Phase 3: Gradual Service Extraction
```yaml
Timeline: 12-18 months
Extraction Order:
  1. Notification Service (low coupling)
  2. Document Processing Service (CPU intensive)
  3. Integration Hub Service (external dependencies)
  4. Audit & Compliance Service (independent)
  5. Financial Assets Service (domain boundary)
  
Per-Service Migration:
  - Create service repository
  - Extract database schema
  - Implement service API
  - Add event publishing
  - Deploy alongside monolith
  - Gradual traffic migration
  - Decommission monolith module
```

#### Phase 4: Full Microservices
```yaml
Timeline: 18-24 months
Infrastructure:
  - Kubernetes orchestration (EKS)
  - Service mesh (Istio/AppMesh)
  - Distributed caching (DynamoDB or Upstash Redis)
  - Message streaming (Kinesis)
  - API Gateway (Kong/AWS API Gateway)
  
Operational Requirements:
  - Centralized logging (ELK)
  - Distributed tracing (Jaeger)
  - Service monitoring (Prometheus/Grafana)
  - Chaos engineering (Gremlin)
  - CI/CD per service (GitHub Actions)
```

### Service Governance

#### API Versioning Strategy
```yaml
Versioning Pattern: URL path versioning
Example: /api/v1/assets, /api/v2/assets

Deprecation Policy:
  - Minimum 6 months notice
  - Dual version support period
  - Migration guides provided
  - Automated migration tools

Backward Compatibility:
  - New fields optional
  - Enum values append-only
  - Response structure stable
  - Error codes immutable
```

#### Service Level Objectives (SLOs)
```yaml
Tier 1 Services (Identity, Asset, FFC):
  - Availability: 99.95%
  - Latency P99: < 200ms
  - Error rate: < 0.1%

Tier 2 Services (Financial, Real Estate):
  - Availability: 99.9%
  - Latency P99: < 500ms
  - Error rate: < 0.5%

Tier 3 Services (Notification, Integration):
  - Availability: 99.5%
  - Latency P99: < 1000ms
  - Error rate: < 1%
```

### Cost Optimization

#### Resource Allocation
```yaml
Development Environment:
  - Shared Kubernetes namespace
  - Minimal replicas (1 per service)
  - Spot instances for workers
  - Shared RDS instance

Staging Environment:
  - Dedicated namespace
  - Auto-scaling enabled
  - Mixed instance types
  - Read replicas enabled

Production Environment:
  - Multi-AZ deployment
  - Reserved instances (70%)
  - Spot instances (30% for batch)
  - Auto-scaling with predictive
```

#### Cost Monitoring
```typescript
// Service cost attribution
interface ServiceCost {
  serviceId: string;
  period: string;
  compute: number;     // EC2/Fargate costs
  storage: number;     // RDS/S3 costs
  network: number;     // Data transfer costs
  external: number;    // Third-party API costs
  total: number;
}

// Cost allocation tags
const costTags = {
  'Service': 'asset-service',
  'Environment': 'production',
  'Team': 'platform',
  'CostCenter': 'engineering'
};
```

---

**Document Status:** Complete  
**Last Updated:** 2025-01-06  
**Version:** 1.0  
**Authors:** Forward Inheritance Development Team