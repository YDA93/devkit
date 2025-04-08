# 🐘 PostgreSQL

DevKit provides powerful helpers for PostgreSQL setup, diagnostics, and local development workflows.

## 📑 Table of Contents

- [🛠 PostgreSQL Setup & Connection](#-postgresql-setup--connection)
- [🔍 PostgreSQL Diagnostics](#-postgresql-diagnostics)
- [📊 Database Operations](#-database-operations)

---

## 🛠 PostgreSQL Setup & Connection

- **`postgres-setup`** — Starts PostgreSQL and creates the `postgres` superuser if needed.
- **`postgres-connect`** — Securely connects using environment variables or interactive prompt.
- **`postgres-password-validation`** — Validates current connection credentials.
- **`devkit-postgres-restart`** — Restarts PostgreSQL service via Homebrew.

---

## 🔍 PostgreSQL Diagnostics

- **`postgres-doctor`** — Checks installation, running service status, and login capability.

---

## 📊 Database Operations

- **`postgres-database-list`** — Lists all system and user databases.
- **`postgres-database-create`** — Interactively creates a new database (with overwrite prompt).
- **`postgres-database-delete`** — Interactively drops a database (with safety checks).

---

> 💡 Tip: Use `postgres-doctor` anytime you suspect connection issues or before initializing your environment.
