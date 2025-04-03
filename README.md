# 🧰 DevKit CLI

**DevKit CLI** is a modular, Zsh-based toolkit that automates the setup, configuration, and maintenance of your macOS development environment.

Whether you’re spinning up a new machine or maintaining an existing one, DevKit makes it effortless to install SDKs, configure tools, manage shell environments, and keep everything up to date — from Homebrew and Flutter to Firebase, Docker, Python, Node.js, Postgres, and beyond.

---

## 🚀 Features

DevKit is more than just a shell script — it’s a full developer environment manager designed for macOS power users. Here’s what it brings to the table:

- **🔧 One-Line Environment Setup**  
  devkit-pc-setup walks you through a full system bootstrap: CLI tools, SDKs, dev apps, shell configuration — personalized and persistent.

- **♻️ Smart Updater for Your Stack**  
  devkit-pc-update upgrades everything in one sweep: Homebrew, Flutter, Firebase, gcloud, NPM, CocoaPods, App Store apps, system updates — all logged.

- **🧪 Full Environment Diagnostics**  
  devkit-doctor checks health across languages, tools, SDKs, mobile stacks, and cloud SDKs — and surfaces actionable fixes.

- **🔍 Tool Version Checker**  
  devkit-check-tools reports what’s installed, what’s outdated, and what’s missing — with clean, emoji-labeled output.

- **🌐 Cloud & Mobile Ready**  
  Built-in support for Firebase, Google Cloud, Flutter, Dart, Android SDK, Postgres, Docker, CocoaPods, and more — no extra wiring.

- **🧠 Smart Prompts & Safe Defaults**  
  Interactive prompts with --quiet overrides for automation. Clean fail-safes, confirmations, and shell-safe user input.

- **🧩 Modular Architecture**  
  Each tool lives in its own modules/[tool] folder — easy to extend, maintain, or override with your own logic.

- **📜 Self-Updating CLI**  
  devkit-update syncs your CLI with the latest version from GitHub and reloads it without needing to restart your terminal.

- **📚 Auto-Logging & Audit Trail**  
  All setup, updates, and diagnostics are logged under ~/devkit/logs with timestamped filenames — great for debugging or history.

- **💻 Mac-First System Utilities**  
  Includes aliases for flushing DNS, checking public IP, restarting Terminal, getting macOS version, and more macOS-specific goodness.

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

## 🧩 App Support

DevKit helps manage a wide range of tools:

- 🛠️ System & Languages: Git, Zsh, Java, Python, Node.js, Dart, Ruby
- 📦 Package Managers: Homebrew, NPM, pip, gem, MAS
- 🧰 Dev Tools: VS Code, Android Studio, Xcode, Flutter, CocoaPods
- ☁️ Cloud & Deploy: Firebase CLI, Google Cloud SDK, Docker
- 🐘 Databases: PostgreSQL
- 🎨 Misc: WeasyPrint, ccache, expect

---

## 🛠️ Core Commands

### 🔧 `devkit-pc-setup`

🧰 Bootstraps your entire dev environment — guided, interactive, and persistent.

- 👤 Asks for your name, email, and app/tool preferences
- 📦 Installs:
- Git, Homebrew (formulas + casks)
- MAS apps, NPM packages, Xcode, Flutter SDK
- 🧠 Uses helpers: \_confirm-or-abort, \_check-software-updates, devkit-settings-setup
- 🖥️ Prompts you to launch & configure downloaded GUI apps (e.g., VS Code)
- 🗂 Logs everything to: ~/devkit/logs/devkit/setup/[timestamp].log

```bash
devkit-pc-setup
```

### 🔄 `devkit-pc-update`

♻️ Runs a full system + dev stack update in one command.

- 📦 Updates:
- 🧪 Homebrew formulas & casks
- 🐍 Python (pip3)
- ☁️ Google Cloud CLI
- 💙 Flutter SDK
- 🟢 Node.js & NPM
- 🍎 CocoaPods
- 🧠 Rosetta 2
- 🛍️ App Store apps via mas-cli
- 🛠️ DevKit itself (devkit-update)
- 🖥 macOS system software
- 🧾 Uses \_log-update-step for clean progress logs
- 🗂 Logs everything to: ~/devkit/logs/devkit/update/[timestamp].log

```bash
devkit-pc-update
```

### 📋 `devkit-check-tools`

🔍 Prints installed versions of all essential dev tools — organized by category with emoji labels.

- ✅ Checks:
  - 💻 Shell & system tools
  - 🧰 Dev tools & editors
  - ⚙️ Languages & package managers
  - 📱 Mobile SDKs
  - ☁️ Cloud CLIs
  - 🗄️ Databases
- ⚠️ Warns about missing tools with suggestions

```bash
devkit-check-tools
```

### 🧪 `devkit-doctor`

🩺 Runs full diagnostics on your environment — catch problems before they catch you.

- 📋 Starts with devkit-check-tools
- 🧠 Validates config via:
- homebrew-doctor, xcode-doctor, git-doctor, firebase-doctor, etc.
- 🐚 Verifies shell + $PATH
- 🗂 Logs output to: ~/devkit/logs/devkit/doctor/[timestamp].log

```bash
devkit-doctor
```

### 📥 `devkit-update`

🚀 Self-updates DevKit from GitHub if new changes exist.

- 🔍 Compares local commit vs origin/main
- ✅ Offers to pull changes & reloads CLI
- 📦 Auto-installs if DevKit is missing
- 💡 No external dependencies required

```bash
devkit-update
```

## ⚙️ Settings & Initialization

### `devkit-settings-setup`

🧰 devkit-settings-setup

📋 Interactive onboarding flow to personalize your DevKit setup.

- 👤 Prompts for:
- Full name & email
- Preferred installs from:
- 🛍️ Mac App Store (MAS)
- 🍺 Homebrew Casks
- 🧪 Homebrew Formulas
- 📝 Saves all preferences to: ~/devkit/.settings
- 🔄 Used automatically by devkit-pc-setup

```bash
devkit-settings-setup
```

### `devkit-is-setup`

🔎 Quick system check to ensure all critical tools are installed.

- Verifies presence of:
  - ⚙️ Git, Zsh, Node, NPM, Python, Java
  - 🐳 Docker, ☁️ GCloud, 🔥 Firebase
  - 💙 Flutter, 🍎 CocoaPods, 🐘 Postgres, and more
  - ✅ Returns 0 if everything is ready
  - 🔇 Add --quiet to suppress output (for scripts)

```bash
devkit-is-setup [--quiet]
```

---

## 🍺 Homebrew Management

DevKit automates Homebrew setup, cleanup, and package installation based on your preferences.

### 🧰 Core Homebrew Commands

- `homebrew-setup` — Full setup: installs Homebrew, saved packages, and prunes extras
- `homebrew-install` — Installs Homebrew if not already installed
- `homebrew-save-packages` — Saves current installed formulae and casks to file
- `homebrew-install-packages` — Reinstalls from saved lists
- `homebrew-install-from-settings` — Installs packages based on `~/.settings`
- `homebrew-prune-packages` — Removes packages not in saved files or settings
- `homebrew-maintain` — Runs `brew doctor`, update, upgrade, cleanup
- `homebrew-doctor` — Checks if Homebrew is healthy
- `homebrew-list-packages` — Lists all currently installed Homebrew packages

These commands are used internally by DevKit setup/update, but can also be used standalone.

---

## 🔧 Git Configuration

DevKit ensures your Git environment is properly set up with global configurations and helpful defaults.

### 🛠 Git Commands

- `git-setup` — Configure Git global user info and preferences (runs automatically during setup)
- `git-doctor` — Diagnose Git installation, user config, SSH key, and GitHub connectivity

### 🧩 Git Alias

- `git-open-settings` — Open global Git config in VS Code

---

## 🍎 Xcode & CLI Tools

DevKit automates macOS dev tools setup and ensures Xcode is ready for iOS/macOS development.

### 🛠 Xcode Commands

- `xcode-setup` — Install updates, accept Xcode license, setup CocoaPods and CLI tools
- `xcode-simulator-first-launch` — Prepares Simulator and platform support for first use
- `xcode-doctor` — Diagnose issues with Xcode installation, simulators, and Rosetta

---

## 🐚 Zsh Shortcuts

DevKit includes useful aliases to manage your Zsh shell quickly:

- `zsh-reload` — Reload your `.zshrc` configuration
- `zsh-reset` — Restart your Zsh shell session
- `zsh-edit` — Open `.zshrc` in VS Code
- `zsh-which` — Show the current shell path

---

## 🐍 Python Environment & Pip Management

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

## 🐘 PostgreSQL Management

DevKit provides powerful helpers for PostgreSQL setup, diagnostics, and local development workflows.

### 🛠 PostgreSQL Setup & Connection

- `postgres-setup` — Starts PostgreSQL and creates the `postgres` superuser if needed
- `postgres-connect` — Securely connects using env vars or interactive prompt
- `postgres-password-validation` — Validates current connection credentials

### 🔍 PostgreSQL Diagnostics

- `postgres-doctor` — Checks installation, running service, and login capability

### 🗃️ Database Operations

- `postgres-database-list` — Lists all system and user databases
- `postgres-database-create` — Interactively creates a new database (with overwrite prompt)
- `postgres-database-delete` — Interactively drops a database (with safety checks)

### 🧩 PostgreSQL Alias

- `devkit-postgres-restart` — Restart PostgreSQL service via Homebrew

---

## 📦 npm Package Management

DevKit includes tooling to back up, restore, prune, and repair global npm packages — perfect for maintaining a clean Node.js environment.

### 🛠 npm Commands

- `npm-setup` — Full setup: prune unused and install saved packages
- `npm-save-packages` — Save currently installed global packages to a file
- `npm-install-packages` — Install global packages from saved list
- `npm-uninstall-packages` — Uninstall all saved packages
- `npm-prune-packages` — Uninstall packages not found in the saved list (with prompts)
- `npm-repair` — Reinstall Node, clean, and restore packages
- `npm-list-packages` — Show globally installed npm packages
- `npm-doctor` — Diagnose and validate npm & Node.js installation

---

## 🛒 Mac App Store (mas-cli) Integration

DevKit automates installation and maintenance of Mac App Store applications using `mas`.

### 🛠 mas Commands

- `mas-setup` — Full setup: installs saved and selected apps, then applies updates
- `mas-save-apps` — Save currently installed App Store apps (filters out cask-preferred)
- `mas-install-apps` — Install apps from saved list
- `mas-install-from-settings` — Install apps based on `.settings` flags
- `mas-maintain` — Check for updates and upgrade installed MAS apps
- `install-if-missing <name> <id>` — Installs app only if not already installed

---

## 🔐 GitHub SSH & Automation Tools

DevKit includes powerful GitHub utilities to manage SSH keys, simplify Git workflows, and automate branching, pushing, and tagging.

### 🗝️ SSH Key Utilities

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

## 🐳 Docker Utilities

DevKit offers convenient functions to manage Docker Desktop, containers, images, and debug your environment.

### 🧰 Docker Daemon Control

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

### 🏗️ Build Tools

- `docker-build <image_name>` — Build a Docker image from the current directory

## 🧩 Handy Aliases

These built-in aliases provide quick access to system info and common tasks:

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

## 🌐 Django Utilities

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
