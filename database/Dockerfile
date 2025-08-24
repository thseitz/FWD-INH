# PostgreSQL Database - Debian-based
FROM postgres:17-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV POSTGRES_DB=fwd_db
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=FGt!3reGTdt5BG!
ENV PGDATA=/var/lib/postgresql/data/pgdata

# Copy initialization scripts
COPY apps/api/src/app/database/migrations/ /docker-entrypoint-initdb.d/

# Create custom postgresql.conf for better performance
RUN echo "# Custom PostgreSQL Configuration" > /tmp/custom.conf && \
    echo "listen_addresses = '*'" >> /tmp/custom.conf && \
    echo "port = 5432" >> /tmp/custom.conf && \
    echo "max_connections = 100" >> /tmp/custom.conf && \
    echo "shared_buffers = 256MB" >> /tmp/custom.conf && \
    echo "effective_cache_size = 1GB" >> /tmp/custom.conf && \
    echo "maintenance_work_mem = 64MB" >> /tmp/custom.conf && \
    echo "checkpoint_completion_target = 0.9" >> /tmp/custom.conf && \
    echo "wal_buffers = 16MB" >> /tmp/custom.conf && \
    echo "default_statistics_target = 100" >> /tmp/custom.conf

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD pg_isready -U postgres -d fwd_db || exit 1

# Start PostgreSQL
CMD ["postgres", "-c", "config_file=/tmp/custom.conf"]