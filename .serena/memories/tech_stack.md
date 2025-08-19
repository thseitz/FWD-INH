# Technology Stack

## Frontend
- **Language**: TypeScript 5.3+
- **Framework**: React 18.2+
- **Routing**: React Router 6.20+
- **UI Components**: shadcn/ui + Radix UI (latest)
- **State Management**: Zustand 4.4+
- **Styling**: Tailwind CSS 3.4+
- **Build Tool**: Vite 5.0+
- **Testing**: Vitest 1.1+, React Testing Library 14.1+
- **Deployment**: AWS Amplify (CI/CD and hosting)

## Backend
- **Language**: TypeScript 5.3+
- **Framework**: Nest.js 10.0+ (enterprise Node.js framework)
- **API Style**: RESTful APIs
- **Database Client**: Slonik 40.0+ (type-safe PostgreSQL)
- **Validation**: class-validator 0.14+
- **Documentation**: OpenAPI/Swagger 7.1+
- **Testing**: Jest 29.7+
- **Deployment**: AWS Fargate/ECS (containerized)

## Database
- **System**: PostgreSQL 14+
- **Architecture**: Database-first with stored procedures
- **Extensions**: uuid-ossp, pgcrypto, pg_trgm, btree_gist
- **Features**: Row-Level Security, Multi-tenant isolation
- **Tables**: 70+ tables designed
- **Stored Procedures**: 69 procedures implemented

## Infrastructure (AWS)
- **CDN**: CloudFront
- **API Gateway**: AWS API Gateway with WAF
- **Compute**: Fargate/ECS for containers
- **Database**: RDS PostgreSQL
- **Storage**: S3 for documents
- **Serverless**: Lambda for async processing
- **Orchestration**: Step Functions for workflows
- **Queue**: SQS for async tasks
- **Security**: KMS for encryption, Cognito for auth
- **CMS**: Builder.io for marketing content

## External Integrations
- **Payments**: Stripe
- **SMS**: Twilio
- **Email**: SendGrid
- **Financial Data**: Quillt API
- **Real Estate**: External API (TBD)
- **Compliance**: Vanta (SOC 2)

## Development Tools
- **Version Control**: Git
- **Package Manager**: npm
- **Monorepo**: npm workspaces (future: Nx)
- **TypeScript Config**: Strict mode enabled
- **Code Generation**: pgtyped for SQL types