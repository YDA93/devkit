# 🧰 DevKit

DevKit is your all-in-one toolkit for setting up, maintaining, and troubleshooting your macOS development environment.

It automates the boring stuff — from Homebrew, Git, and Node.js to Flutter, Docker, PostgreSQL, and more — so you can focus on building, not fixing.

Run a full setup, update your stack anytime, and keep your dev machine running smooth with built-in diagnostics and helpers.

## 📑 Table of Contents

- [🚀 Core Workflow](#-core-workflow)
- [💻 System Utilities](#-system-utilities)
- [🧩 Helpers & Optional Tools](#-helpers--optional-tools)
  - [🔍 Diagnostics & Updates](#-diagnostics--updates)
  - [🔧 Configuration & Environment Checks](#-configuration--environment-checks)

---

## 🚀 Core Workflow

Your main setup and maintenance commands:

- 🔧 **`devkit-pc-setup`** — Full environment bootstrap: prompts for your details, installs core tools (Git, Homebrew, MAS apps, Node.js, Xcode, Flutter), and guides app setup.
- 🔄 **`devkit-pc-update`** — Update system and dev stack: Homebrew, Python, Google Cloud SDK, Flutter, Node.js, CocoaPods, MAS apps, Rosetta 2, and DevKit itself.
- 🧪 **`devkit-doctor`** — Run a full environment check: verifies critical tools, configurations, and $PATH health.

---

## 💻 System Utilities

Quick system-level helpers:

- 🌐 **`devkit-pc-ip-address`** — Show local Wi-Fi IP
- 🌍 **`devkit-pc-public-ip`** — Show public IP
- 📡 **`devkit-pc-ping`** — Test internet (Google DNS)
- 📴 **`devkit-pc-shutdown`** — Shut down Mac
- 🔁 **`devkit-pc-restart`** — Restart Mac
- 🧹 **`devkit-pc-dns-flush`** — Flush DNS cache
- 🧼 **`devkit-pc-clear-cache`** — Clear user/system cache
- 🗑️ **`devkit-pc-empty-trash`** — Empty the trash
- 💽 **`devkit-pc-disk`** — Disk usage summary
- 🔋 **`devkit-pc-battery`** — Battery status
- 📊 **`devkit-pc-stats`** — Top resource usage
- 💻 **`devkit-pc-version`** — macOS version info
- 🐚 **`devkit-shell-info`** — Shell & interpreter info
- 🐚 **`devkit-bash-reset`** — Restart Bash session
- 🔁 **`devkit-terminal-restart`** — Restart Terminal app

---

## 🧩 Helpers & Optional Tools

Mostly auto-called by core commands, but handy for manual use.

### 🔍 Diagnostics & Updates

- 📋 **`devkit-check-tools`** — Print versions of essential tools, warn about missing ones.
- 📥 **`devkit-update`** — Self-update DevKit from GitHub, auto-install latest version.

### 🔧 Configuration & Environment Checks

- 🧰 **`devkit-settings-setup`** — Configure user info and install preferences (MAS apps, Homebrew, etc.).
- 🔎 **`devkit-is-setup`** — Quick check to verify critical tools are ready. Add `--quiet` for scripts.

---

> 🧩 Most helpers run automatically, but you can run them manually for deeper diagnostics or setup.
