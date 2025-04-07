# 🛒 Mac App Store (mas-cli) Integration

DevKit automates installation and maintenance of Mac App Store applications using `mas`.

## 🔧 Setup & Initialization

- `mas-setup` — Full setup: installs saved and selected apps, then applies updates

## 📦 Package Management

- `mas-save-apps` — Save currently installed App Store apps (filters out cask-preferred)
- `mas-install-apps` — Install apps from saved list
- `mas-install-from-settings` — Install apps based on `.settings` flags
- `install-if-missing <name> <id>` — Installs app only if not already installed

## 🧹 Maintenance & Cleanup

- `mas-maintain` — Check for updates and upgrade installed MAS apps
