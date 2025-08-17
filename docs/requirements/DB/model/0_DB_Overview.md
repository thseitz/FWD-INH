# 01 - Forward Inheritance Platform - Database Architecture Overview

## Table of Contents
1. [Introduction](#introduction)
2. [Platform Context](#platform-context)
3. [Database Design Philosophy](#database-design-philosophy)
4. [Key Architectural Decisions](#key-architectural-decisions)
5. [Technology Stack](#technology-stack)
6. [Security & Compliance](#security--compliance)
7. [Performance Considerations](#performance-considerations)
8. [Next Steps](#next-steps)

## Introduction

The Forward Inheritance Platform is a comprehensive multi-tenant SaaS application designed to help families manage their financial inheritance and estate planning. The database architecture supports complex family structures, diverse asset management, and sophisticated access control while maintaining simplicity and performance.

This document provides a high-level overview of the database design principles, architectural decisions, and technical considerations that guide the platform's data layer.

## Platform Context

### Business Purpose
- **Family Financial Management**: Track and manage diverse financial assets across family members
- **Estate Planning Support**: Document ownership structures, beneficiaries, and inheritance plans  
- **Multi-Generational Planning**: Support complex family relationships and changing ownership over time
- **Compliance & Audit**: Maintain detailed audit trails for legal and tax purposes

### Key Use Cases
- Asset inventory and valuation tracking
- Family member invitation and access management
- Document storage with PII protection
- Regular reporting and analytics
- Integration with external financial data providers

## Database Design Philosophy

### Core Principles

#### 1. **Type-Safe Database Architecture**
The platform uses pgTyped and Slonik for type-safe database operations:
- **pgTyped** provides compile-time SQL type safety from live schema
- **Slonik** delivers production-grade runtime PostgreSQL client
- **Single source of truth** - Each query lives in one `.sql` file
- **84% migration** - 59 of 70 procedures converted to individual SQL queries
- **Type validation** across all client applications
- **Better performance** through optimized query patterns

#### 2. **Multi-Tenant Design**
Every table includes a `tenant_id` to ensure complete data isolation between different family organizations:
- Single database instance serves multiple families
- Complete data separation and security
- Efficient resource utilization
- Simplified deployment and maintenance

#### 3. **Dual-Identity System**
The platform separates authentication (`users`) from business identity (`personas`):
- **Users**: Handle login, authentication, and system access
- **Personas**: Represent family members in business contexts
- One user can represent multiple family members (personas)
- Enables complex family relationship modeling

#### 4. **Ownership-Centric Model**
Assets are connected to personas through a flexible ownership system:
- Central `asset_persona` junction table manages all ownership relationships
- Supports percentage ownership, ownership types (owner, beneficiary, trustee)
- Enables complex inheritance scenarios and shared ownership

## Key Architectural Decisions

### 1. **PostgreSQL as Primary Database**
- **JSONB Support**: Flexible metadata storage for evolving asset types
- **UUID Primary Keys**: Asset and user entities use UUIDs for uniqueness
- **Integer Tenant IDs**: Simple integer IDs for tenants (1=Forward, 2-50 for customers)
- **Advanced Indexing**: GIN indexes for JSONB, full-text search capabilities
- **Robust Constraints**: Enum types for data integrity

### 2. **Enum-Driven Data Integrity**
Replace VARCHAR fields with PostgreSQL enums where possible:
- **Data Consistency**: Prevents invalid values at database level
- **Performance**: More efficient storage and comparison
- **Schema Evolution**: Clear documentation of allowed values
- **Application Safety**: Compile-time validation in strongly-typed languages

### 3. **Simplified Asset Category Design**
Instead of complex normalized asset structures:
- **One Table Per Asset Category**: 13 specialized asset tables (real_estate, financial_accounts, etc.)
- **Common Base**: All assets share a common `assets` table for basic properties
- **Flexible Metadata**: JSONB fields for category-specific attributes
- **Easy Querying**: Direct relationships without complex joins

### 4. **Comprehensive Audit Strategy**
- **Action-Level Auditing**: Every create, update, delete operation logged
- **Business Event Tracking**: Higher-level business events for weekly reports
- **PII Protection**: Separate audit trail for sensitive data access
- **Retention Policies**: Configurable audit log retention

## Technology Stack

### Database Layer
- **PostgreSQL 14+**: Primary database engine
- **JSONB**: Flexible schema elements and metadata
- **UUID**: Primary key strategy for distributed architecture
- **Enum Types**: Data integrity and performance optimization

### Security Features
- **Row-Level Security (RLS)**: Planned for additional tenant isolation
- **Encrypted Connections**: TLS for all database communications
- **Audit Logging**: Comprehensive activity tracking
- **PII Detection**: Automated detection and masking of sensitive data

### Integration Points
- **External APIs**: Quillt for financial data, real estate providers for valuations
- **Builder.io**: Content management system integration
- **Multi-language**: Spanish language support built-in

## Security & Compliance

### Data Protection
- **Multi-Tenant Isolation**: Complete data separation between families
- **PII Processing**: Automatic detection and optional masking of personally identifiable information
- **Access Control**: Role-based permissions at the Forward Family Circle (FFC) level
- **Audit Trails**: Complete activity logging for compliance requirements

### Authentication & Authorization
- **Dual-Channel Verification**: Both email and SMS verification required, utilizing AWS Cognito to support this process
- **Session Management**: JWT-style token management with configurable expiration through AWS Cognito
- **MFA Support**: Multi-factor authentication capabilities via AWS Cognito
- **Permission Hierarchy**: Granular permissions for different user roles

### Compliance Features
- **SOC 2 Ready**: Audit logging and access controls support SOC 2 requirements
- **GDPR Considerations**: PII masking and data retention policies
- **Weekly Reporting**: Automatic generation of family activity reports
- **Document Versioning**: Complete history of document changes

## Performance Considerations

### Indexing Strategy
- **Primary Access Patterns**: Indexes optimized for tenant-specific queries
- **JSONB Indexes**: GIN indexes for flexible metadata queries
- **Foreign Key Indexes**: Support for efficient joins
- **Composite Indexes**: Multi-column indexes for common query patterns

### Query Optimization
- **Stored Procedures**: Reduce network overhead and improve performance
- **Bulk Operations**: Specialized procedures for bulk data updates
- **Pagination**: Built-in pagination support for large result sets
- **Caching Strategy**: Database-level caching through procedure optimization

### Scalability Approach
- **Vertical Scaling**: PostgreSQL's robust vertical scaling capabilities
- **Read Replicas**: Future support for read-only replicas
- **Partitioning**: Potential table partitioning for large tenants
- **Connection Pooling**: Application-level connection management

## Database Statistics

### Current Schema Size
- **Total Tables**: 70+ tables across all functional areas (including subscription platform)
- **Stored Procedures**: 64+ procedures and functions (including subscription management)
- **Enum Types**: 71 custom enum types for data integrity
- **Indexes**: Comprehensive indexing strategy for performance

### Functional Areas
- **Core Infrastructure**: 11 tables (tenants, users, personas, etc.)
- **Asset Management**: 14 tables (base assets + 13 category tables)
- **Subscription & Payment**: 14 tables (plans, subscriptions, payments, ledger)
- **Security & Auth**: 8 tables (sessions, verifications, permissions)
- **Audit & Compliance**: 6 tables (logs, events, PII processing)
- **Integration**: 7 tables (external systems including Stripe)
- **Supporting**: 11 tables (contacts, addresses, documents, etc.)

## Next Steps

### Immediate Documentation
1. **Schema Reference**: Detailed ERD and data dictionary
2. **Table Documentation**: In-depth explanation of each functional area
3. **Procedure Documentation**: Complete stored procedure reference
4. **Developer Guides**: Integration and testing documentation

### Future Enhancements
1. **Performance Monitoring**: Query performance tracking and optimization
2. **Advanced Security**: Row-level security implementation
3. **Scalability Features**: Horizontal scaling preparation
4. **Analytics Platform**: Business intelligence and reporting enhancements

---

*This overview document is part of the Forward Inheritance Platform database documentation suite. For detailed technical information, refer to the specific documentation files for each functional area.*