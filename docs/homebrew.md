# 🍺 Homebrew

DevKit automates Homebrew setup, cleanup, and package installation based on your preferences.

## 📑 Table of Contents

- [🍺 Homebrew](#-homebrew)
  - [🔧 Setup & Initialization](#-setup--initialization)
  - [📦 Package Management](#-package-management)
  - [🧹 Maintenance & Cleanup](#-maintenance--cleanup)
  - [🩺 Diagnostics & Health](#-diagnostics--health)

## 🔧 Setup & Initialization

- `homebrew-setup` — Full setup: Full setup routine: installs Homebrew, prunes unlisted packages, restores saved packages, and performs maintenance.
- `homebrew-install` — Installs Homebrew if it’s not already installed. Verifies Homebrew is working afterward.

## 📦 Package Management

- `homebrew-save-packages` — Saves your currently installed formulae and casks to files. Useful for backups or sharing your setup.
- `homebrew-install-packages` — Installs formulae and casks from your saved package lists.
- `homebrew-install-from-settings` — Installs formulae and casks based on your .settings file preferences (y-marked entries).
- `homebrew-prune-packages` — Uninstalls any Homebrew packages not listed in your saved package files or .settings. Prompts before removal.
- `homebrew-list-packages` — Lists all currently installed Homebrew formulae and casks.

## 🧹 Maintenance & Cleanup

- `homebrew-maintain` — Updates, upgrades, and cleans Homebrew. Also runs a health check and verifies packages.
- `homebrew-clean` - Performs cleanup: removes unused dependencies, old versions, and verifies installed packages.

## 🩺 Diagnostics & Health

- `homebrew-doctor` — Runs Homebrew diagnostics, checks for issues, and reports outdated packages.
