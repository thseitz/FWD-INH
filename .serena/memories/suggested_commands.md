# Suggested Commands for Development

## Database Operations

### PostgreSQL Connection (Windows)
```bash
# Connect to database
psql -h localhost -p 5432 -U postgres -d fwd_db

# Set password environment variable (Windows)
set PGPASSWORD=your_password

# Run SQL scripts
psql -h localhost -p 5432 -U postgres -d fwd_db -f "path\to\script.sql"
```

### Test Data Generator
```bash
# Navigate to test generator
cd "C:\Users\bob\github-thseitz\fwd-inh\docs\requirements\DB\Node JS scripts\test-data-generator"

# Install dependencies
npm install

# Generate test data
npm run forward-generate

# Clean test data
npm run forward-clean

# Test stored procedures
npm run test-procedures

# Run comprehensive tests
npm run test-comprehensive

# Run safe tests (non-destructive)
npm run test-safe
```

## Development Commands

### TypeScript/Node.js Commands
```bash
# Build TypeScript
npm run build
tsc

# Development mode with hot reload
npm run dev
tsx src/index.ts

# Start application
npm start
node dist/index.js

# Type checking
tsc --noEmit
```

### Testing Commands
```bash
# Run tests
npm test
npm run test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- path/to/test.spec.ts

# Run tests in watch mode
npm run test:watch
```

## Git Commands (Windows Compatible)

```bash
# Status and diff
git status
git diff

# Stage and commit
git add .
git commit -m "feat: your commit message"

# Branch operations
git checkout -b feature/new-feature
git push -u origin feature/new-feature

# Pull latest changes
git pull origin master

# View commit history
git log --oneline -10
```

## Windows System Commands

```bash
# List directory contents
dir
dir /b  # Brief listing

# Change directory
cd "path\to\directory"

# Create directory
mkdir folder_name

# Delete file
del filename

# Delete directory
rmdir /s folder_name

# Find files
where filename
dir /s /b *pattern*

# View file contents
type filename
more filename

# Environment variables
set VAR_NAME=value
echo %VAR_NAME%

# Clear screen
cls

# Copy files
copy source destination
xcopy /s source destination  # With subdirectories

# Move/rename files
move oldname newname
```

## AWS CLI Commands (if configured)

```bash
# List S3 buckets
aws s3 ls

# Deploy to Amplify
amplify push

# View CloudWatch logs
aws logs tail /aws/lambda/function-name --follow
```

## Docker Commands (for containerization)

```bash
# Build image
docker build -t forward-app .

# Run container
docker run -p 3000:3000 forward-app

# List containers
docker ps

# Stop container
docker stop container_id
```

## Package Management

```bash
# Install dependencies
npm install
npm ci  # Clean install from lock file

# Add new dependency
npm install package-name
npm install -D package-name  # Dev dependency

# Update dependencies
npm update

# Check for outdated packages
npm outdated

# Audit for security issues
npm audit
npm audit fix
```

## Database Schema Management

```bash
# Run schema creation scripts (in order)
psql -U postgres -d fwd_db -f "1_SQL_create_fwd_db.sql"
psql -U postgres -d fwd_db -f "2_SQL_create_schema_structure.sql"
psql -U postgres -d fwd_db -f "3_SQL_create_schema_relationships.sql"
psql -U postgres -d fwd_db -f "4_SQL_create_procs.sql"
```