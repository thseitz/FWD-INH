# Architecture: **pgTyped (types) + Slonik (runtime)** for a NestJS Backend

> **Purpose**  
> Provide a production-grade pattern where **pgTyped** supplies compile-time safety from a **live Postgres schema**, while **Slonik** delivers a robust **runtime client** (pooling, strict parameterization, logging) in a NestJS service layer.  
> **Principle**: Each query lives in **one `.sql` file** (single source of truth). **pgTyped** generates `Params`/`Row` types from those files. NestJS services **load the same file text** and **execute with Slonik**.

---

## 1) High-Level Design

- **Compile time**:  
  - `migrations → dev DB → pgTyped codegen → TS typecheck/tests`
  - pgTyped introspects the **dev** database and emits TypeScript types per query (`*.types.ts`).
- **Runtime**:  
  - NestJS services load the **exact `.sql` file content** and call Slonik (`pool.query(...)`).
  - Service method signatures are typed with pgTyped’s `Params`/`Row` output, so callers are contract-safe.
- **No duplication**:  
  - The SQL string used at runtime is the same file pgTyped read.  
  - Add a **checksum test** to enforce this.

---

## 2) Repository Layout

```
/apps/api
  /src
    /modules
      /users
        /queries
          get_users.sql
          get_user_by_id.sql
        users.service.ts
        users.module.ts
      /assets
        /queries
          list_assets.sql
          upsert_asset.sql
        assets.service.ts
        assets.module.ts
    /common
      sql-loader.ts            # tiny helper to load .sql text safely
      slonik.client.ts         # Slonik pool + logging/interceptors
  /generated
    /pgtyped
      /users
        get_users.types.ts
        get_user_by_id.types.ts
      /assets
        list_assets.types.ts
        upsert_asset.types.ts
  /scripts
    pgtyped.config.json
  /tests
    sql-checksum.spec.ts       # ensures runtime SQL == codegen SQL
/migrations                     # SQL migrations (e.g., with node-pg-migrate or sqitch)
/env                            # .env.{local,dev,ci,prod}
```

**Conventions**
- **One query per file** under `src/modules/*/queries/`.
- **Explicit column lists** (avoid `SELECT *`) so `Row` types are stable.
- **Snake case** for files: `get_user_by_id.sql`.

---

## 3) pgTyped Configuration (types-only)

`/apps/api/scripts/pgtyped.config.json`
```json
{
  "$schema": "https://raw.githubusercontent.com/adelsz/pgtyped/master/packages/pgtyped/bin/config.schema.json",
  "srcDir": "apps/api/src",
  "glob": "**/queries/*.sql",
  "failOnError": true,
  "db": {
    "host": "localhost",
    "port": 5432,
    "user": "pgtyped",
    "password": "pgtyped",
    "database": "app_dev",
    "ssl": false
  },
  "typeOverrides": [],
  "outDir": "apps/api/generated/pgtyped",
  "camelCaseColumnNames": true,
  "watch": false
}
```

**Notes**
- Point `db` to a **dev schema** that has the **latest migrations applied**.
- `outDir` mirrors module structure (pgTyped will create directories).
- In dev, run with `--watch`; in CI, run once and **fail if generation is needed**.

**NPM/PNPM scripts**
```json
{
  "scripts": {
    "migrate": "node-pg-migrate up -m migrations",
    "pgtyped:gen": "pgtyped --config apps/api/scripts/pgtyped.config.json",
    "pgtyped:watch": "pgtyped --config apps/api/scripts/pgtyped.config.json --watch",
    "typecheck": "tsc -p apps/api/tsconfig.json --noEmit",
    "test": "jest -c apps/api/jest.config.js"
  }
}
```

---

## 4) Slonik Client (runtime)

`/apps/api/src/common/slonik.client.ts`
- Create and export a **singleton Slonik Pool**.
- Add **interceptors**: query logging, timing, redaction.  
- Enforce **statement timeout** (e.g., via `SET statement_timeout` per connection or `pg_stat_statements` + app-level timeouts).
- Ensure **strict parameterization** (never string-concat values).

**Environment**
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, `PGSSLMODE`, and optional `PGCONNECT_TIMEOUT`, app statement timeout env.

---

## 5) SQL Loader Helper

`/apps/api/src/common/sql-loader.ts`
- Tiny function that loads `.sql` text (e.g., `readFileSync`) and optionally **caches** content in memory.
- Optionally normalizes whitespace/newlines for consistent checksums.

```ts
export function loadSql(relativePath: string): string {
  // e.g., resolve from __dirname to the queries folder
  // readFileSync, return UTF-8 string
}
```

---

## 6) NestJS Service Pattern

**Generated types** (by pgTyped), e.g.:  
`/apps/api/generated/pgtyped/users/get_user_by_id.types.ts`
```ts
/* HASH: abc123def456 */

export interface GetUserByIdParams { id: string; }   // derived from :id or $1 placeholder
export interface GetUserByIdRow { id: string; email: string; created_at: string; } // derived from SELECT
```

**Service uses the types and Slonik at runtime**:  
`/apps/api/src/modules/users/users.service.ts`
```ts
import { Injectable } from '@nestjs/common';
import { sql, DatabasePool } from 'slonik';
import { loadSql } from '../../common/sql-loader';
import { GetUserByIdParams, GetUserByIdRow } from '../../../generated/pgtyped/users/get_user_by_id.types';
import { slonikPool } from '../../common/slonik.client';

@Injectable()
export class UsersService {
  constructor(private readonly pool: DatabasePool = slonikPool) {}

  async getUserById(params: GetUserByIdParams): Promise<GetUserByIdRow | null> {
    const text = loadSql('modules/users/queries/get_user_by_id.sql');

    const values = [params.id];

    const result = await this.pool.query(sql.unsafe(text, values));
    return result.rowCount ? (result.rows[0] as GetUserByIdRow) : null;
  }
}
```

**Controller** returns DTOs mapped from `Row` types. For runtime validation, you can parse with Zod/DTO pipes (optional).

---

## 7) SQL Authoring Guidelines

- **Top-of-file docstring**: document placeholder order → `-- $1: id (uuid)`  
- Use **named CTEs** and **explicit columns** for clarity.  
- Keep **business rules** in Nest; SQL focuses on set-based operations and correctness.  
- For optional filters, prefer **composable SQL** (template sections) or use a small server-side builder that assembles the final SQL before execution (then still type against the superset query with pgTyped or maintain a minimal set of variants).

---

## 8) CI Pipeline (Drift-Proof)

**Order**
1. **Migrate** dev DB to latest (`pnpm migrate`).
2. **pgTyped generate** (`pnpm pgtyped:gen`). Fail if output changed and not committed.
3. **Checksum test** (below) to ensure runtime SQL == codegen SQL.
4. `pnpm typecheck`
5. `pnpm test`
6. Build & deploy.

**Checksum Test (`/apps/api/tests/sql-checksum.spec.ts`)**
- For each query:
  - Read `queries/*.sql`, compute a **hash** (e.g., SHA-256).
  - Read the **hash banner** in the generated `*.types.ts`.
  - **Assert equality**.

**How to get a codegen hash**  
- **Hash banner comment** in the generated `*.types.ts` (simple dev script that updates the file header).

---

## 9) Observability & Ops

- **Logging**: Slonik interceptors → structured logs (query text with redacted params), timings, row counts. Correlate with request-id via Nest interceptor.  
- **Timeouts**: App-level (AbortController) and/or DB-level (`statement_timeout`).  
- **Metrics**: Count slow queries, error rates per query file, pool saturation.  
- **Plan analysis**: Add a dev-only route or script to run `EXPLAIN (ANALYZE, BUFFERS)` on hot queries.  
- **Migrations**: Always run before pgTyped generation. Keep migrations idempotent/forward-only, and coordinate breaking changes with blue/green or feature flags.

---

## 10) Security

- **Strict parameterization**: All values via Slonik parameters—no string concatenation.  
- **Least-privilege DB role** for the app; restrict DDL in runtime connections.  
- **Secrets** via AWS Secrets Manager/Parameter Store; do not commit DSNs.  
- **PII**: keep out of logs; ensure redaction in interceptors.  
- **Row-level security** (optional): enforce multi-tenant constraints at DB level for defense-in-depth (plus app guards).

---

## 11) Developer Workflow (Day-to-Day)

1. Edit or add a query in `src/modules/*/queries/*.sql`.  
2. If schema changed, update migrations and run `pnpm migrate`.  
3. Run `pnpm pgtyped:watch` during development—types regenerate instantly.  
4. Update the service method signature to use the new `Params`/`Row` types.  
5. Run tests; commit both SQL and generated `*.types.ts`.  
6. CI enforces generation + checksum + typecheck.

---

## 12) Handling Dynamic Queries

- **Small variations**:  
  - Maintain **two or three** explicit `.sql` variants (e.g., `list_users.sql`, `list_users_with_filters.sql`).  
- **Truly dynamic** (many optional filters):  
  - Build final SQL server-side from fragments; then either:  
    - Type against the **superset** query with nullable filters, or  
    - For *these few cases*, you may use Slonik inline with `@slonik/typegen` (document exceptions).

---

## 13) Troubleshooting

- **pgTyped fails to generate**: Ensure dev DB is migrated; inspect SQL for invalid identifiers or missing casts.  
- **Checksum test fails**: You edited the `.sql` but didn’t regenerate the manifest/hash; run codegen step.  
- **Wrong param order at runtime**: Align `values[]` with `$1, $2…` order; document in SQL header.  
- **Type mismatch**: The generated `Row` reflects exactly what you `SELECT`. Update column list or service mapping.  
- **Production errors only**: Check pool limits, timeouts, and connection string (TLS). Validate that prod schema matches the version your build targeted.

---

## Summary

- **pgTyped** provides **compiler-level** guarantees: params/results match your **actual DB schema**.  
- **Slonik** provides **runtime excellence**: pooling, strict parameterization, logging, timeouts, ergonomics.  
- This architecture keeps **SQL in files (one truth)**, eliminates drift via **checksum in CI**, and preserves **DX + security** without adding an ORM.
