# 📦 NPM

DevKit includes tools to back up, restore, prune, and repair global npm packages — keeping your Node.js environment clean and consistent.

## 📑 Table of Contents

- [🔧 Setup & Initialization](#-setup--initialization)
- [📦 Package Management](#-package-management)
- [🩺 Diagnostics & Health](#-diagnostics--health)

---

## 🔧 Setup & Initialization

- **`npm-setup`** — Full setup: prune unused packages and install from saved list.

---

## 📦 Package Management

- **`npm-save-packages`** — Save your globally installed packages to a file.
- **`npm-install-packages`** — Install global packages from your saved list.
- **`npm-uninstall-packages`** — Uninstall all saved global packages.
- **`npm-prune-packages`** — Uninstall any global package not found in your saved list (prompts included).
- **`npm-list-packages`** — List all globally installed npm packages.

---

## 🩺 Diagnostics & Health

- **`npm-repair`** — Reinstall Node.js, clean up, and restore global packages.
- **`npm-doctor`** — Diagnose npm and Node.js installation, registry, permissions, and health.

---

> 💡 Tip: Keep your global npm environment tidy by running `npm-save-packages` after installing new global packages!
