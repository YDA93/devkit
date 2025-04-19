# 🛒 Mac App Store (mas-cli) Integration

DevKit automates the installation and maintenance of Mac App Store applications using `mas`.

No more manual installs — manage your MAS apps like any other package!

## 📑 Table of Contents

- [🔧 Setup & Initialization](#-setup--initialization)
- [📦 Package Management](#-package-management)
- [🧹 Maintenance & Cleanup](#-maintenance--cleanup)

---

## 🔧 Setup & Initialization

- **`mas-setup`** — Full setup: install apps from saved list and `settings.json`, then check for updates.

---

## 📦 Package Management

- **`mas-save-apps`** — Save currently installed MAS apps (skips cask-preferred).
- **`mas-install-apps`** — Install apps from your saved list.
- **`mas-install-from-settings`** — Install apps based on `settings.json` selections.
- **`install-if-missing <name> <id>`** — Install app only if not already installed.

---

## 🧹 Maintenance & Cleanup

- **`mas-maintain`** — Check for updates and upgrade installed MAS apps.

---

> 💡 Tip: Maintain your Mac App Store apps with `mas-maintain` regularly to keep everything fresh.
