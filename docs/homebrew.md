# 🍺 Homebrew

DevKit automates Homebrew setup, package management, cleanup, and maintenance.

Install, prune, back up, and restore your Homebrew environment with simple, streamlined commands.

## 📑 Table of Contents

- [🔧 Setup & Initialization](#-setup--initialization)
- [📦 Package Management](#-package-management)
- [🧹 Maintenance & Cleanup](#-maintenance--cleanup)
- [🩺 Diagnostics & Health](#-diagnostics--health)

---

## 🔧 Setup & Initialization

- **`homebrew-setup`** — Full setup: install Homebrew, prune unlisted packages, restore saved packages, and maintain.
- **`homebrew-install`** — Install Homebrew if missing and verify installation.

---

## 📦 Package Management

- **`homebrew-save-packages`** — Save current formulae and casks to files for backup or sharing.
- **`homebrew-install-packages`** — Install formulae and casks from saved lists.
- **`homebrew-install-packages-from-settings`** — Install packages based on your `settings.json` file.
- **`homebrew-prune-packages`** — Uninstall packages not in saved lists or settings (with confirmation).
- **`homebrew-list-packages`** — List all currently installed formulae and casks.

---

## 🧹 Maintenance & Cleanup

- **`homebrew-maintain`** — Update, upgrade, and clean Homebrew. Runs health check and verifies packages.
- **`homebrew-clean`** — Remove unused dependencies, old versions, and clean cache.

---

## 🩺 Diagnostics & Health

- **`homebrew-doctor`** — Run Homebrew diagnostics and check for outdated packages.

---

> 🚀 Pro tip: Use `devkit-pc-update` regularly to keep your dev environment healthy and up to date.
