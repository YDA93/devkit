# DevKit CLI Documentation

## 📑 Table of Contents

- [🚀 Core Workflow (Run these — they handle everything)](#-core-workflow-run-these--they-handle-everything)
- [💻 System Utilities](#-system-utilities)
- [🧩 Optional Helpers & Utilities](#-optional-helpers--utilities)
  - [🔍 Diagnostics & Updates](#-diagnostics--updates)
  - [🔧 Configuration & Environment Checks](#-configuration--environment-checks)

## 🚀 Core Workflow (Run these — they handle everything)

These commands handle your primary development setup and maintenance:

- 🔧 `devkit-pc-setup` — 🧰 Bootstraps your entire dev environment: prompts for your details, installs tools (Git, Homebrew, MAS apps, NPM, Xcode, Flutter), uses helpers, guides GUI app setup.
- 🔄 `devkit-pc-update` — ♻️ Runs full system and dev stack updates: Homebrew, Python, Google Cloud CLI, Flutter, Node.js, CocoaPods, Rosetta 2, MAS apps, DevKit itself.
- 🧪 `devkit-doctor` — 🩺 Runs full environment diagnostics: starts with devkit-check-tools, validates tools like Homebrew, Xcode, Git, Firebase, verifies shell & $PATH.

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

## 🧩 Optional Helpers & Utilities

🧩 These are optional — they are usually called automatically by the core commands.

### 🔍 Diagnostics & Updates

- 📋 `devkit-check-tools` — 🔍 Prints installed versions of essential dev tools, covering shell, dev tools, languages, mobile SDKs, cloud CLIs, databases, and warns about missing tools with suggestions.
- 📥 `devkit-update` - 🚀 Self-updates DevKit from GitHub by comparing local vs origin/main, auto-installs if missing, reloads CLI, and requires no external dependencies.

### 🔧 Configuration & Environment Checks

- 🧰 `devkit-settings-setup` — 📋 Interactive onboarding to personalize DevKit: prompts for name, email, install preferences (MAS, Homebrew Casks & Formulas), saves to ~/devkit/.settings, and runs automatically during setup.
- 🔎 `devkit-is-setup` — ✅ Quick system check to verify critical tools (Git, Zsh, Node, Python, Java, Docker, GCloud, Firebase, Flutter, CocoaPods, Postgres), with optional --quiet for scripts.
