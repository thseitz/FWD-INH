-- =====================================================
-- Forward Inheritance Platform - Database Creation Script
-- Purpose: Create the fwd_db database and configure settings
-- Script: SQL_Test_0.sql
-- Note: Run this script as a PostgreSQL superuser
-- =====================================================

-- Terminate existing connections to fwd_db if it exists
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'fwd_db' 
  AND pid <> pg_backend_pid();

-- Drop database if exists (be careful in production!)
DROP DATABASE IF EXISTS fwd_db;

-- Create the database
-- Note: Using template0 to avoid collation conflicts on Windows
CREATE DATABASE fwd_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    TEMPLATE = template0;

-- Connect to the new database
\connect fwd_db

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search
CREATE EXTENSION IF NOT EXISTS "btree_gist"; -- For exclusion constraints

-- Set default schema search path
ALTER DATABASE fwd_db SET search_path TO public;

-- Configure database settings for better performance
ALTER DATABASE fwd_db SET shared_preload_libraries = 'pg_stat_statements';
ALTER DATABASE fwd_db SET track_counts = on;
ALTER DATABASE fwd_db SET track_functions = 'all';
ALTER DATABASE fwd_db SET track_io_timing = on;

-- Create a dedicated application user (optional)
-- Uncomment and modify as needed
/*
CREATE USER fwd_app_user WITH 
    LOGIN
    NOSUPERUSER
    CREATEDB
    NOCREATEROLE
    INHERIT
    NOREPLICATION
    CONNECTION LIMIT -1
    PASSWORD 'your_secure_password_here';

-- Grant privileges to application user
GRANT CONNECT ON DATABASE fwd_db TO fwd_app_user;
GRANT USAGE ON SCHEMA public TO fwd_app_user;
GRANT CREATE ON SCHEMA public TO fwd_app_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO fwd_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO fwd_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO fwd_app_user;
*/

-- Create audit schema for future audit tables
CREATE SCHEMA IF NOT EXISTS audit;
COMMENT ON SCHEMA audit IS 'Schema for audit trail tables';

-- Create a schema for archived data
CREATE SCHEMA IF NOT EXISTS archive;
COMMENT ON SCHEMA archive IS 'Schema for archived/historical data';

-- Verify database creation
SELECT 
    current_database() as database_name,
    pg_database_size(current_database()) as size_bytes,
    pg_size_pretty(pg_database_size(current_database())) as size_pretty,
    datcollate as collation,
    datctype as character_type,
    version() as postgres_version;

-- List installed extensions
SELECT 
    extname as extension_name,
    extversion as version
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm', 'btree_gist')
ORDER BY extname;

-- Display success message
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '======================================';
    RAISE NOTICE 'Database fwd_db created successfully!';
    RAISE NOTICE '======================================';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Run SQL_Test_1.sql to create tables';
    RAISE NOTICE '2. Configure application user if needed';
    RAISE NOTICE '3. Set up backup procedures';
    RAISE NOTICE '======================================';
END $$;