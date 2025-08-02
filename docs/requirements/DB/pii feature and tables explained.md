# PII Processing Feature & Table Logic Explanation

**Document Type:** Technical Specification  
**Version:** 1.0  
**Date:** August 2025  
**Status:** Comprehensive Analysis

---

## Core Architecture

The Forward Inheritance Platform implements a **sophisticated dual-storage PII protection system** designed for financial services compliance. The architecture follows a "security-first" approach with automated detection, classification, and masking of personally identifiable information.

---

## Key Components

### 1. PII Detection Pipeline
- **Automated Detection**: Uses AWS Comprehend for AI-powered entity recognition
- **Pattern Matching**: Configurable regex patterns for SSNs, account numbers, etc.
- **Confidence Scoring**: Each detection includes confidence levels (0.00-1.00)
- **Multi-language Support**: Handles English and Spanish content

### 2. Dual Storage Strategy
```
Original Data (Encrypted) ’ PII Masked Version (Encrypted)
     “                              “
S3 Storage                    S3 Storage
(Full Access)                (Restricted Access)
```

---

## Core Tables & Logic

### `pii_processing_jobs` - Processing Queue

**Table Structure:**
```sql
- job_id: Unique processing identifier
- tenant_id: Multi-tenant isolation
- asset_id/document_id: Source data reference
- status: 'queued' ’ 'processing' ’ 'completed'/'failed'
- pii_fields_detected: JSON array of detected PII types
- priority: 1-10 priority queue (lower = higher priority)
```

**Business Logic:**
- Documents queued automatically upon upload
- Background processing prevents UI blocking
- Priority system handles urgent processing first
- Comprehensive error handling and retry logic

### `pii_detection_rules` - Configurable Detection

**Table Structure:**
```sql
- rule_name: "SSN Detection", "Phone Validation"
- pii_type: 'ssn', 'phone', 'email', 'financial_account'
- detection_method: 'regex', 'ai_model', 'lookup_table'
- pattern_config: JSON rules and thresholds
- confidence_threshold: Minimum confidence for positive detection
```

**Business Logic:**
- Tenant-specific rules allow customization
- Multiple detection methods can be combined
- Rules can be activated/deactivated dynamically
- AI models improve over time with feedback

### `pii_masked_data` - Masked Storage

**Table Structure:**
```sql
- original_record_table/id: Source data reference
- masked_content: PII-scrubbed version
- masking_strategy: 'full_redact', 'partial_mask', 'tokenize'
- pii_types: Array of detected PII categories
- confidence_scores: JSON mapping of confidence per type
- classification_level: Data sensitivity classification
```

**Business Logic:**
- One masked record per original document/field
- Different masking strategies per PII type
- Maintains referential integrity with source data
- Supports versioning for re-processing

### `masking_strategies` - Configurable Masking

**Table Structure:**
```sql
- strategy_name: "Partial SSN Masking"
- pii_type: Target PII category
- masking_method: How to mask the data
- masking_pattern: "XXX-XX-####" (for partial masking)
- preserve_format: Maintain original formatting
```

**Business Logic:**
- Role-based masking (executives see more than staff)
- Configurable patterns per tenant
- Format preservation for usability
- Multiple strategies per PII type

### `pii_access_logs` - Audit Trail

**Table Structure:**
```sql
- log_id: Unique audit identifier
- user_id: Who accessed the data
- resource_type: 'document', 'contact', 'financial_account'
- resource_id: Specific resource accessed
- access_type: 'view_masked', 'view_original', 'download', 'print'
- pii_types_accessed: Array of PII categories viewed
- justification: Reason for access (if required)
- ip_address: Source IP for security tracking
```

**Business Logic:**
- Immutable audit records
- All PII access logged automatically
- Geographic anomaly detection
- Compliance reporting integration

### `pii_classification_levels` - Data Sensitivity

**Table Structure:**
```sql
- level_name: 'public', 'internal', 'confidential', 'restricted'
- level_code: Numeric hierarchy (1-4)
- access_requirements: JSON rules for access
- retention_policy: Data lifecycle rules
- masking_requirements: Default masking behavior
```

**Business Logic:**
- Hierarchical access control
- Automated retention policies
- Role-based visibility rules
- Compliance framework integration

---

## Processing Workflow

### 1. Document Upload Flow
```
Upload ’ Queue PII Job ’ AWS Comprehend ’ Detection Rules ’ Masking ’ Dual Storage
```

**Detailed Steps:**
1. **Document Upload**: User uploads document to S3
2. **Job Creation**: `queue_pii_processing()` creates processing job
3. **Text Extraction**: Document text extracted for analysis
4. **AI Detection**: AWS Comprehend identifies potential PII entities
5. **Rule Processing**: Custom detection rules applied
6. **Confidence Evaluation**: Results filtered by confidence thresholds
7. **Masking Application**: Appropriate masking strategies applied
8. **Dual Storage**: Original encrypted + masked versions stored
9. **Audit Logging**: Complete processing trail recorded

### 2. Access Control Flow
```
User Request ’ Role Check ’ Permission Level ’ Return Masked/Original
```

**Detailed Steps:**
1. **Request Validation**: Verify user authentication and session
2. **Tenant Isolation**: Confirm user belongs to correct FFC
3. **Role Resolution**: Determine user's roles within FFC
4. **Permission Check**: Evaluate access permissions for resource
5. **Content Selection**: Choose masked or original based on permissions
6. **Access Logging**: Record access attempt with full context
7. **Response Delivery**: Return appropriate content version

---

## Key Stored Procedures

### `queue_pii_processing()`
**Purpose:** Creates processing job with priority
**Parameters:**
- `p_tenant_id`: FFC identifier
- `p_document_id`: Document to process
- `p_job_type`: Processing type ('detection', 'reprocessing')
- `p_priority`: Job priority (1-10)

**Logic:**
- Validates tenant context and permissions
- Creates job record with unique identifier
- Sets appropriate priority based on document type
- Logs queuing action for audit trail
- Returns job ID for status tracking

### `process_pii_detection()`
**Purpose:** Main detection workflow
**Parameters:**
- `p_job_id`: Processing job identifier

**Logic:**
- Retrieves job details with tenant validation
- Updates job status to 'processing'
- Extracts text content from document
- Calls AWS Comprehend for AI detection
- Applies all active detection rules
- Combines results with confidence scoring
- Creates masked versions using appropriate strategies
- Updates job with results and completion status
- Logs all processing steps for audit

### `get_pii_safe_content()`
**Purpose:** Role-based content retrieval
**Parameters:**
- `p_user_id`: Requesting user
- `p_resource_table`: Source table name
- `p_resource_id`: Specific resource
- `p_field_name`: Requested field

**Logic:**
- Validates user session and tenant context
- Determines user roles within FFC
- Checks permissions for original vs masked access
- Retrieves appropriate content version
- Logs access attempt with full context
- Returns content with access metadata

### `create_masking_strategy()`
**Purpose:** Configure new masking approach
**Parameters:**
- `p_tenant_id`: FFC identifier
- `p_strategy_name`: Human-readable name
- `p_pii_type`: Target PII category
- `p_masking_method`: Masking technique
- `p_pattern`: Masking pattern (if applicable)

**Logic:**
- Validates tenant permissions for configuration
- Creates new masking strategy record
- Associates with appropriate PII types
- Sets default configuration parameters
- Enables for immediate use
- Logs configuration change for audit

---

## Multi-Tenancy & Security

### Tenant Isolation
- **Database Level**: Every table includes `tenant_id` with NOT NULL constraint
- **Row-Level Security**: RLS policies prevent cross-tenant access
- **Stored Procedures**: All procedures validate tenant context
- **Data Segregation**: Complete separation per family circle
- **API Isolation**: Tenant context enforced at application layer

### Access Control Matrix

| Role | Original PII | Masked PII | Configuration | Audit Logs |
|------|-------------|------------|---------------|------------|
| **FFC Owner** |  Full |  Full |  Full |  Full |
| **FFC Admin** |  Limited |  Full |  Limited |  Limited |
| **FFC Member** | L None |  Full | L None | L None |
| **FFC Viewer** | L None |  Limited | L None | L None |
| **Professional** |  Scoped |  Full | L None | L None |

### Security Features
- **Encryption at Rest**: All PII encrypted using AES-256
- **Encryption in Transit**: TLS 1.3 for all communications  
- **Key Management**: AWS KMS with automatic rotation
- **Access Logging**: All operations logged with user context
- **Anomaly Detection**: Geographic and behavioral monitoring
- **Session Management**: Maximum 5 concurrent sessions per user

---

## Compliance Features

### Regulatory Support

#### **GDPR Compliance**
- **Right to be Forgotten**: Complete data erasure workflows
- **Data Portability**: Export masked/original data per permissions
- **Consent Management**: Granular consent tracking per PII type
- **Breach Notification**: Automated alerting for security incidents

#### **CCPA Compliance**
- **Right to Know**: Complete disclosure of collected PII types
- **Right to Delete**: Secure deletion with audit trails
- **Right to Opt-Out**: Granular privacy controls
- **Non-Discrimination**: Equal service regardless of privacy choices

#### **Financial Regulations**
- **TILA**: Truth in Lending Act compliance for loan documents
- **Gramm-Leach-Bliley**: Financial privacy protection
- **SOX**: Sarbanes-Oxley audit trail requirements
- **PCI DSS**: Payment card data protection (if applicable)

### Audit Requirements
- **Immutable Records**: Cryptographically signed audit logs
- **Complete Lineage**: Full traceability of data access and changes
- **Retention Policies**: Configurable retention per regulation
- **Automated Reporting**: Compliance reports generated automatically
- **External Integration**: API endpoints for compliance tools

---

## Performance Optimizations

### Asynchronous Processing
- **Background Jobs**: PII processing doesn't block user operations
- **Queue Management**: Priority-based processing with deadlock prevention
- **Batch Processing**: Bulk operations for large document sets
- **Retry Logic**: Exponential backoff for failed processing jobs
- **Resource Scaling**: Auto-scaling based on queue depth

### Caching Strategy
- **Masked Content**: Redis caching for frequently accessed masked data
- **Detection Rules**: In-memory caching of active rules per tenant
- **User Permissions**: Session-based permission caching
- **Materialized Views**: Pre-computed compliance reports
- **CDN Integration**: Cached masked images and documents

### Database Performance
- **Strategic Indexing**: Optimized for tenant_id and access patterns
- **Partitioning**: Time-based partitioning for audit logs
- **Connection Pooling**: Efficient database connection management
- **Read Replicas**: Separate read operations from write operations
- **Query Optimization**: Stored procedures for complex operations

---

## Integration Points

### AWS Services Integration

#### **AWS Comprehend**
- **Real-time Detection**: API calls for immediate PII scanning
- **Batch Processing**: Bulk analysis for document migration
- **Custom Models**: Tenant-specific entity recognition training
- **Multi-language**: English and Spanish entity detection
- **Confidence Tuning**: Adjustable thresholds per tenant

#### **AWS S3**
- **Encrypted Storage**: Client-side encryption before upload
- **Dual Buckets**: Separate storage for original and masked content
- **Access Controls**: IAM policies for secure bucket access
- **Lifecycle Management**: Automated archival and deletion
- **Cross-Region Replication**: Disaster recovery and compliance

#### **AWS KMS**
- **Key Management**: Automatic encryption key rotation
- **Tenant Isolation**: Separate keys per FFC
- **Access Policies**: Fine-grained key usage permissions
- **Audit Trail**: Complete key usage logging
- **Compliance**: FIPS 140-2 Level 3 validation

#### **AWS Lambda**
- **Processing Pipeline**: Serverless PII detection workflow
- **Image Processing**: OCR and image-based PII detection
- **Webhook Processing**: Real-time integration responses
- **Scheduled Jobs**: Periodic re-scanning and compliance checks
- **Error Handling**: Dead letter queues for failed processes

### Application Integration

#### **RESTful APIs**
- **PII-Safe Endpoints**: Automatic masking based on user roles
- **GraphQL Support**: Fine-grained field-level access control
- **Webhook Notifications**: Real-time processing status updates
- **Rate Limiting**: Prevent abuse of PII access endpoints
- **API Documentation**: Swagger/OpenAPI with security annotations

#### **Real-time Features**
- **WebSocket Updates**: Live processing status for large documents
- **Push Notifications**: Mobile alerts for processing completion
- **Progress Tracking**: Real-time job status and estimated completion
- **Error Notifications**: Immediate alerts for processing failures
- **Status Dashboard**: Visual processing queue and statistics

#### **Mobile Applications**
- **Role-based Masking**: Appropriate content for mobile screens
- **Offline Support**: Cached masked content for offline access
- **Biometric Security**: Additional authentication for PII access
- **Document Capture**: Mobile document upload with immediate PII scanning
- **Push Notifications**: Processing status and security alerts

---

## Data Flow Examples

### Example 1: Trust Document Upload

**Scenario:** FFC Owner uploads trust document containing SSNs, tax IDs, and beneficiary information.

**Flow:**
1. **Upload**: Document uploaded to encrypted S3 bucket
2. **Queue**: `queue_pii_processing()` creates high-priority job
3. **Extract**: Text extraction via AWS Textract
4. **Detect**: AWS Comprehend identifies 15 PII entities:
   - 3 SSNs (confidence: 0.95, 0.92, 0.88)
   - 2 Tax IDs (confidence: 0.97, 0.94)
   - 10 addresses/phone numbers (confidence: 0.85-0.99)
5. **Validate**: Custom rules confirm all detections above 0.85 threshold
6. **Mask**: Apply strategies:
   - SSNs ’ "XXX-XX-1234" (partial masking)
   - Tax IDs ’ "[REDACTED]" (full redaction)
   - Addresses ’ "123 Main St, [CITY], [STATE]" (city/state masked)
7. **Store**: Dual storage with both versions encrypted
8. **Audit**: Complete processing logged with entity counts
9. **Notify**: FFC Owner receives processing completion notification

**Result:** FFC Members see masked version, FFC Owner can access original with audit logging.

### Example 2: Financial Account Integration

**Scenario:** Quillt API webhook delivers bank account data with account numbers and routing numbers.

**Flow:**
1. **Webhook**: Quillt sends account balance update
2. **Validate**: Signature verification and tenant identification
3. **Queue**: API data queued for PII processing
4. **Detect**: Account numbers and routing numbers identified
5. **Classify**: Financial account data marked as "confidential"
6. **Mask**: Account numbers ’ "****1234", routing numbers ’ "[HIDDEN]"
7. **Update**: Financial account records updated with masked display values
8. **Audit**: API integration and PII processing logged
9. **Sync**: Real-time balance updates pushed to connected users

**Result:** Balance visible to all FFC Members, account details restricted by role.

---

## Troubleshooting & Monitoring

### Common Issues

#### **High Queue Processing Times**
- **Symptoms**: Jobs stuck in 'queued' status for extended periods
- **Causes**: High volume uploads, AWS service limits, processing failures
- **Solutions**: Scale Lambda functions, implement batch processing, add priority queues
- **Monitoring**: Queue depth alerts, processing time metrics

#### **PII Detection Accuracy**
- **Symptoms**: False positives/negatives in PII detection
- **Causes**: Low confidence thresholds, inadequate training data, edge cases
- **Solutions**: Adjust confidence levels, add custom detection rules, retrain models
- **Monitoring**: Detection accuracy metrics, manual review workflows

#### **Access Permission Errors**
- **Symptoms**: Users unable to access expected content versions
- **Causes**: Role configuration errors, permission caching issues, session problems
- **Solutions**: Verify role assignments, clear permission cache, validate sessions
- **Monitoring**: Permission denial logs, access pattern analysis

### Monitoring & Alerting

#### **Key Metrics**
- **Processing Queue Depth**: Current jobs waiting for processing
- **Average Processing Time**: Time from queue to completion
- **Detection Accuracy Rate**: Percentage of correctly identified PII
- **Access Pattern Anomalies**: Unusual access attempts or patterns
- **Error Rates**: Failed processing jobs and API calls
- **Compliance Violations**: Unauthorized access attempts

#### **Alert Triggers**
- **Queue Backlog**: >100 jobs waiting for >1 hour
- **Processing Failures**: >5% failure rate in 15-minute window
- **Security Anomalies**: Access from unusual IP/location
- **High-Risk Access**: Original PII access by non-owners
- **System Errors**: AWS service outages or API failures
- **Compliance Issues**: Retention policy violations

---

## Future Enhancements

### Planned Features

#### **Advanced AI Capabilities**
- **Context-Aware Detection**: Understanding document context for better accuracy
- **Multi-Modal Analysis**: Image and audio PII detection
- **Predictive Masking**: AI-suggested masking strategies
- **Anomaly Detection**: ML-based unusual access pattern identification

#### **Enhanced Compliance**
- **HIPAA Compliance**: Healthcare information special handling
- **International Regulations**: PIPEDA, LGPD support
- **Industry Standards**: ISO 27001, NIST framework alignment
- **Automated Compliance Reports**: Real-time regulatory reporting

#### **User Experience Improvements**
- **Visual Masking Controls**: UI for configuring masking preferences
- **Smart Redaction**: Context-preserving intelligent masking
- **Progressive Disclosure**: Graduated access based on user verification
- **Mobile Optimization**: Enhanced mobile PII handling

### Technical Roadmap

#### **Q3 2025**
- Enhanced AWS Comprehend integration with custom models
- Real-time processing for small documents (<1MB)
- Advanced audit dashboard with compliance metrics
- Mobile app PII detection capabilities

#### **Q4 2025**
- Multi-region deployment for data residency compliance
- Advanced role-based masking with temporal controls
- Integration with external compliance platforms
- Automated privacy impact assessments

#### **Q1 2026**
- AI-powered context-aware detection
- Blockchain-based audit trail immutability
- Advanced analytics and reporting platform
- International regulation compliance expansion

---

## Conclusion

The Forward Inheritance Platform's PII Processing system represents a comprehensive, enterprise-grade solution for sensitive data protection in family wealth management. The system successfully balances:

- **Security**: Multi-layered protection with encryption, access controls, and audit trails
- **Compliance**: Support for major privacy regulations with automated reporting
- **Usability**: Role-based access ensuring users see appropriate data versions
- **Performance**: Asynchronous processing with intelligent caching and optimization
- **Scalability**: Cloud-native architecture supporting millions of families
- **Flexibility**: Configurable rules and strategies per tenant requirements

This architecture provides the foundation for secure, compliant family financial planning while maintaining the usability and performance required for a modern SaaS platform.

---

*This document represents the complete PII Processing feature specification as of August 2025. Implementation details may evolve based on regulatory changes and technical requirements.*