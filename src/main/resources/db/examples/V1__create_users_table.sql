-- =============================================================
-- V1 : Create the initial 'users' table
-- Scenario: Starting from scratch - this is the very first migration
--
-- Flyway naming convention:
--   V{version}__{description}.sql
--   e.g., V1__create_users_table.sql
--
-- When the app starts for the first time, Flyway will:
--   1. Create 'flyway_schema_history' tracking table
--   2. Run this script
--   3. Record it in flyway_schema_history with checksum + timestamp
-- =============================================================

CREATE TABLE users (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

