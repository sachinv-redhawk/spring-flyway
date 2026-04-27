# 🛫 Flyway Database Migration Demo — Spring Boot + H2

> A complete, well-commented Spring Boot project that explains **how Flyway works**,
> covering both "starting from scratch" and "adding Flyway to an existing database",
> plus the recommended **rollback (fix-forward) strategy**.

---

## 📑 Table of Contents
1. [What is Flyway?](#what-is-flyway)
2. [Project Structure](#project-structure)
3. [How to Run](#how-to-run)
4. [Scenario 1 – Starting from Scratch](#scenario-1--starting-from-scratch)
5. [Scenario 2 – Adding Flyway to an Existing Database](#scenario-2--adding-flyway-to-an-existing-database)
6. [Migration Naming Convention](#migration-naming-convention)
7. [flyway_schema_history Table](#flyway_schema_history-table)
8. [REST Endpoints](#rest-endpoints)
9. [Rollback Strategy – Go Fix Forward](#rollback-strategy--go-fix-forward)
10. [Key Flyway Properties](#key-flyway-properties)
11. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

---

## What is Flyway?

**Flyway** is an open-source database migration tool that lets you version-control your database schema the same way you version-control your code.

| Problem without Flyway | Solution with Flyway |
|------------------------|----------------------|
| "Which SQL scripts did we run on prod?" | `flyway_schema_history` table tracks every migration |
| "Dev DB is different from prod DB" | Everyone runs the same ordered scripts automatically |
| "I forgot to run the ALTER TABLE script" | Flyway runs pending scripts on app startup |
| "Who changed what in the schema?" | Git history of `.sql` files |

**How it works (at app startup):**
```
App starts
    │
    ├── Does flyway_schema_history table exist?
    │       No  → create it
    │
    ├── Scan classpath:db/migration for V*.sql files
    │
    ├── For each migration (ordered by version):
    │       Already in history?  → skip
    │       Not in history?      → execute SQL + record in history
    │
    └── App continues to start normally
```

---

## Project Structure

```
src/
├── main/
│   ├── java/com/spring/flyway/
│   │   ├── FlywayApplication.java           # Spring Boot entry point
│   │   ├── entity/
│   │   │   ├── User.java                    # JPA entity – maps to 'users' table
│   │   │   └── Product.java                 # JPA entity – maps to 'products' table
│   │   ├── repository/
│   │   │   ├── UserRepository.java
│   │   │   └── ProductRepository.java
│   │   └── controller/
│   │       ├── DemoController.java          # REST endpoints for users & products
│   │       └── FlywayInfoController.java    # Shows migration history at runtime
│   └── resources/
│       ├── application.properties           # Flyway + H2 + JPA config
│       └── db/migration/                    # ← ALL MIGRATION SCRIPTS LIVE HERE
│           ├── V1__create_users_table.sql
│           ├── V2__add_email_to_users.sql
│           ├── V3__create_products_table.sql
│           ├── V4__seed_sample_data.sql
│           ├── V5__create_orders_table.sql
│           ├── V6__fix_forward_orders_add_updated_at.sql
│           └── B2__existing_db_baseline.sql  # For "adding Flyway later" scenario
```

---

## How to Run

```bash
# Clone / open the project, then:
./mvnw spring-boot:run
```

- App starts on **http://localhost:8080**
- H2 Console: **http://localhost:8080/h2-console**
  - JDBC URL: `jdbc:h2:mem:flywaydb`
  - Username: `sa`  |  Password: *(empty)*

---

## Scenario 1 – Starting from Scratch

> **"We are building a brand-new application. We add Flyway from day one."**

### Setup (already done in this project)

**`pom.xml`** – add Flyway dependency:
```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

**`application.properties`** – key settings:
```properties
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.jpa.hibernate.ddl-auto=none   # ← CRITICAL: Flyway owns the schema, NOT Hibernate
```

### What happens on first start

```
App starts (fresh database)
│
├─ Flyway creates: flyway_schema_history
│
├─ Executes V1__create_users_table.sql       → creates 'users'
├─ Executes V2__add_email_to_users.sql       → adds 'email' column
├─ Executes V3__create_products_table.sql    → creates 'products'
├─ Executes V4__seed_sample_data.sql         → inserts demo rows
├─ Executes V5__create_orders_table.sql      → creates 'orders', 'order_items'
└─ Executes V6__fix_forward_orders_add_updated_at.sql → adds 'updated_at'
```

### What happens on subsequent starts

```
App starts again (flyway_schema_history already has V1–V6)
│
└─ Flyway checks each migration → all already applied → NOTHING runs → fast startup
```

### Adding a new feature (V7)

Simply create `V7__your_description.sql`:
```sql
-- V7__add_user_phone.sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
```
Next startup: Flyway detects V7 is pending → runs it automatically.

---

## Scenario 2 – Adding Flyway to an Existing Database

> **"We have an app that has been running for months. The database already has tables.
> We want to start using Flyway now."**

### The problem

If you just add Flyway and create `V1__create_users_table.sql`, Flyway will try to
`CREATE TABLE users` — but it already exists! → **Error.**

### The solution: Baseline

#### Step 1 — Export your current schema
Take a snapshot of the existing schema (what's already in the database):
```sql
-- This becomes your "baseline" (what existed before Flyway)
-- Put this in a file (for documentation only — Flyway won't execute it)
-- See: B2__existing_db_baseline.sql in this project
```

#### Step 2 — Set `baseline-on-migrate` in `application.properties`
```properties
spring.flyway.baseline-on-migrate=true
spring.flyway.baseline-version=1
```

#### Step 3 — Create new migrations starting at V2

Any `.sql` files with version > 1 will be run. V1 is treated as "already done".

#### What Flyway does on first run with baseline

```
App starts (existing database with tables, no flyway_schema_history)
│
├─ Flyway creates flyway_schema_history
├─ Records version=1 as BASELINE (no SQL executed, just marked as done)
├─ Executes V2__add_new_column.sql  (new feature from here onward)
└─ Executes V3__...
```

#### B2__existing_db_baseline.sql in this project

The file `B2__existing_db_baseline.sql` in `db/migration` demonstrates this
scenario. The `B` prefix makes it a **Baseline** migration type in Flyway.

---

## Migration Naming Convention

```
V  1  __  create_users_table  .sql
│  │  │   │                   │
│  │  │   └── Description     └── Extension (.sql)
│  │  └── Double underscore (separator)
│  └── Version number (must be unique, can be 1, 2, 1.1, 2.3.4)
└── Prefix: V=Versioned, U=Undo(Pro), R=Repeatable, B=Baseline
```

| Prefix | Meaning |
|--------|---------|
| `V`    | **Versioned** – runs once, in version order (most common) |
| `R`    | **Repeatable** – runs every time its checksum changes (e.g., views, functions) |
| `B`    | **Baseline** – marks the starting point for an existing database |
| `U`    | **Undo** – reverses a migration (Flyway Teams / Pro only) |

---

## flyway_schema_history Table

After running the app, query this table in the H2 Console:
```sql
SELECT * FROM flyway_schema_history;
```

You'll see something like:

| installed_rank | version | description             | type | script                                   | checksum   | installed_by | state   |
|---------------|---------|-------------------------|------|------------------------------------------|------------|--------------|---------|
| 1             | 1       | create users table      | SQL  | V1__create_users_table.sql               | 123456789  | SA           | Success |
| 2             | 2       | add email to users      | SQL  | V2__add_email_to_users.sql               | 987654321  | SA           | Success |
| 3             | 3       | create products table   | SQL  | V3__create_products_table.sql            | 456123789  | SA           | Success |
| ...           | ...     | ...                     | ...  | ...                                      | ...        | ...          | ...     |

**The checksum column is crucial** — if you modify an already-applied `.sql` file,
Flyway will detect the checksum change and **refuse to start** (throws `FlywayException`).

---

## REST Endpoints

| Method | URL                  | Description                                      |
|--------|----------------------|--------------------------------------------------|
| GET    | `/api/users`         | List all users (seeded by V4)                    |
| GET    | `/api/users/{id}`    | Get user by ID                                   |
| POST   | `/api/users`         | Create a new user                                |
| GET    | `/api/products`      | List all products (seeded by V4)                 |
| GET    | `/api/products/{id}` | Get product by ID                                |
| POST   | `/api/products`      | Create a new product                             |
| GET    | `/api/flyway/info`   | 🔍 Show full Flyway migration history (JSON)      |

---

## Role of Entity, Repository & Controller

These classes exist purely as **demo scaffolding** to prove that Flyway migrations actually worked.
They have no business logic.

### Entities (`User`, `Product`)
Java mirrors of the DB tables created by Flyway scripts.
`spring.jpa.hibernate.ddl-auto=none` means **Hibernate does NOT create tables** — only Flyway does.

| Entity | Fields created by |
|--------|------------------|
| `User` — `username`, `firstName`, `lastName` | V1 |
| `User` — `email` | V2 |
| `Product` — `name`, `price`, `stock` | V3 |
| Seed data for both | V4 |

### Repositories (`UserRepository`, `ProductRepository`)
Standard Spring Data JPA interfaces. They query the tables Flyway created.
If a migration ran incorrectly (e.g. wrong column name), the repository query fails at runtime —
proving Flyway is the **single source of truth** for the schema.

### Controllers

**`DemoController`** — lets you visually verify data after migrations:
```
GET  /api/users       → shows users seeded by V4
GET  /api/products    → shows products seeded by V4
```

**`FlywayInfoController`** — injects the `Flyway` bean and calls `flyway.info()` to expose
the full migration history as JSON — same as `SELECT * FROM flyway_schema_history` but
accessible from a browser or Postman without needing H2 Console.

```
GET  /api/flyway/info
```

Sample response:
```json
[
  {
    "version": "1",
    "description": "create users table",
    "type": "SQL",
    "state": "Success",
    "installedOn": "2026-04-25T10:00:00.000+0000",
    "executionTime_ms": 12,
    "script": "V1__create_users_table.sql"
  },
  {
    "version": "2",
    "description": "add email to users",
    "type": "SQL",
    "state": "Pending",
    "installedOn": "pending",
    "executionTime_ms": 0,
    "script": "V2__add_email_to_users.sql"
  }
]
```

> 💡 Pending migrations (not yet run) also appear with `"state": "Pending"` —
> useful to preview what Flyway **will** run on next startup.

---

### Sample Requests

```bash
# See all users inserted by V4 seed migration
curl http://localhost:8080/api/users

# See Flyway migration history
curl http://localhost:8080/api/flyway/info

# Create a new user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","firstName":"Alice","lastName":"Wonder","email":"alice@example.com"}'
```

---

## Rollback Strategy – Go Fix Forward

### ❌ What you CANNOT do (Community Edition)

Flyway Community Edition **does not support undo/rollback** of versioned migrations.
There is no `flyway undo` command in the free tier.

### ✅ The Recommended Pattern: "Go Fix Forward"

> If a migration introduced a bug or mistake, **write a new migration that fixes it**.

```
Timeline:
──────────────────────────────────────────────────────────
V1  →  V2  →  V3  →  V4 (BUG!)  →  V5 (fixes V4)
──────────────────────────────────────────────────────────
```

#### Real-world examples

| Mistake in V{N} | Fix in V{N+1} |
|----------------|---------------|
| Dropped wrong column | `ALTER TABLE t ADD COLUMN col_name ...` |
| Created wrong column name | `ALTER TABLE t ALTER COLUMN wrong RENAME TO correct` |
| Inserted wrong data | `UPDATE/DELETE` the bad rows |
| Created table with wrong constraints | `ALTER TABLE` to fix constraints |

#### Why this is the right approach

1. **Audit trail is preserved** — The history shows exactly what happened and when.
2. **Team safety** — Once V4 is applied on other devs' machines, you can't change it.
3. **Production-safe** — No rollback scripts means no risk of data loss from automation.
4. **V6 in this project** demonstrates this pattern — see `V6__fix_forward_orders_add_updated_at.sql`.

#### The "broken V5" simulation in this project

See comments in `V6__fix_forward_orders_add_updated_at.sql` for a detailed walkthrough.

---

## Key Flyway Properties

```properties
# Enable/disable Flyway (useful in tests)
spring.flyway.enabled=true

# Where to find migration scripts
spring.flyway.locations=classpath:db/migration

# For existing databases - mark existing DB as baseline
spring.flyway.baseline-on-migrate=true
spring.flyway.baseline-version=1

# Allow running migrations out of order (use with caution)
spring.flyway.out-of-order=false

# Name of the history tracking table
spring.flyway.table=flyway_schema_history

# Validate applied migrations match scripts on disk (default: true)
spring.flyway.validate-on-migrate=true

# Ignore checksum mismatches (NOT recommended for production!)
# spring.flyway.ignore-migration-patterns=*:ignored

# Schema to manage (defaults to datasource default schema)
# spring.flyway.schemas=myschema
```

---

## Common Mistakes to Avoid

| Mistake | Why It's Bad | Fix |
|---------|-------------|-----|
| `spring.jpa.hibernate.ddl-auto=create` | Hibernate will wipe and recreate schema, conflicting with Flyway | Set to `none` |
| Editing an already-applied `.sql` file | Flyway checksum validation will fail on next startup | Create a new V{N+1} instead |
| Skipping version numbers intentionally | Breaks `out-of-order=false` validation | Keep versions sequential |
| Putting Flyway scripts in wrong folder | Flyway won't find them | Use `classpath:db/migration` |
| Not committing `.sql` files to Git | Other developers / CI won't have the migrations | Always commit migration files |

---

## Migration Evolution Diagram

```
V1 ──────────────────────────────────────────────────────────────────► V6
│         │           │            │            │            │
│         │           │            │            │            │
Create    Add         Create       Seed         Create       Fix Forward:
users     email       products     sample       orders       add updated_at
table     column      table        data         table        to orders
(DDL)     (DDL)       (DDL)        (DML)        (DDL)        (demonstrates
                                                              rollback pattern)
```

---

*Happy migrating! 🚀*

