# React Frontend with Vite - Debian Container with NX
FROM node:20-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
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
# Fix for rollup optional dependency issue per npm bug #4828
RUN rm -rf node_modules package-lock.json || true && \
    npm install --no-audit --no-fund && \
    npm rebuild

# Copy the rest of the application
COPY --chown=app:app . .

# Ensure NX caches are writable
RUN mkdir -p .nx/cache "$HOME/.nx" && \
    node node_modules/esbuild/install.js || true

# Expose port
EXPOSE 4200

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:4200 || exit 1

# Start with vite directly to bypass NX issues
CMD ["sh", "-c", "cd apps/web && npx vite --host 0.0.0.0 --port 4200"]