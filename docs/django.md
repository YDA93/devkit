# 🌐 Django

DevKit includes a full suite of Django utilities to bootstrap, manage, and automate your Django projects.

## 📑 Table of Contents

- [🌐 Django](#-django)
  - [🎬 Project Bootstrap & Configuration](#-project-bootstrap--configuration)
  - [🧱 Database Schema & Migrations](#-database-schema--migrations)
  - [🔁 Database Initialization](#-database-initialization)
  - [💾 Data Backup & Restore](#-data-backup--restore)
  - [🌍 Translations & Localization](#-translations--localization)
  - [🚀 Development & Deployment Tools](#-development--deployment-tools)
  - [🧪 Testing & Quality Assurance](#-testing--quality-assurance)
  - [🔍 Introspection & Automation](#-introspection--automation)
  - [🧰 Utilities & Aliases](#-utilities--aliases)

## 🎬 Project Bootstrap & Configuration

- `django-project-start <project_name>` — Initializes a brand new Django project in the current directory using `django-admin`.
- `django-app-start <app_name>` — Creates a new Django app inside the current project via `manage.py startapp`.
- `django-settings [local|dev|prod|test]` — Activates your Python environment and sets the appropriate `DJANGO_SETTINGS_MODULE` based on the given environment.
- `django-secret-key-generate` — Generates a secure random string and sets it as the `DJANGO_SECRET_KEY` environment variable.

## 🧱 Database Schema & Migrations

- `django-migrate-make [args]` — A wrapper for `makemigrations`, forwards any arguments to the Django command.
- `django-migrate [args]` — Runs Django's `migrate` command with passed arguments.
- `django-migrate-initial` — Wipes all existing migrations and `__pycache__` folders, temporarily disables project URLs to avoid import errors, and reinitializes the database from scratch.
- `django-migrate-and-cache-delete` — Deletes all migration files (excluding `__init__.py`) and `__pycache__` directories, skipping the virtual environment.

## 🔁 Database Initialization

- `django-database-init` — Validates your environment, confirms user intent, resets the database, updates `.env`, runs initial migrations, and restores previously backed-up data (if available).

## 💾 Data Backup & Restore

- `django-data-backup` — Dumps the entire database to `data.json` using Django’s `dumpdata` command after user confirmation.
- `django-data-restore` — Restores data from a backup (by default `data.json`) and resets all auto-increment sequences using `sqlsequencereset`.

## 🌍 Translations & Localization

- `django-translations-make` — Scans for apps with a `locale/` directory and runs `makemessages` to generate `.po` translation files for Arabic.
- `django-translations-compile` — Compiles `.po` files into `.mo` binaries across all subdirectories with a `locale/` folder.

## 🚀 Development & Deployment Tools

- `django-run-server [port]` — Starts Django’s dev server on `0.0.0.0`. Defaults to port 8000 if not specified.
- `django-collect-static` — Clears and collects static files into the deployment-ready folder using Django’s `collectstatic`.
- `django-upload-env-to-github-secrets` — Uploads `.env` content and `GCP_CREDENTIALS` as GitHub repository secrets using the GitHub CLI (`gh`).

## 🧪 Testing & Quality Assurance

- `django-run-pytest [test_path]` — Runs `pytest` with Django’s test settings and full coverage reporting. Accepts optional test paths like `app/tests/test_something.py::TestClass::test_case`.
- `django-run-test [test_path]` — Uses Django’s `manage.py test` with test environment settings. Accepts the same test path format as `pytest`.

## 🔍 Introspection & Automation

- `django-find-cron-urls [project_root]` — Searches all internal apps defined in `INTERNAL_APPS` for URL patterns starting with `cron/`, and returns full URL paths using the `$ADMIN_DOMAIN`.

## 🧰 Utilities & Aliases

- `django-project-setup` — Sets up the environment, installs packages, and initializes the database in one command.
- `django-find-templates` — Prints the location of Django’s internal template directories.
- `django-format-documents` — Formats the codebase using `isort` and `black` (line length 80).
