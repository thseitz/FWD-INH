# Code Style and Conventions

## TypeScript Configuration
- **Target**: ES2022
- **Module**: CommonJS
- **Strict Mode**: Enabled (strict: true)
- **ES Module Interop**: Enabled
- **Force Consistent Casing**: Enabled
- **Resolve JSON Module**: Enabled

## Naming Conventions

### Database
- **Tables**: snake_case (e.g., `fwd_family_circles`, `asset_ownerships`)
- **Columns**: snake_case (e.g., `created_at`, `tenant_id`)
- **Stored Procedures**: sp_ prefix (e.g., `sp_register_user`, `sp_create_ffc`)
- **Enums**: snake_case with _enum suffix (e.g., `status_enum`, `asset_type_enum`)
- **Indexes**: idx_ prefix (e.g., `idx_personas_tenant_id`)
- **Foreign Keys**: fk_ prefix (e.g., `fk_personas_user`)

### TypeScript/JavaScript
- **Classes**: PascalCase (e.g., `AssetController`, `UserService`)
- **Interfaces**: PascalCase with I prefix optional (e.g., `IUser` or `User`)
- **Functions**: camelCase (e.g., `createAsset`, `getUserById`)
- **Variables**: camelCase (e.g., `userId`, `assetValue`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRIES`, `API_BASE_URL`)
- **Files**: kebab-case (e.g., `user-service.ts`, `asset-controller.ts`)

## Code Organization

### Backend (Nest.js)
- **Module-based structure**: Each domain has its own module
- **Separation of concerns**: Controllers, Services, Repositories
- **Dependency Injection**: Use constructor injection
- **Guards**: For authentication and authorization
- **Interceptors**: For cross-cutting concerns
- **DTOs**: For request/response validation

### Frontend (React)
- **Component-based**: Functional components with hooks
- **File structure**: Component file with same-named folder
- **State management**: Zustand stores for global state
- **Custom hooks**: For reusable logic
- **Type definitions**: Co-located with components

## Documentation
- **Comments**: Minimal, code should be self-documenting
- **JSDoc**: For public APIs and complex functions
- **README files**: For module/feature documentation
- **Architecture docs**: Maintained in /docs directory

## Error Handling
- **Try-catch blocks**: For async operations
- **Custom error classes**: Extend base Error class
- **Error logging**: Structured logging with context
- **User-friendly messages**: Separate from technical errors

## Testing Conventions
- **Test files**: *.spec.ts or *.test.ts suffix
- **Test structure**: Describe/it blocks
- **Mocking**: Use Jest mocks for dependencies
- **Coverage**: Aim for 80%+ coverage

## Git Conventions
- **Branch naming**: feature/*, bugfix/*, hotfix/*
- **Commit messages**: Conventional commits format
- **PR titles**: Clear description of changes
- **Code review**: Required before merge