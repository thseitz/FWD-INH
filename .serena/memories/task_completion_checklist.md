# Task Completion Checklist

When completing any development task in the Forward Inheritance Platform, follow this checklist:

## Before Starting Code Changes
- [ ] Review relevant architecture documents (architecture.md, DB-architecture.md)
- [ ] Check if database schema changes are needed
- [ ] Verify stored procedures exist for data operations
- [ ] Understand the multi-tenant context (tenant_id requirements)

## During Development

### Database Changes
- [ ] Write SQL scripts for any schema changes
- [ ] Update stored procedures if needed
- [ ] Maintain audit trail requirements
- [ ] Ensure Row-Level Security policies are respected
- [ ] Test with multi-tenant scenarios

### Backend Development (Nest.js)
- [ ] Follow module-based architecture
- [ ] Use dependency injection properly
- [ ] Implement proper DTOs for validation
- [ ] Add appropriate guards for auth/authorization
- [ ] Handle errors with custom exception filters
- [ ] Call stored procedures through Slonik
- [ ] Add OpenAPI/Swagger documentation

### Frontend Development (React)
- [ ] Use TypeScript with strict typing
- [ ] Follow component-based architecture
- [ ] Implement with shadcn/ui components
- [ ] Manage state with Zustand if needed
- [ ] Ensure responsive design with Tailwind
- [ ] Handle loading and error states
- [ ] Add proper form validation

## Testing Requirements
- [ ] Write unit tests for new functions/components
- [ ] Test database operations with test data generator
- [ ] Run stored procedure tests: `npm run test-procedures`
- [ ] Execute safe tests: `npm run test-safe`
- [ ] Verify multi-tenant isolation
- [ ] Test error scenarios

## Code Quality Checks
- [ ] Run TypeScript compiler: `tsc --noEmit`
- [ ] Fix any type errors
- [ ] Ensure consistent naming conventions
- [ ] Remove unnecessary comments
- [ ] Check for security issues: `npm audit`

## Documentation
- [ ] Update relevant architecture docs if design changes
- [ ] Document new stored procedures
- [ ] Add JSDoc for complex functions
- [ ] Update README if new setup steps

## Pre-Commit Checklist
- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] Database scripts tested
- [ ] Code follows conventions
- [ ] Sensitive data not exposed
- [ ] Audit trail maintained

## Deployment Considerations
- [ ] Database migrations scripted
- [ ] Environment variables documented
- [ ] AWS resources configured
- [ ] Monitoring/logging in place
- [ ] Performance tested

## Special Considerations

### Subscription System
- [ ] Free plan auto-assignment working
- [ ] Stripe webhooks handled via queue
- [ ] Seat management logic correct
- [ ] UI visibility rules applied

### Security
- [ ] PII properly masked in documents
- [ ] Tenant isolation verified
- [ ] Authentication/authorization tested
- [ ] Audit logs generated

### Integration Points
- [ ] Stripe payment flow tested
- [ ] Email notifications working (SendGrid)
- [ ] SMS notifications working (Twilio)
- [ ] Document processing pipeline functional

## Final Verification
- [ ] Feature works end-to-end
- [ ] Performance acceptable
- [ ] Error handling comprehensive
- [ ] User experience smooth
- [ ] Documentation complete