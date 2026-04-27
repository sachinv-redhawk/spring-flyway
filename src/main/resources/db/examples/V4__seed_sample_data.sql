-- =============================================================
-- V4 : Seed sample data
-- Scenario: Load reference / demo data as part of migration
--
-- This is a DATA migration (DML) as opposed to V1-V3 which were
-- schema migrations (DDL). Flyway tracks both types identically.
-- =============================================================

INSERT INTO users (username, first_name, last_name, email) VALUES
    ('john.doe',   'John',  'Doe',   'john.doe@example.com'),
    ('jane.smith', 'Jane',  'Smith', 'jane.smith@example.com'),
    ('bob.jones',  'Bob',   'Jones', 'bob.jones@example.com');

INSERT INTO products (name, description, price, stock) VALUES
    ('Laptop',     'High-performance laptop',  999.99, 50),
    ('Mouse',      'Wireless ergonomic mouse',  29.99, 200),
    ('Keyboard',   'Mechanical keyboard',        79.99, 150),
    ('Monitor',    '4K UHD monitor',            499.99, 30);

