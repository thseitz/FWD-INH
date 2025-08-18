
DROP DATABASE IF EXISTS fwd_db;
CREATE DATABASE fwd_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    -- Removed CONNECTION LIMIT = -1 per Robin's feedback (use default 100)
    TEMPLATE = template0
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

-- Step 2: Change connection to fwd_db manually, then run:
SET TIME ZONE 'UTC';
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

ALTER DATABASE fwd_db SET search_path TO public;
ALTER DATABASE fwd_db SET timezone = 'UTC';
--ALTER DATABASE fwd_db SET log_timezone = 'UTC';
ALTER DATABASE fwd_db SET track_counts = on;
ALTER DATABASE fwd_db SET track_functions = 'all';
ALTER DATABASE fwd_db SET track_io_timing = on;

CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS archive;