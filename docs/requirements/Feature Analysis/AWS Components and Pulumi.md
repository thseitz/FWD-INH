1. Recap: AWS components the doc actually commits to

Edge \& Frontend

CloudFront in front of the SPA; Builder.io as CMS origin for marketing content. Amplify hosts the React app and handles CI/CD.



API Layer

API Gateway (HTTP) as the single entry, with rate limiting/usage plans and AWS WAF ahead of backend services.

Compute

ECS on Fargate for the NestJS backend (plus workers).

Data \& Storage

RDS PostgreSQL, S3 for documents (two copies: original + masked), and a cost-optimized in-memory cache (Redis later, only when needed).



Auth \& Security

Cognito (Authorization Code + PKCE), httpOnly cookies via the API layer; KMS for encryption.



Async \& Workflows

SQS for app tasks/Stripe webhooks; Step Functions orchestrating Textract + Comprehend + Lambda for PII masking pipeline, writing to S3.



Region

Primary region us-west-1; CloudFront for US edge coverage.

2. Proposed infrastructure component list (Pulumi-ready)

Account \& org (baseline)

IAM OIDC role for GitHub Actions deploys; least-privilege roles for CI, ECS tasks, Step Functions, and data access.

Networking (per env: dev/stage/prod)

One VPC w/ 3 AZs, private subnets (app/db) and public subnets (egress only), IGW, NAT (1 per AZ or single for cost), route tables.

VPC endpoints (Gateway/Interface): S3, ECR (api+dkr), CloudWatch Logs, Secrets Manager, SSM, KMS, STS for private egress.

Security

KMS CMKs for RDS/S3/secrets; WAF on API Gateway (and CloudFront if desired); Secrets Manager for DB/Auth/3P API secrets.

CloudTrail + CloudWatch metrics/alarms; (optionally Security Hub/GuardDuty later).

Data \& storage

RDS PostgreSQL Multi-AZ, subnet group, parameter group; S3 buckets: docs-original, docs-processed, and website-static (versioning + KMS + lifecycle).

In-memory cache in NestJS; later add Redis (or Upstash) when scale requires it (matches ADR-004).

Compute \& containers

ECR repos (api, worker).

ECS (Fargate) cluster; task defs for API/worker/migrations; internal ALB for REST.

WebSockets: either API Gateway WebSocket API (NLB integration) or ALB WebSocket pass-through behind CloudFront (keeps Socket.io simple).

API \& auth

API Gateway HTTP API + VPC Link → internal ALB target; usage plans/quotas; WAF; custom domain + ACM.

Cognito User Pool \& Hosted UI; Pre-Token-Gen Lambda for tenant claims (per doc), tokens in httpOnly cookies.

Async \& workflows

SQS (main + DLQ) for app tasks \& Stripe webhooks.

Step Functions state machine invoking Textract/Comprehend/Lambda, writing to S3 and updating DB (as diagrammed).

Observability

CloudWatch log groups w/ retention, dashboards, alarms (5xx, p95, RDS CPU/connections, queue depth, Step Functions failures).

Sentry for app errors (per tech stack).

Frontend

Amplify app (connected to GitHub) building the React SPA; CloudFront in front (OAC) as CDN.

3. Step-by-step deployment plan (Pulumi + TypeScript), with test gates

Repo shape (monorepo w/ Nx as you specified; Pulumi project under /infra/pulumi):

/apps/frontend  /apps/api  /packages/shared  /infra/pulumi



Order for Bootstrapping the INFRA Build   

Here’s a lean-first, phase-by-phase build plan that keeps dev velocity high, costs low, and layers security/operability as you go—mapped to your doc’s decisions (Cognito + httpOnly cookies via API GW later; ECS/Fargate; RDS Postgres; S3; SQS; Step Functions; Amplify/CloudFront, etc.). 

&nbsp;



Phase 0 — Absolute fundamentals (account \& access)



Goal: safe(ish) root, fast developer access, billing safety.



Turn on root MFA, set alternate contacts, and create a break-glass user with MFA (store creds offline).



Create one “sandbox/dev” account (you can add stage/prod later) and enable AWS Budgets + alerts.



Enable CloudTrail (1 trail, all regions) → S3. (Security Hub/GuardDuty can wait a few phases to save cost.)



Create a minimal DeployRole for CI/CD later (GitHub OIDC-ready), and a DeveloperRole with console access.



Why now: these are near-zero-cost and unblock everything else.



Phase 1 — “Open” dev networking to move fast \& cheap



Goal: get containers/db reachable quickly, keep it simple.



Single VPC with two public subnets (2 AZs). No NAT Gateways yet (saves $$).



Security Groups: one for ALB (allow 80/443 from 0.0.0.0/0), one for ECS tasks (allow 3000 from ALB SG), one for DB (allow 5432 from ECS SG).



ALB (public) in front of your API service (this is a temporary dev front door; we’ll add API Gateway + WAF later per doc). 



Why now: avoids NAT and VPC endpoints early; lowest-cost, lowest-friction path in dev.



Pulumi toggles



// config.ts

export const isProd = pulumi.getStack() === "prod";

export const openDev = !isProd;       // public ALB, tasks with public IPs

export const natCount = isProd ? 2 : 0;



Phase 2 — Minimum app stack (frontend/backend/DB)



Goal: ship the app, end-to-end, with the fewest moving parts.



ECR: create api repo and push your NestJS image.



RDS PostgreSQL (dev): start single-AZ, small instance (e.g., t4g.small), KMS default key OK for now; upgrade later to Multi-AZ + CMK.



S3 buckets (early):



app-docs-original and app-docs-processed (versioning on; KMS later). Your doc’s dual-copy strategy comes later for the pipeline, but it’s harmless to create these now. 



ECS/Fargate: one cluster; one API service (2 tasks) behind the public ALB; tasks get public IP (no NAT).



Frontend: use Amplify to deploy the SPA now (or even a static S3 website for day‑1), call the ALB domain directly while auth isn’t enabled.



Smoke tests



curl ALB /healthz → 200.



App → DB migrations run via a one-off Fargate task.



SPA renders; API calls succeed.



Phase 3 — Add authentication/authorization (Cognito + cookies) and swap in API Gateway



Goal: follow your design: Cognito + Authorization Code w/ PKCE, httpOnly cookies, API Gateway front door.



Stand up Cognito User Pool + hosted UI (scopes openid email profile), callbacks to your API domain; add Pre-Token-Gen trigger if you need tenant/role claims baked into tokens per doc. 

&nbsp;



Introduce API Gateway (HTTP API) in front, and route /auth/\* + /api/\* to your backend. Keep credentials + CORS aligned; backend sets httpOnly cookies; JWT stays out of JS, matching your flow. 

&nbsp;



Use VPC Link only when you move the ALB to private later; for now, you can temporarily proxy to the public ALB to avoid adding NAT/endpoints yet. (We’ll lock it down in Phase 6.)



Smoke tests



Login via Cognito → callback handled by API → cookies set (id/access/refresh tokens), not visible to JS, CSRF cookie set. 



Expired token → refresh flow succeeds transparently. 



Phase 4 — Storage + async primitives (S3, SQS, workers)



Goal: enable uploads and background work while traffic is tiny.



Wire S3 buckets fully into the app (original + processed). Begin writing originals; masking pipeline will land processed copies.



Add SQS (main + DLQ). Start a worker ECS service that reads SQS (Stripe webhooks, notifications, etc.), which aligns with your queue-based reliability guidance. 

&nbsp;



Keep Redis out for now (your ADR prefers in‑memory first—add Redis only if scale/instances require it). 



Smoke tests



Upload doc → object appears in original bucket; a test job enqueued → worker consumes; DLQ receives poison messages.



Phase 5 — Document pipeline (Step Functions + Textract + Comprehend + Lambda)



Goal: fulfill PII masking flow once core app is stable.



Build a State Machine that: Validate → Textract → Comprehend PII → Mask → Write both copies → Update DB → Notify. Trigger by S3 event on original bucket, exactly as your doc prescribes. 



Use small Lambdas (few hundred MB mem) and short timeouts to keep cost predictable.



Smoke tests



Upload a sample PDF → see masked copy in processed → DB updated → app shows masked version.



Phase 6 — Tighten the network (private subnets, NAT, VPC endpoints, WAF)



Goal: harden now that dev velocity is unblocked.



Migrate ECS tasks to private subnets (no public IP). Add 1 NAT for the whole VPC (dev) to keep cost down; later scale NAT per AZ in prod.



Move ALB to internal; connect API Gateway via VPC Link to the ALB (your final pattern). 



Add VPC Endpoints for S3/ECR/Logs/Secrets/SSM/KMS to reduce NAT egress.



Attach WAF to API Gateway with sane defaults (rate limit, managed SQLi/XSS rules) as in your doc’s example; keep throttling low to avoid false positives early. 

&nbsp;



Smoke tests



External calls only via API Gateway (ALB not public anymore). WAF blocks a test signature. App still works.



Phase 7 — Frontend delivery at scale (CloudFront) and polish



Goal: production-grade delivery for static + API.



Put CloudFront in front of the SPA (Amplify or S3+OAC as origin) and, optionally, in front of API Gateway for global edge latency. (Your plan already includes CloudFront for static assets.) 



Turn on long‑TTL caching for static assets; keep APIs no‑cache.



Phase 8 — Observability, then CI/CD when it helps



Goal: add what improves stability right now; defer the rest.



CloudWatch Logs/Dashboards/Alarms: API 4xx/5xx, latency (p95), ECS CPU/Mem, RDS CPU/conn, SQS depth, Step Functions failures. Your doc even sketches API metrics widgets—perfect starting point. 



Add Sentry to FE/BE for error tracking (as listed). 



CI/CD (lightweight first):



GitHub Actions: build \& push Docker → pulumi up dev.



Gate on manual approvals for stage/prod (add stacks later).



Later: full pipeline (policy checks, blue/green for ECS, integration tests).



“Just enough” Pulumi module order



Keep each step deployable/testable:



00-account-foundation (budgets, CloudTrail minimal)



10-network-dev-open (public subnets, public ALB)



20-data-dev (RDS single‑AZ, S3 buckets)



30-ecr-ecs-api (cluster, api service behind ALB)



40-frontend-amplify (SPA to Amplify)



50-auth-cognito (user pool, app client, hosted UI) + 55-api-gateway (routes to ALB) 



60-queues-workers (SQS, worker service) 



70-step-functions-doc-pipeline (Textract/Comprehend flow) 



80-network-harden (private subnets, NAT=1, endpoints, VPC Link, ALB internal, WAF) 



90-cloudfront (put CDN in front of SPA; optional API)



95-observability (dashboards/alarms) 



99-cicd (OIDC role + pipelines)



Cost‑savvy defaults



NAT=0 until Phase 6; then NAT=1 in dev.



RDS single‑AZ in dev; Multi‑AZ only for prod.



ECS Fargate Spot allowed for non-critical workers.



Delay WAF until Phase 6 (it does cost), but keep app-level rate limiting in NestJS earlier as a backstop (as your doc suggests).









