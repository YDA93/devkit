# 📦 NPM

DevKit includes tooling to back up, restore, prune, and repair global npm packages — perfect for maintaining a clean Node.js environment.

## 🔧 Setup & Initialization

- `npm-setup` — Full setup: prune unused and install saved packages

## 📦 Package Management

- `npm-save-packages` — Save currently installed global packages to a file
- `npm-install-packages` — Install global packages from saved list
- `npm-uninstall-packages` — Uninstall all saved packages
- `npm-prune-packages` — Uninstall packages not found in the saved list (with prompts)
- `npm-list-packages` — Show globally installed npm packages

## 🩺 Diagnostics & Health

- `npm-repair` — Reinstall Node, clean, and restore packages
- `npm-doctor` — Diagnose and validate npm & Node.js installation
