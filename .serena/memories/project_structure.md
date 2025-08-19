# Project Structure

## Current Repository Structure

```
fwd-inh/
├── docs/                           # Documentation root
│   ├── architecture.md            # Fullstack architecture document
│   ├── DB-architecture.md         # Database architecture details
│   ├── prd.md                     # Product Requirements Document
│   ├── pdf/                       # PDF versions of documents
│   └── requirements/              # Detailed requirements
│       ├── API/                   # API specifications
│       ├── Architecture/          # Architecture diagrams
│       ├── DB/                    # Database resources
│       │   ├── model/            # Data models
│       │   ├── Node JS scripts/  # Database utilities
│       │   │   └── test-data-generator/  # Test data generation
│       │   │       ├── src/      # TypeScript source files
│       │   │       ├── dist/     # Compiled JavaScript
│       │   │       └── package.json
│       │   └── sql scripts/      # SQL schema and procedures
│       │       ├── 1_SQL_create_fwd_db.sql
│       │       ├── 2_SQL_create_schema_structure.sql
│       │       ├── 3_SQL_create_schema_relationships.sql
│       │       └── 4_SQL_create_procs.sql
│       ├── Feature Analysis/      # Feature specifications
│       ├── Feedback/              # User feedback
│       ├── Q-A/                   # Q&A documentation
│       ├── metadata/              # Project metadata
│       └── pics/                  # Images and diagrams
├── web-bundles/                   # Web bundle configurations
│   ├── agents/                    # Agent configurations
│   ├── expansion-packs/           # Extension packs
│   └── teams/                     # Team configurations
├── .gitignore                     # Git ignore rules
├── .mcp.json                      # MCP configuration
└── .serena/                       # Serena tool files
```

## Planned Application Structure (Monorepo)

```
forward-platform/
├── apps/
│   ├── frontend/                  # React application
│   │   ├── src/
│   │   │   ├── components/       # React components
│   │   │   ├── pages/           # Page components
│   │   │   ├── hooks/           # Custom hooks
│   │   │   ├── stores/          # Zustand stores
│   │   │   ├── services/        # API services
│   │   │   ├── utils/           # Utilities
│   │   │   └── types/           # TypeScript types
│   │   ├── public/              # Static assets
│   │   └── package.json
│   └── backend/                   # Nest.js application
│       ├── src/
│       │   ├── modules/         # Feature modules
│       │   │   ├── auth/       # Authentication
│       │   │   ├── users/      # User management
│       │   │   ├── personas/   # Persona management
│       │   │   ├── ffcs/       # Family circles
│       │   │   ├── assets/     # Asset management
│       │   │   ├── subscriptions/ # Subscription handling
│       │   │   └── payments/   # Payment processing
│       │   ├── common/          # Shared code
│       │   │   ├── guards/     # Auth guards
│       │   │   ├── interceptors/ # HTTP interceptors
│       │   │   ├── filters/    # Exception filters
│       │   │   └── decorators/ # Custom decorators
│       │   ├── database/        # Database layer
│       │   │   ├── repositories/ # Data repositories
│       │   │   └── migrations/  # DB migrations
│       │   └── config/          # Configuration
│       └── package.json
├── packages/                      # Shared packages
│   ├── types/                    # Shared TypeScript types
│   ├── utils/                    # Shared utilities
│   └── database-types/           # Generated DB types
├── infrastructure/                # Infrastructure as code
│   ├── aws/                     # AWS CDK/Terraform
│   └── docker/                   # Docker configurations
├── scripts/                      # Build and deploy scripts
├── .github/                      # GitHub workflows
├── package.json                  # Root package.json
└── tsconfig.json                 # Root TypeScript config
```

## Key Architectural Decisions

1. **Monorepo Structure**: Using npm workspaces for managing multiple packages
2. **Database-First**: All data operations through stored procedures
3. **Module-Based Backend**: Nest.js modules for domain separation
4. **Component-Based Frontend**: React with TypeScript and shadcn/ui
5. **Shared Types**: Common TypeScript definitions across stack
6. **Infrastructure as Code**: AWS CDK or Terraform for deployments