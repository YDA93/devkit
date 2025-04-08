# 🌐 Django

DevKit ships with full Django automation tools to bootstrap, manage, and streamline your projects.

## 📑 Table of Contents

- [🎬 Project Bootstrap](#-project-bootstrap)
- [🧱 Database Schema & Migrations](#-database-schema--migrations)
- [🔁 Database Initialization](#-database-initialization)
- [💾 Data Backup & Restore](#-data-backup--restore)
- [🌍 Translations & Localization](#-translations--localization)
- [🚀 Development & Deployment](#-development--deployment)
- [🧪 Testing & Quality](#-testing--quality)
- [🔍 Introspection & Automation](#-introspection--automation)
- [🧰 Utilities & Aliases](#-utilities--aliases)

---

## 🎬 Project Bootstrap

- **`django-project-start <project>`** — Create a new Django project in the current folder.
- **`django-app-start <app>`** — Add a new app to your Django project.
- **`django-settings [local|dev|prod|test]`** — Activate Python env and set `DJANGO_SETTINGS_MODULE`.
- **`django-secret-key-generate`** — Generate and set a secure Django secret key.

---

## 🧱 Database Schema & Migrations

- **`django-migrate-make [args]`** — Shortcut to `makemigrations`.
- **`django-migrate [args]`** — Run migrations.
- **`django-migrate-initial`** — Clean slate: wipe migrations/cache, disable URLs, re-init DB.
- **`django-migrate-and-cache-delete`** — Remove all migrations (except `__init__.py`) and caches.

---

## 🔁 Database Initialization

- **`django-database-init`** — Full DB reset: validate env, confirm action, recreate DB, restore data.

---

## 💾 Data Backup & Restore

- **`django-data-backup`** — Backup your database to `data.json`.
- **`django-data-restore`** — Restore data from `data.json` and reset sequences.

---

## 🌍 Translations & Localization

- **`django-translations-make`** — Generate `.po` files for Arabic across apps with `locale/`.
- **`django-translations-compile`** — Compile `.po` into `.mo` for deployment.

---

## 🚀 Development & Deployment

- **`django-run-server [port]`** — Start Django dev server on `0.0.0.0:8000` (default).
- **`django-collect-static`** — Collect and clear static files.
- **`django-upload-env-to-github-secrets`** — Push `.env` and `GCP_CREDENTIALS` to GitHub Secrets.

---

## 🧪 Testing & Quality

- **`django-run-pytest [test_path]`** — Run tests with `pytest` and coverage report.
- **`django-run-test [test_path]`** — Run Django tests via `manage.py`.

---

## 🔍 Introspection & Automation

- **`django-find-cron-urls [project_root]`** — Discover `cron/` URLs in internal apps and print full paths.

---

## 🧰 Utilities & Aliases

- **`django-project-setup`** — Full setup: env, dependencies, DB init.
- **`django-find-templates`** — Show Django’s internal template paths.
- **`django-format-documents`** — Format codebase with `isort` and `black`.

---

> 🚀 All Django commands are environment-aware. Make sure your Python environment is active before running them.
