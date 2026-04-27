-- V7 : Add phone number to users
-- This migration is added AFTER Flyway was introduced to the existing DB.
-- This is the first migration that Flyway will fully manage.

ALTER TABLE users ADD COLUMN phone VARCHAR(20);

