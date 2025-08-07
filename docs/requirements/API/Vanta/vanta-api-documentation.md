# Vanta API Documentation

## Overview

The Vanta API is a RESTful service that enables programmatic access to Vanta's security and compliance platform. This documentation provides comprehensive details for integrating with Vanta's API.

**API Status**: Public Beta  
**Base URL**: `https://api.vanta.com`  
**Documentation**: https://developer.vanta.com/docs

## Authentication

### OAuth 2.0 Client Credentials Flow

Vanta uses OAuth 2.0 Client Credentials flow for API authentication.

#### Token Endpoint
```
POST https://api.vanta.com/oauth/token
```

#### Request Headers
```http
Content-Type: application/json
```

#### Request Body
```json
{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "scope": "vanta-api.all:read vanta-api.all:write",
  "grant_type": "client_credentials"
}
```

#### Response
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3599,
  "token_type": "Bearer",
  "scope": "vanta-api.all:read vanta-api.all:write"
}
```

#### Token Usage
Include the token in the Authorization header for all API requests:
```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

### Token Management
- **Expiration**: Tokens expire after 1 hour (3599 seconds)
- **Refresh**: Request a new token before expiration
- **Limit**: Only one active token per application at a time

### Available Scopes

#### Management API Scopes
- `vanta-api.all:read` - Read access to all resources
- `vanta-api.all:write` - Write access to all resources

#### Integration API Scopes
- `vanta-api.integrations:read` - Read integration data
- `vanta-api.integrations:write` - Write integration data

## Rate Limits

| Endpoint Type | Rate Limit | Time Window |
|--------------|------------|-------------|
| OAuth Authentication | 5 requests | per minute |
| Private/Public Integration | 20 requests | per minute |
| Management API | 50 requests | per minute |
| Auditor API (GET) | 250 requests | per minute |
| Auditor API (POST/PATCH) | 10 requests | per minute |
| Audit Sampling | 10 requests | per minute |

### Rate Limit Headers
Response headers include rate limit information:
```http
X-RateLimit-Limit: 50
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640995200
```

## Core API Endpoints

### 1. Security & Compliance Monitoring

#### Get Failing Computers
```http
GET /api/v1/computers?status=failing
```

Query computers with failing security checks.

**Query Parameters:**
- `status` (string): Filter by status (failing, passing, all)
- `pageSize` (integer): Number of results per page (default: 20, max: 100)
- `pageCursor` (string): Pagination cursor

**Response:**
```json
{
  "data": [
    {
      "id": "comp_123",
      "hostname": "laptop-001",
      "owner": "user@example.com",
      "failingChecks": [
        {
          "name": "Disk Encryption",
          "status": "FAILING",
          "lastChecked": "2024-01-06T10:00:00Z"
        }
      ]
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6MTIzfQ=="
  }
}
```

### 2. Resource Management

#### List Resources
```http
GET /api/v1/resources
```

#### Update Resource
```http
PATCH /api/v1/resources/{resourceId}
```

**Request Body:**
```json
{
  "owner": "new-owner@example.com",
  "description": "Production database server",
  "tags": ["production", "critical"]
}
```

### 3. Tests & Documents

#### Get Test Results
```http
GET /api/v1/tests/{testId}/results
```

**Query Parameters:**
- `status` (string): Filter by status (passing, failing, not_applicable)
- `framework` (string): Filter by compliance framework

#### Upload Document
```http
POST /api/v1/documents
```

**Request Body (multipart/form-data):**
```
Content-Type: multipart/form-data

file: [binary data]
name: "SOC2_Report_2024.pdf"
type: "audit_report"
expiration: "2025-01-01"
```

### 4. Controls & Frameworks

#### List Controls
```http
GET /api/v1/controls
```

#### Get Framework Details
```http
GET /api/v1/frameworks/{frameworkId}
```

**Response:**
```json
{
  "id": "soc2",
  "name": "SOC 2 Type II",
  "controls": [
    {
      "id": "CC1.1",
      "name": "Control Environment",
      "description": "The entity demonstrates a commitment to integrity and ethical values",
      "status": "SATISFIED",
      "evidence": ["policy_123", "training_456"]
    }
  ]
}
```

### 5. Vendor Management

#### List Vendors
```http
GET /api/v1/vendors
```

#### Create Vendor
```http
POST /api/v1/vendors
```

**Request Body:**
```json
{
  "name": "AWS",
  "category": "infrastructure",
  "critical": true,
  "assessmentFrequency": "annual",
  "contact": {
    "name": "Security Team",
    "email": "security@aws.amazon.com"
  }
}
```

#### Update Vendor Security Review
```http
PATCH /api/v1/vendors/{vendorId}/security-review
```

**Request Body:**
```json
{
  "status": "approved",
  "reviewDate": "2024-01-06",
  "nextReviewDate": "2025-01-06",
  "findings": [],
  "attestations": ["soc2", "iso27001"]
}
```

### 6. Integration Endpoints

#### Create Integration
```http
POST /api/v1/integrations
```

**Request Body:**
```json
{
  "name": "Custom HR System",
  "type": "hr_system",
  "config": {
    "apiUrl": "https://hr.example.com/api",
    "syncFrequency": "daily"
  }
}
```

#### Sync Integration Data
```http
POST /api/v1/integrations/{integrationId}/sync
```

**Request Body:**
```json
{
  "resources": [
    {
      "type": "employee",
      "externalId": "emp_001",
      "data": {
        "email": "john.doe@example.com",
        "department": "Engineering",
        "startDate": "2023-01-15",
        "hasAccessToProduction": true
      }
    }
  ]
}
```

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "The requested resource was not found",
    "details": {
      "resourceId": "res_123"
    }
  },
  "requestId": "req_abc123"
}
```

### HTTP Status Codes

| Status Code | Description |
|------------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid or expired token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

## Pagination

Most list endpoints support pagination using cursor-based pagination:

```http
GET /api/v1/resources?pageSize=50&pageCursor=eyJpZCI6MTAwfQ==
```

**Pagination Response:**
```json
{
  "data": [...],
  "pagination": {
    "hasMore": true,
    "nextCursor": "eyJpZCI6MTUwfQ==",
    "totalCount": 500
  }
}
```

## Webhooks

### Webhook Events

Vanta can send webhooks for the following events:

- `computer.status_changed` - Computer compliance status changed
- `test.completed` - Test execution completed
- `control.status_changed` - Control status changed
- `vendor.review_due` - Vendor review is due
- `document.expiring` - Document is expiring soon

### Webhook Payload
```json
{
  "id": "evt_123",
  "type": "computer.status_changed",
  "timestamp": "2024-01-06T10:00:00Z",
  "data": {
    "computerId": "comp_123",
    "previousStatus": "passing",
    "currentStatus": "failing",
    "failingChecks": ["disk_encryption"]
  }
}
```

### Webhook Verification
Verify webhook authenticity using the signature header:

```javascript
const crypto = require('crypto');

function verifyWebhookSignature(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}
```

## Code Examples

### Node.js/TypeScript Implementation

```typescript
import axios from 'axios';

class VantaAPIClient {
  private baseUrl = 'https://api.vanta.com';
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;

  constructor(
    private clientId: string,
    private clientSecret: string
  ) {}

  /**
   * Authenticate and get access token
   */
  private async authenticate(): Promise<void> {
    if (this.accessToken && this.tokenExpiry && this.tokenExpiry > new Date()) {
      return; // Token still valid
    }

    const response = await axios.post(`${this.baseUrl}/oauth/token`, {
      client_id: this.clientId,
      client_secret: this.clientSecret,
      scope: 'vanta-api.all:read vanta-api.all:write',
      grant_type: 'client_credentials'
    });

    this.accessToken = response.data.access_token;
    this.tokenExpiry = new Date(Date.now() + (response.data.expires_in * 1000));
  }

  /**
   * Make authenticated API request
   */
  private async request<T>(
    method: string,
    endpoint: string,
    data?: any
  ): Promise<T> {
    await this.authenticate();

    const response = await axios({
      method,
      url: `${this.baseUrl}${endpoint}`,
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json'
      },
      data
    });

    return response.data;
  }

  /**
   * Get failing computers
   */
  async getFailingComputers(): Promise<any> {
    return this.request('GET', '/api/v1/computers?status=failing');
  }

  /**
   * Update vendor security review
   */
  async updateVendorReview(vendorId: string, reviewData: any): Promise<any> {
    return this.request(
      'PATCH',
      `/api/v1/vendors/${vendorId}/security-review`,
      reviewData
    );
  }

  /**
   * Upload compliance document
   */
  async uploadDocument(file: Buffer, metadata: any): Promise<any> {
    const formData = new FormData();
    formData.append('file', file);
    Object.keys(metadata).forEach(key => {
      formData.append(key, metadata[key]);
    });

    return this.request('POST', '/api/v1/documents', formData);
  }

  /**
   * Get SOC 2 control status
   */
  async getSOC2Status(): Promise<any> {
    return this.request('GET', '/api/v1/frameworks/soc2');
  }
}

// Usage example
const vantaClient = new VantaAPIClient(
  process.env.VANTA_CLIENT_ID!,
  process.env.VANTA_CLIENT_SECRET!
);

// Get failing computers
const failingComputers = await vantaClient.getFailingComputers();
console.log('Failing computers:', failingComputers);

// Update vendor review
await vantaClient.updateVendorReview('vendor_123', {
  status: 'approved',
  reviewDate: new Date().toISOString(),
  nextReviewDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()
});
```

### Python Implementation

```python
import requests
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

class VantaAPIClient:
    def __init__(self, client_id: str, client_secret: str):
        self.base_url = "https://api.vanta.com"
        self.client_id = client_id
        self.client_secret = client_secret
        self.access_token: Optional[str] = None
        self.token_expiry: Optional[datetime] = None
    
    def _authenticate(self) -> None:
        """Authenticate and get access token"""
        if self.access_token and self.token_expiry and self.token_expiry > datetime.now():
            return  # Token still valid
        
        response = requests.post(
            f"{self.base_url}/oauth/token",
            json={
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "scope": "vanta-api.all:read vanta-api.all:write",
                "grant_type": "client_credentials"
            }
        )
        response.raise_for_status()
        
        data = response.json()
        self.access_token = data["access_token"]
        self.token_expiry = datetime.now() + timedelta(seconds=data["expires_in"])
    
    def _request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """Make authenticated API request"""
        self._authenticate()
        
        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json"
        }
        
        response = requests.request(
            method=method,
            url=f"{self.base_url}{endpoint}",
            headers=headers,
            json=data
        )
        response.raise_for_status()
        
        return response.json()
    
    def get_failing_computers(self) -> Dict[str, Any]:
        """Get computers with failing security checks"""
        return self._request("GET", "/api/v1/computers?status=failing")
    
    def update_vendor_review(self, vendor_id: str, review_data: Dict) -> Dict[str, Any]:
        """Update vendor security review"""
        return self._request(
            "PATCH",
            f"/api/v1/vendors/{vendor_id}/security-review",
            review_data
        )
    
    def get_soc2_status(self) -> Dict[str, Any]:
        """Get SOC 2 framework status"""
        return self._request("GET", "/api/v1/frameworks/soc2")

# Usage example
if __name__ == "__main__":
    import os
    
    client = VantaAPIClient(
        client_id=os.environ["VANTA_CLIENT_ID"],
        client_secret=os.environ["VANTA_CLIENT_SECRET"]
    )
    
    # Get failing computers
    failing_computers = client.get_failing_computers()
    print(f"Found {len(failing_computers['data'])} failing computers")
    
    # Update vendor review
    client.update_vendor_review("vendor_123", {
        "status": "approved",
        "reviewDate": datetime.now().isoformat(),
        "nextReviewDate": (datetime.now() + timedelta(days=365)).isoformat()
    })
```

## Best Practices

### 1. Token Management
- Cache tokens until expiration
- Implement automatic token refresh
- Never expose tokens in client-side code

### 2. Error Handling
- Implement exponential backoff for rate limits
- Log all API errors with request IDs
- Handle network timeouts gracefully

### 3. Rate Limiting
- Implement request queuing
- Monitor rate limit headers
- Use pagination efficiently

### 4. Data Sync
- Use webhooks for real-time updates
- Implement incremental sync strategies
- Validate data before sending

### 5. Security
- Store credentials securely (use environment variables or secrets manager)
- Validate webhook signatures
- Use HTTPS for all communications
- Implement request logging for audit trails

## Support & Resources

- **Developer Portal**: https://developer.vanta.com
- **API Reference**: https://developer.vanta.com/docs
- **Support**: support@vanta.com
- **Status Page**: https://status.vanta.com

## Changelog

### 2024-01 (Current - Public Beta)
- Initial public beta release
- Core API endpoints available
- OAuth 2.0 authentication
- Rate limiting implemented
- Webhook support added

---

**Note**: This API is in Public Beta. Breaking changes may occur. Always refer to the official documentation at https://developer.vanta.com for the most up-to-date information.