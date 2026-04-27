-- V9__rollback_discount_from_products.sql
-- Fix Forward: undo V8 by dropping the discount column that was added in error.
-- In Flyway there is no built-in rollback — we always go FORWARD with a new version.
ALTER TABLE products DROP COLUMN IF EXISTS discount;

