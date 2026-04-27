-- =============================================================
-- V6 : FIX-FORWARD example
-- =============================================================
-- SCENARIO (Simulated Mistake):
--   Imagine V5 accidentally named the column 'total_price' as
--   'total_cost' (wrong name). Developers have already applied V5
--   in production. Since Flyway DOES NOT support rollback of
--   versioned migrations (community edition), the recommended
--   approach is "Go Fix Forward":
--
--   ✅ DO: Create a NEW migration (V6) that corrects the mistake.
--   ❌ DON'T: Edit V5 and re-run (Flyway detects checksum change
--             and throws: "Migration checksum mismatch").
--
-- In this demo V5 already used the correct name, so we simulate
-- a fix-forward by renaming it back and forth for illustration.
-- In a real scenario this file would fix whatever V5 broke.
-- =============================================================

-- Fix-forward: suppose V5 created column with wrong name 'total_cost'
-- This migration renames it back to 'total_price'.
-- (H2 ALTER COLUMN RENAME syntax shown below)

-- In H2, renaming a column is done with:
-- ALTER TABLE orders ALTER COLUMN total_cost RENAME TO total_price;
-- Since our V5 already used the correct name, we add a useful
-- improvement instead to demonstrate the "go forward" principle:

ALTER TABLE orders ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- =====================================================================
-- KEY LESSON ON ROLLBACK:
-- =====================================================================
-- Flyway Community Edition does NOT have an undo/rollback command.
--
-- Recommended strategy:  "GO FIX FORWARD"
--
--  Bad migration applied    →  Write V{N+1} that compensates/fixes it
--  DROP a column by mistake →  V{N+1} re-adds the column
--  Wrong data inserted      →  V{N+1} corrects or deletes the data
--
-- This keeps the flyway_schema_history table clean and sequential
-- and is the industry-standard pattern for database migrations.
-- =====================================================================

