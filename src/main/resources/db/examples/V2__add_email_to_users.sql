-- =============================================================
-- V2 : Add 'email' column to users table
-- Scenario: Business requirement - we need to store user emails
--
-- This is a purely ADDITIVE change (new column) - safe to apply.
-- Flyway will detect that V1 has already been applied (via checksum
-- stored in flyway_schema_history) and only run V2.
-- =============================================================

ALTER TABLE users ADD COLUMN email VARCHAR(150);

