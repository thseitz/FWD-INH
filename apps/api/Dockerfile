# NestJS Backend API - Debian Container with NX
FROM node:20-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    postgresql-client \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash app
USER app
WORKDIR /app
ENV HOME=/home/app

# NX/FS/watcher friendly env; allow optional deps but skip lifecycle scripts 
ENV NX_DAEMON=false \
    CHOKIDAR_USEPOLLING=true \
    CHOKIDAR_INTERVAL=300 \
    WATCHPACK_POLLING=true \
    npm_config_audit=false \
    npm_config_fund=false

# Copy and install dependencies with cache optimization
COPY --chown=app:app package.json package-lock.json ./
RUN npm ci --no-audit --no-fund && npm rebuild

# Copy the rest of the application
COPY --chown=app:app . .

# Ensure NX caches are writable
RUN mkdir -p .nx/cache "$HOME/.nx" && \
    node node_modules/esbuild/install.js || true

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:3001/api/health || exit 1

# Start with ts-node directly to bypass NX issues
CMD ["sh", "-c", "cd apps/api && npx ts-node --project tsconfig.app.json src/main.ts"]