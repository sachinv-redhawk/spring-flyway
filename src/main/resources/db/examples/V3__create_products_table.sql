-- =============================================================
-- V3 : Create 'products' table
-- Scenario: New feature - product catalogue
-- =============================================================

CREATE TABLE products (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    price       DECIMAL(10, 2) NOT NULL,
    stock       INT          NOT NULL DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

