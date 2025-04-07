# 🧰 DevKit CLI

**DevKit CLI** is a modular, Zsh-based automation toolkit that fully manages your macOS development environment — from first-time setup to daily maintenance and advanced workflow automations.

Whether you’re bootstrapping a new machine, updating your dev stack, or automating repetitive tasks, DevKit takes care of the heavy lifting. It installs, configures, and maintains your complete toolchain: Homebrew, Flutter, Firebase, Docker, Node.js, Python, Postgres, Django, Android SDK, GitHub workflows, and much more.

DevKit automates everything from CLI tools and SDKs to macOS system utilities, package managers, App Store apps, shell configurations, cloud CLIs, and even Docker containers — all with built-in diagnostics, safe prompts, logging, and self-updating magic.

> ⚙️ Built for Mac power users, automation fans, and dev teams who want to skip the setup pain and jump straight to building.

---

## 📑 Table of Contents

- [🧰 DevKit CLI](#-devkit-cli)
- [🚀 Features](#-features)
- [🚀 Installation Steps](#-installation-steps)
- [🔧 Requirements](#-requirements)
- [🚀 Core Workflow (Run these — they handle everything)](#-core-workflow-run-these--they-handle-everything)
- [🧩 Optional Helpers & Utilities](#-optional-helpers--utilities)
  - [🔍 Diagnostics & Updates](#-diagnostics--updates)
  - [🔧 Configuration & Environment Checks](#-configuration--environment-checks)
- [💻 System Utilities](#-system-utilities)
- [🍺 Homebrew](#-homebrew)
  - [🔧 Setup & Initialization](#-setup--initialization)
  - [📦 Package Management](#-package-management)
  - [🧹 Maintenance & Cleanup](#-maintenance--cleanup)
  - [🩺 Diagnostics & Health](#-diagnostics--health)
- [🔧 Git](#-git)
- [🍎 Xcode](#-xcode)
- [🐚 Zsh](#-zsh)
- [🐍 Python](#-python)
  - [🐍 Virtual Environment Commands](#-virtual-environment-commands)
  - [🐚 Python Shell](#-python-shell)
  - [📦 Pip Dependency Management](#-pip-dependency-management)
  - [🧩 Python Aliases](#-python-aliases)
- [🐘 PostgreSQL](#-postgresql)
  - [🛠 PostgreSQL Setup & Connection](#-postgresql-setup--connection)
  - [🔍 PostgreSQL Diagnostics](#-postgresql-diagnostics)
  - [📊 Database Operations](#-database-operations)
- [📦 NPM](#-npm)
- [🛒 Mac App Store (mas-cli) Integration](#-mac-app-store-mas-cli-integration)
- [🔐 GitHub SSH & Automation Tools](#-github-ssh--automation-tools)
  - [🔑 SSH Key Utilities](#-ssh-key-utilities)
  - [🚀 Workflow Helpers](#-workflow-helpers)
  - [🌿 Branch Management](#-branch-management)
  - [📥 Pulling, Tagging & Sync](#-pulling-tagging--sync)
  - [📊 Git Info](#-git-info)
- [🐳 Docker](#-docker)
  - [🧰 Daemon Control](#-daemon-control)
  - [🧹 Cleanup & Maintenance](#-cleanup--maintenance)
  - [📋 Listing Tools](#-listing-tools)
  - [🔍 Debugging & Interaction](#-debugging--interaction)
  - [🔨 Build Tools](#-build-tools)
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
- [💙 Flutter](#-flutter)
  - [🔥 Firebase & FlutterFire](#-firebase--flutterfire)
  - [🧠 Android & JDK Setup](#-android--jdk-setup)
  - [🎨 Flutter App Visuals](#-flutter-app-visuals)
  - [🔌 Development Utilities](#-development-utilities)
  - [🧹 Clean-Up & Maintenance](#-clean-up--maintenance)
- [🌐 Google Cloud](#-google-cloud)
  - [🧩 Essentials](#-essentials)
  - [🔐 Account Management](#-account-management)
  - [📂 Project Management](#-project-management)
  - [🔧 Django Deployment Shortcuts](#-django-deployment-shortcuts)
    - [🚨 Important: Prepare your .env file](#-important-prepare-your-env-file)
    - [📦 Artifact Registry Utilities](#-artifact-registry-utilities)
    - [🚀 Cloud Run Deployment Utilities](#-cloud-run-deployment-utilities)
    - [📆 Google Cloud Scheduler Utilities](#-google-cloud-scheduler-utilities)
    - [🐘 Google Cloud SQL for PostgreSQL](#-google-cloud-sql-for-postgresql)
    - [💾 Google Cloud Storage Management](#-google-cloud-storage-management)
      - [📂 Bucket Management](#-bucket-management)
    - [📤 Static Files & Access Control](#-static-files--access-control)
    - [🌐 Google Compute Engine - Load Balancer Automation](#-google-compute-engine---load-balancer-automation)
      - [🚦 Load Balancer Setup & Teardown](#-load-balancer-setup--teardown)
      - [🌍 IP Management](#-ip-management)
      - [🔐 SSL Certificate Management](#-ssl-certificate-management)
      - [🧩 Network Endpoint Group (NEG)](#-network-endpoint-group-neg)
      - [🔧 Backend Service Management](#-backend-service-management)
      - [🔧 URL Map Management](#-url-map-management)
      - [🔐 Target Proxies (HTTP / HTTPS)](#-target-proxies-http--https)
      - [🚦 Global Forwarding Rules](#-global-forwarding-rules)
    - [🔐 Google Secret Manager](#-google-secret-manager)

## 🚀 Features

DevKit is more than just a shell script — it’s a full-stack environment manager for macOS developers and automation enthusiasts. Here’s what DevKit brings to the table:

- **🔧 One-Line Environment Bootstrap**  
  devkit-pc-setup fully bootstraps your macOS dev environment: CLI tools, SDKs, languages, apps, shell configuration, and project preferences — all in one go.

- **♻️ Unified Stack Updater**  
  devkit-pc-update keeps your entire stack fresh: Homebrew, Flutter, Firebase, Google Cloud, Docker, NPM, Python, CocoaPods, App Store apps, system updates, and more.

- **🧪 Full Environment Diagnostics & Health Checks**  
  devkit-doctor audits your dev environment, languages, SDKs, mobile stacks, cloud tools, and system health — with actionable fixes.

- **📋 Toolchain Version Reporting**  
  devkit-check-tools lists installed versions of all tools — clean, emoji-labeled, and organized by category.

- **🐳 Docker Automation**  
  Manage Docker Desktop, containers, images, networks, logs, and builds with ease.

- **🐘 PostgreSQL Local Dev Helper**  
  Automate PostgreSQL setup, connection testing, database creation, and diagnostics.

- **🧩 Modular, Extensible Design**  
  Each integration lives in its own module for easy maintenance and extension — add your own workflows or override behaviors.

- **🌐 Cloud & Mobile Ready**  
  Native support for Firebase, Google Cloud, Flutter, Dart, Android SDK, CocoaPods, and GitHub automation — pre-configured and integrated.

- **🧠 Smart Prompts & Automation-Ready**  
  Clean prompts, safe defaults, and --quiet flags for automation workflows and CI/CD pipelines.

- **📦 Package Manager Automation**  
  Automate Homebrew, NPM, pip, and Mac App Store apps — backup, restore, prune, and update your packages effortlessly.

- **🔐 Git & GitHub Automation**  
  Built-in helpers for Git config, GitHub SSH keys, branches, stashes, tags, and syncs — streamline your workflows.

- **🐍 Python & Django Ready**  
  Manage virtual environments, pip dependencies, migrations, database seeding, testing, and more — DevKit handles full Django project automation.

- **📜 Self-Updating CLI**  
  devkit-update fetches the latest version of DevKit from GitHub and reloads automatically — no restarts required.

- **📚 Auto-Logging & Full Audit Trail**  
  All commands are logged under ~/devkit/logs with timestamped files for traceability and debugging.

- **💻 macOS System Utilities**  
  Includes helpers for DNS flush, IP lookups, Terminal restarts, system stats, cache cleaning, battery status, and more macOS-specific utilities.

---

## 🚀 Installation Steps

Open your terminal and run:

### 1. Change into the DevKit directory

```bash
cd ~/devkit
```

### 2. Run the installer script

```bash
zsh install.zsh
```

---

## 🔧 Requirements

- macOS
- Zsh shell
- Git
- Internet access (for installs and updates)

---

## 🚀 Core Workflow (Run these — they handle everything)

- 🔧 `devkit-pc-setup` — 🧰 Bootstraps your entire dev environment: prompts for your details, installs tools (Git, Homebrew, MAS apps, NPM, Xcode, Flutter), uses helpers, guides GUI app setup.
- 🔄 `devkit-pc-update` — ♻️ Runs full system and dev stack updates: Homebrew, Python, Google Cloud CLI, Flutter, Node.js, CocoaPods, Rosetta 2, MAS apps, DevKit itself.
- 🧪 `devkit-doctor` — 🩺 Runs full environment diagnostics: starts with devkit-check-tools, validates tools like Homebrew, Xcode, Git, Firebase, verifies shell & $PATH.

## 🧩 Optional Helpers & Utilities

🧩 These are optional — they are usually called automatically by the core commands.

### 🔍 Diagnostics & Updates

- 📋 `devkit-check-tools` — 🔍 Prints installed versions of essential dev tools, covering shell, dev tools, languages, mobile SDKs, cloud CLIs, databases, and warns about missing tools with suggestions.
- 📥 `devkit-update` - 🚀 Self-updates DevKit from GitHub by comparing local vs origin/main, auto-installs if missing, reloads CLI, and requires no external dependencies.

### 🔧 Configuration & Environment Checks

- 🧰 `devkit-settings-setup` — 📋 Interactive onboarding to personalize DevKit: prompts for name, email, install preferences (MAS, Homebrew Casks & Formulas), saves to ~/devkit/.settings, and runs automatically during setup.
- 🔎 `devkit-is-setup` — ✅ Quick system check to verify critical tools (Git, Zsh, Node, Python, Java, Docker, GCloud, Firebase, Flutter, CocoaPods, Postgres), with optional --quiet for scripts.

## 💻 System Utilities

- 🌐 `devkit-pc-ip-address` — Get local Wi-Fi IP address
- 🌍 `devkit-pc-public-ip` — Get your public IP address
- 📡 `devkit-pc-ping` — Check internet connection (Google DNS ping)
- 📴 `devkit-pc-shutdown` — Shut down the Mac
- 🔁 `devkit-pc-restart` — Restart the Mac
- 🧹 `devkit-pc-dns-flush` — Flush DNS cache
- 🧼 `devkit-pc-clear-cache` — Clear user/system cache folders
- 🗑️ `devkit-pc-empty-trash` — Force empty the trash folder
- 💽 `devkit-pc-disk` — Show disk usage
- 🔋 `devkit-pc-battery` — Show battery status
- 📊 `devkit-pc-stats` — Top resource usage
- 💻 `devkit-pc-version` — Show macOS version
- 🐚 `devkit-shell-info` — Show shell and interpreter info
- 🐚 `devkit-bash-reset` — Restart Bash shell
- 🔁 `devkit-terminal-restart` — Restart Terminal app

---

## 🍺 Homebrew

DevKit automates Homebrew setup, cleanup, and package installation based on your preferences.

### 🔧 Setup & Initialization

- `homebrew-setup` — Full setup: Full setup routine: installs Homebrew, prunes unlisted packages, restores saved packages, and performs maintenance.
- `homebrew-install` — Installs Homebrew if it’s not already installed. Verifies Homebrew is working afterward.

### 📦 Package Management

- `homebrew-save-packages` — Saves your currently installed formulae and casks to files. Useful for backups or sharing your setup.
- `homebrew-install-packages` — Installs formulae and casks from your saved package lists.
- `homebrew-install-from-settings` — Installs formulae and casks based on your .settings file preferences (y-marked entries).
- `homebrew-prune-packages` — Uninstalls any Homebrew packages not listed in your saved package files or .settings. Prompts before removal.
- `homebrew-list-packages` — Lists all currently installed Homebrew formulae and casks.

### 🧹 Maintenance & Cleanup

- `homebrew-maintain` — Updates, upgrades, and cleans Homebrew. Also runs a health check and verifies packages.
- `homebrew-clean` - Performs cleanup: removes unused dependencies, old versions, and verifies installed packages.

### 🩺 Diagnostics & Health

- `homebrew-doctor` — Runs Homebrew diagnostics, checks for issues, and reports outdated packages.

---

## 🔧 Git

DevKit ensures your Git environment is properly set up with global configurations and helpful defaults.

- `git-setup` — Configure Git global user info and preferences (runs automatically during setup)
- `git-doctor` — Diagnose Git installation, user config, SSH key, and GitHub connectivity
- `git-open-settings` — Open global Git config in VS Code

---

## 🍎 Xcode

DevKit automates macOS dev tools setup and ensures Xcode is ready for iOS/macOS development.

- `xcode-setup` — Install updates, accept Xcode license, setup CocoaPods and CLI tools
- `xcode-simulator-first-launch` — Prepares Simulator and platform support for first use
- `xcode-doctor` — Diagnose issues with Xcode installation, simulators, and Rosetta

---

## 🐚 Zsh

DevKit includes useful aliases to manage your Zsh shell quickly:

- `zsh-reload` — Reload your `.zshrc` configuration
- `zsh-reset` — Restart your Zsh shell session
- `zsh-edit` — Open `.zshrc` in VS Code
- `zsh-which` — Show the current shell path

---

## 🐍 Python

DevKit includes helpers to manage Python virtual environments and dependencies with ease.

### 🐍 Virtual Environment Commands

- `python-environment-create` — Creates a new `./venv` and activates it
- `python-environment-activate` — Activates the `./venv` if available
- `python-environment-is-active` — Checks if the current environment is active
- `python-environment-delete` — Deletes the `./venv`
- `python-environment-setup` — Recreates, activates `./venv`, and installs dependencies

### 🐚 Python Shell

- `python-shell [env]` — Activates environment, sets settings, and opens Django shell  
  (supports `local`, `dev`, `prod`, `test`)

### 📦 Pip Dependency Management

- `pip-install [--main|--test]` — Installs dependencies from requirements files
- `pip-update [--main|--test]` — Updates installed packages and regenerates requirements

### 🧩 Python Aliases

- `python` — Points to `python3`
- `pip` — Points to `pip3`

---

## 🐘 PostgreSQL

DevKit provides powerful helpers for PostgreSQL setup, diagnostics, and local development workflows.

### 🛠 PostgreSQL Setup & Connection

- `postgres-setup` — Starts PostgreSQL and creates the `postgres` superuser if needed
- `postgres-connect` — Securely connects using env vars or interactive prompt
- `postgres-password-validation` — Validates current connection credentials
- `devkit-postgres-restart` — Restart PostgreSQL service via Homebrew

### 🔍 PostgreSQL Diagnostics

- `postgres-doctor` — Checks installation, running service, and login capability

### 📊 Database Operations

- `postgres-database-list` — Lists all system and user databases
- `postgres-database-create` — Interactively creates a new database (with overwrite prompt)
- `postgres-database-delete` — Interactively drops a database (with safety checks)

---

## 📦 NPM

DevKit includes tooling to back up, restore, prune, and repair global npm packages — perfect for maintaining a clean Node.js environment.

- `npm-setup` — Full setup: prune unused and install saved packages
- `npm-repair` — Reinstall Node, clean, and restore packages
- `npm-save-packages` — Save currently installed global packages to a file
- `npm-install-packages` — Install global packages from saved list
- `npm-uninstall-packages` — Uninstall all saved packages
- `npm-prune-packages` — Uninstall packages not found in the saved list (with prompts)
- `npm-list-packages` — Show globally installed npm packages
- `npm-doctor` — Diagnose and validate npm & Node.js installation

---

## 🛒 Mac App Store (mas-cli) Integration

DevKit automates installation and maintenance of Mac App Store applications using `mas`.

- `mas-setup` — Full setup: installs saved and selected apps, then applies updates
- `mas-save-apps` — Save currently installed App Store apps (filters out cask-preferred)
- `mas-install-apps` — Install apps from saved list
- `mas-install-from-settings` — Install apps based on `.settings` flags
- `mas-maintain` — Check for updates and upgrade installed MAS apps
- `install-if-missing <name> <id>` — Installs app only if not already installed

---

## 🔐 GitHub SSH & Automation Tools

DevKit includes powerful GitHub utilities to manage SSH keys, simplify Git workflows, and automate branching, pushing, and tagging.

### 🔑 SSH Key Utilities

- `github-ssh-list` — List all SSH keys found in `~/.ssh/`
- `github-ssh-setup` — Generate and configure SSH key for GitHub access (port 443 fallback)
- `github-ssh-delete` — Interactively delete a selected SSH key
- `github-ssh-connection-test` - Test SSH connection to GitHub

### 🚀 Workflow Helpers

- `github-commit-and-push ["message"]` — Commit all changes and push (with confirmation)
- `github-clear-cache-and-recommit-all-files` — Reset Git cache and recommit everything
- `github-undo-last-commit` — Revert last commit from remote GitHub only

### 🌿 Branch Management

- `github-branch-rename <new>` — Rename current branch locally and on GitHub
- `github-branch-create <name>` — Create and switch to a new branch
- `github-branch-delete <name>` — Delete local and/or remote branch (with confirmation)
- `github-branch-list` — List all local and remote branches
- `github-branches-clean` — Delete all local branches merged into main
- `github-reset-to-remote` — Reset local branch to match remote HEAD (destructive)

### 📥 Pulling, Tagging & Sync

- `github-stash-and-pull` — Safely stash, pull, and reapply changes
- `github-push-tag <tag> [message]` — Create and push annotated Git tag
- `github-rebase-current [target]` — Rebase current branch onto another (default: main)
- `github-sync-fork` — Sync your fork’s main with upstream/main

### 📊 Git Info

- `github-status-short` — Show current branch and short status

---

## 🐳 Docker

DevKit offers convenient functions to manage Docker Desktop, containers, images, and debug your environment.

### 🧰 Daemon Control

- `docker-daemon-start [--quiet|-q]` — Start Docker and wait for it to become ready
- `docker-daemon-restart` — Restart Docker Desktop

### 🧹 Cleanup & Maintenance

- `docker-kill-all` — Kill all running containers
- `docker-clean-all` — Remove unused containers, images, volumes, and networks
- `docker-show-versions` — Show Docker and Compose versions

### 📋 Listing Tools

- `docker-list-containers` — Show all containers (running or not)
- `docker-list-running` — Show only running containers
- `docker-list-images` — Show all Docker images
- `docker-list-volumes` — List all Docker volumes
- `docker-list-networks` — List all Docker networks

### 🔍 Debugging & Interaction

- `docker-inspect-container <name|id>` — Show detailed container metadata
- `docker-logs <name|id>` — Tail logs of a running container
- `docker-shell <name|id>` — Open a shell inside a running container

### 🔨 Build Tools

- `docker-build <image_name>` — Build a Docker image from the current directory

---

## 🌐 Django

DevKit includes a full suite of Django utilities to bootstrap, manage, and automate your Django projects.

### 🎬 Project Bootstrap & Configuration

- `django-project-start <project_name>` — Initializes a brand new Django project in the current directory using `django-admin`.
- `django-app-start <app_name>` — Creates a new Django app inside the current project via `manage.py startapp`.
- `django-settings [local|dev|prod|test]` — Activates your Python environment and sets the appropriate `DJANGO_SETTINGS_MODULE` based on the given environment.
- `django-secret-key-generate` — Generates a secure random string and sets it as the `DJANGO_SECRET_KEY` environment variable.

### 🧱 Database Schema & Migrations

- `django-migrate-make [args]` — A wrapper for `makemigrations`, forwards any arguments to the Django command.
- `django-migrate [args]` — Runs Django's `migrate` command with passed arguments.
- `django-migrate-initial` — Wipes all existing migrations and `__pycache__` folders, temporarily disables project URLs to avoid import errors, and reinitializes the database from scratch.
- `django-migrate-and-cache-delete` — Deletes all migration files (excluding `__init__.py`) and `__pycache__` directories, skipping the virtual environment.

### 🔁 Database Initialization

- `django-database-init` — Validates your environment, confirms user intent, resets the database, updates `.env`, runs initial migrations, and restores previously backed-up data (if available).

### 💾 Data Backup & Restore

- `django-data-backup` — Dumps the entire database to `data.json` using Django’s `dumpdata` command after user confirmation.
- `django-data-restore` — Restores data from a backup (by default `data.json`) and resets all auto-increment sequences using `sqlsequencereset`.

### 🌍 Translations & Localization

- `django-translations-make` — Scans for apps with a `locale/` directory and runs `makemessages` to generate `.po` translation files for Arabic.
- `django-translations-compile` — Compiles `.po` files into `.mo` binaries across all subdirectories with a `locale/` folder.

### 🚀 Development & Deployment Tools

- `django-run-server [port]` — Starts Django’s dev server on `0.0.0.0`. Defaults to port 8000 if not specified.
- `django-collect-static` — Clears and collects static files into the deployment-ready folder using Django’s `collectstatic`.
- `django-upload-env-to-github-secrets` — Uploads `.env` content and `GCP_CREDENTIALS` as GitHub repository secrets using the GitHub CLI (`gh`).

### 🧪 Testing & Quality Assurance

- `django-run-pytest [test_path]` — Runs `pytest` with Django’s test settings and full coverage reporting. Accepts optional test paths like `app/tests/test_something.py::TestClass::test_case`.
- `django-run-test [test_path]` — Uses Django’s `manage.py test` with test environment settings. Accepts the same test path format as `pytest`.

### 🔍 Introspection & Automation

- `django-find-cron-urls [project_root]` — Searches all internal apps defined in `INTERNAL_APPS` for URL patterns starting with `cron/`, and returns full URL paths using the `$ADMIN_DOMAIN`.

### 🧰 Utilities & Aliases

- `django-project-setup` — Sets up the environment, installs packages, and initializes the database in one command.
- `django-find-templates` — Prints the location of Django’s internal template directories.
- `django-format-documents` — Formats the codebase using `isort` and `black` (line length 80).

## 💙 Flutter

A collection of custom Zsh functions and aliases to automate Flutter, Firebase, and Android/iOS environment setup and maintenance.

Boost your productivity with quick commands to manage Firebase functions, Android tools, iOS Pods, icons, translations, and more!

### 🔥 Firebase & FlutterFire

- `flutter-flutterfire-init` — Initialize Firebase & FlutterFire CLI for your project.
- `flutter-firebase-environment-create` - Create and activate a new Python venv for Firebase functions.
- `flutter-firebase-environment-setup` - Delete and recreate Firebase functions virtual environment.
- `flutter-firebase-update-functions` - Rebuild Firebase functions environment from scratch.
- `flutter-firebase-upload-crashlytics-symbols` - Upload obfuscation symbols to Firebase Crashlytics manually.
- `flutter-flutterfire-activate` - Activate FlutterFire CLI.
- `flutter-flutterfire-configure` - Launch Firebase project config tool.

### 🧠 Android & JDK Setup

- `java-symlink-latest` - Symlink latest Homebrew-installed OpenJDK to system.
- `flutter-android-sdk-setup` - Install Android SDK packages and accept licenses.

### 🎨 Flutter App Visuals

- `flutter-update-icon` - Update app launcher icons.
- `flutter-update-splash` - Update splash screen assets using flutter_native_splash.
- `flutter-update-fontawesome` - Update FontAwesome icons (local CLI utility).

### 🔌 Development Utilities

- `flutter-adb-connect <IP> <PORT>` - Connect device via ADB and update VSCode launch config.
- `flutter-build-runner` - Rebuild code generators (JSON serialization, etc.).
- `flutter-open-xcode` - Open iOS project in Xcode.
- `flutter-build-ios-warm-up` - iOS build with SKSL shaders.
- `flutter-build-android-warm-up` - Android build with SKSL shaders.
- `flutter-build-android` - Android production build + upload Crashlytics symbols.
- `flutter-dart-fix` - Apply Dart code fixes.

### 🧹 Clean-Up & Maintenance

- `flutter-clean` - Clean, upgrade dependencies, and apply Dart fixes.
- `flutter-maintain` - Full maintenance: Firebase, icons, pods, build runner, clean, etc.
- `flutter-delete-unused-strings` - Delete unused translation keys from .arb files.
- `flutter-cache-reset` - Clear Pod, Flutter, and Ccache caches.
- `flutter-ios-reinstall-podfile` - Reinstall iOS Podfile dependencies.

## 🌐 Google Cloud

Google Cloud support in DevKit gives you powerful CLI shortcuts, automation workflows, and project setup utilities for Django deployments on GCP. Manage accounts, projects, services, databases, storage, secrets, and deploy your application end-to-end.

### 🧩 Essentials

- `gcloud-init` — Initialize Google Cloud SDK and set up configurations.

- `gcloud-login-cli` — Authenticate user account for CLI access.

- `gcloud-login-adc` — Authenticate application default credentials.

- `gcloud-logout` — Revoke current authentication.

- `gcloud-info` — Show current SDK details and configuration.

- `gcloud-update` — Update installed components of the SDK.

### 🔐 Account Management

- `gcloud-account-list` — List all authenticated accounts.

- `gcloud-config-account-set <account>` — Set the active account for gcloud CLI.

### 📂 Project Management

- `gcloud-projects-list` — List all accessible projects.

- `gcloud-project-describe <project>` — Show details of a specific project.

- `gcloud-config-project-set <project>` — Set active project for gcloud CLI.

### 🔧 Django Deployment Shortcuts

A set of powerful functions to automate Django deployments on Google Cloud:

- `gcloud-project-django-setup` — 🛠️ Full project setup: Cloud SQL, buckets, secrets, Cloud Run deployment, load balancer, and scheduler jobs.

- `gcloud-project-django-teardown` — 💣 Clean teardown: destroys all GCP resources tied to your Django project.

- `gcloud-project-django-update` — 🔁 Redeploy and update services: deploy latest image, sync storage and secrets, update scheduler jobs.

**💡 Notes**  
All setup, teardown, and update functions automatically validate environment variables and .env secrets before execution.  
Log files are generated automatically for setup, teardown, and update steps, with timestamps for easy tracking.  
Secret files are written to /tmp/env_secrets securely during execution and deleted after loading.  
With these GCloud integrations, DevKit boosts your cloud automation game by allowing you to fully manage GCP Django deployments from the terminal — from project provisioning to full teardown and redeployment. ☁️🚀

#### 🚨 Important: Prepare your .env file

All Django Deployment Shortcuts and GCP automations rely on environment variables defined in your local .env file.

Before using these functions, ensure you:

1. Prepare and fill the .env file properly.  
   Your .env must include all required variables, such as:

   - ```# Example .env file
     GCP_PROJECT_ID=your-gcp-project-id                       # e.g., project-id
     GCP_PROJECT_NUMBER=your-gcp-project-number               # e.g., 1052922103635
     GCP_PROJECT_NAME=your-gcp-project-name                   # e.g., Hello World
     GCP_REGION=your-gcp-region                               # e.g., europe-west3
     GCP_RUN_NAME=your-cloud-run-service-name                 # e.g., project-django-run
     GCP_RUN_MIN_INSTANCES=your-min-instances                 # e.g., 0
     GCP_RUN_MAX_INSTANCES=your-max-instances                 # e.g., 5
     GCP_RUN_CPU=your-cpu                                     # e.g., 1
     GCP_RUN_MEMORY=your-memory                               # e.g., 1Gi
     GCP_EXTENDED_IMAGE_NAME=your-extended-image-name         # e.g., project-django-extended-run-image
     GCP_RUN_CPU=your-cpu                                     # e.g., 1
     GCP_RUN_MEMORY=your-memory                               # e.g., 1Gi
     GCP_SQL_INSTANCE_ID=your-sql-instance-id                 # e.g., project-sql-instance
     GCP_SQL_INSTANCE_PASSWORD=your-sql-instance-password     # e.g., your-sql-password
     GCP_SQL_DB_NAME=your-database-name                       # e.g., project_db
     GCP_SQL_DB_USERNAME=your-database-username               # e.g., project_db_user
     GCP_SQL_DB_PASSWORD=your-database-password               # e.g., your-database-password
     GCP_SQL_DB_VERSION=your-database-version                 # e.g., POSTGRES_15
     GCP_SECRET_NAME=your-secret-manager-name                 # e.g., project-django-secret
     GCP_ARTIFACT_REGISTRY_NAME=your-artifact-registry-name   # e.g., project-artifact-registry
     GCP_SCHEDULER_TOKEN=your-cloud-scheduler-bearer-token    # e.g., your-cloud-scheduler-token
     GCP_EXTENDED_IMAGE_NAME=your-extended-image-name         # e.g., project-django-extended-run-image
     GCP_SQL_PROXY_PORT=your-sql-proxy-port                   # e.g., 5432
     GS_BUCKET_STATIC=your-static-bucket-name                 # e.g., project-django-static
     GS_BUCKET_NAME=your-bucket-name                          # e.g., project-django-bucket
     OFFICIAL_DOMAIN=your-official-domain.com                 # e.g., project.com
     DJANGO_SECRET_KEY=your-django-secret-key                 # e.g., your-django-secret-key
     ADMIN_DOMAIN=your-admin-domain.com                       # e.g., admin.project.com
     GCP_CREDS=your-gcp-credentials-file.json                 # e.g., /path/to/your-credentials.json
     ```

2. Follow the official GCP Django sample app for best practices.  
   Reference: Cloud Run Django Sample App
3. Update any project-specific fields.  
   For example, buckets names, database credentials, and Cloud Run service names must match your actual resources.
4. Secrets are handled safely.  
   DevKit reads from .env, writes secrets to secure temporary files (/tmp/env_secrets), and cleans up after execution.
5. Always check your .env before running destructive commands.  
   Functions like gcloud-project-django-teardown will permanently delete resources defined in your .env.

✅ Once your .env is configured, DevKit handles the rest.
You’ll be able to run end-to-end Django deployments on GCP — securely and repeatably.

#### 📦 Artifact Registry Utilities

Manage Docker Artifact Registries for Cloud Run deployments.

- `gcloud-artifact-registry-repository-create` — Create a new Docker Artifact Registry repository
- `gcloud_artifact_registry_repository_delete` — Delete an Artifact Registry repository and its contents

#### 🚀 Cloud Run Deployment Utilities

DevKit automates building Docker images, pushing to Artifact Registry, and deploying services to Cloud Run.

- `gcloud-run-build-image` — Build Docker image and push to Artifact Registry
- `gcloud-run-deploy-initial` — Deploy service to Cloud Run for the first time
- `gcloud-run-deploy-latest` — Redeploy service to Cloud Run with the latest image
- `gcloud-run-set-service-urls-env` — Update service URLs environment variable in Cloud Run
- `gcloud-run-build-and-deploy-initial` — Build and deploy service (first-time setup)
- `gcloud-run-build-and-deploy-latest` — Build and redeploy service (update)
- `gcloud-run-service-delete` — Delete Cloud Run service and job

#### 📆 Google Cloud Scheduler Utilities

Automate Django cron jobs as scheduled Cloud Tasks using GCP Cloud Scheduler. Sync local URLs, create, update, and delete jobs easily.

- `gcloud-scheduler-jobs-list` — List all Cloud Scheduler jobs in the current project and region
- `gcloud-scheduler-jobs-delete` — Delete all Cloud Scheduler jobs with confirmation
- `gcloud-scheduler-jobs-sync` — Sync local Django cron jobs with Cloud Scheduler (creates or deletes jobs as needed)

#### 🐘 Google Cloud SQL for PostgreSQL

Automate Cloud SQL instance creation, proxy connections, user management, and Django setup.

- `gcloud-sql-instance-create` — Create Cloud SQL PostgreSQL instance with backups and monitoring
- `gcloud-sql-instance-delete` — Delete Cloud SQL PostgreSQL instance
- `gcloud-sql-proxy-start` — Start the Cloud SQL Proxy for local secure connections
- `gcloud-sql-postgres-connect` — Connect to Cloud SQL PostgreSQL instance via gcloud CLI
- `gcloud-sql-db-and-user-create` — Create new PostgreSQL database and user inside Cloud SQL
- `gcloud-sql-db-and-user-delete` — Delete PostgreSQL database and user from Cloud SQL
- `gcloud-sql-proxy-and-django-setup` — Start SQL Proxy, run Django migrations, and populate the database

#### 🔐 Google Secret Manager

Automate the management of environment secrets for your projects using Google Secret Manager.

- `gcloud-secret-manager-env-create` — 🔐 Create new secret from .env file
- `gcloud-secret-manager-env-update` — 🔄 Update secret with new version and disable old versions
- `gcloud-secret-manager-env-delete` — 🗑️ Delete secret from Secret Manager
- `gcloud-secret-manager-env-download` — 📥 Download secret to local .env file

#### 💾 Google Cloud Storage Management

Full control over your static, media, and artifact storage buckets — create, configure access, sync, and clean up effortlessly.

##### 📂 Bucket Management

- `gcloud-storage-buckets-create` — 🗃️ Create static, media, and artifacts buckets with access control and CORS
- `gcloud-storage-buckets-delete` — 🗑️ Delete all storage buckets and their contents

#### 📤 Static Files & Access Control

- `gcloud-storage-buckets-sync-static` — 📤 Upload and sync local static files to the bucket
- `gcloud-storage-buckets-set-public-read` — 🌐 Set public read access on static and media buckets
- `gcloud-storage-buckets-set-cross-origin` — 🔄 Apply CORS policy to buckets

#### 🌐 Google Compute Engine - Load Balancer Automation

Automate the complete lifecycle of your Google Cloud Load Balancer setup, including IP allocation, SSL certs, network groups, backend services, proxies, forwarding rules, and teardown.

##### 🚦 Load Balancer Setup & Teardown

- `gcloud-compute-engine-cloud-load-balancer-setup` — ⚙️ Full setup: static IP, SSL, NEG, backend, URL map, proxies, forwarding rules
- `gcloud-compute-engine-cloud-load-balancer-teardown` — 🔄 Full teardown of the Cloud Load Balancer components

##### 🌍 IP Management

- `gcloud-compute-engine-ipv4-create` — 🌐 Create global static IPv4 address for Load Balancer
- `gcloud-compute-engine-ipv4-delete` — 🗑️ Delete static IPv4 address

##### 🔐 SSL Certificate Management

- `gcloud-compute-engine-ssl-certificate-create` — 🔐 Create Google-managed SSL certificate
- `gcloud-compute-engine-ssl-certificate-delete` — 🗑️ Delete SSL certificate

##### 🧩 Network Endpoint Group (NEG)

- `gcloud-compute-engine-network-endpoint-group-create` — 🔌 Create serverless NEG for Cloud Run
- `gcloud-compute-engine-network-endpoint-group-delete` — 🗑️ Delete serverless NEG

##### 🔧 Backend Service Management

- `gcloud-compute-engine-backend-service-create` — ⚙️ Create backend service and attach NEG
- `gcloud-compute-engine-backend-service-delete` — 🗑️ Delete backend service and detach NEG

##### 🔧 URL Map Management

- `gcloud-compute-engine-url-map-create` — 🗺️ Create URL map to route traffic to backend
- `gcloud-compute-engine-url-map-delete` — 🗑️ Delete URL map

##### 🔐 Target Proxies (HTTP / HTTPS)

- `gcloud-compute-engine-target-https-proxy-and-attach-ssl-certificate` — 🔐 Create HTTPS target proxy and attach SSL cert
- `gcloud-compute-engine-target-https-proxy-delete` — 🗑️ Delete target HTTP/HTTPS proxies

##### 🚦 Global Forwarding Rules

- `gcloud-compute-engine-global-forwarding-rule-create` — 🚦 Create global forwarding rules for HTTP/HTTPS
- `gcloud-compute-engine-global-forwarding-rule-delete` — 🗑️ Delete forwarding rules

> DevKit is your all-in-one, scriptable Swiss Army knife for macOS development environments. Automate everything — and focus on building.
