# 🧰 DevKit CLI

**DevKit** is a powerful automation toolkit for macOS developers — especially teams building Django and Flutter apps and deploying to Google Cloud Platform.  
It streamlines setup, configuration, and deployment so you can spend less time fixing environments and more time shipping code.

> ⚙️ Built for Mac pros, automation fans, and dev teams who want to skip the setup pain and jump straight to building.

---

## Who is it for?

- **macOS developers** using Django, Flutter, and GCP
- Teams needing fast, reproducible environments
- Anyone who wants one-command setup and deployment automation

## Why DevKit?

- ✅ **One-command setup:** Instantly bootstrap your entire dev environment.
- ✅ **Effortless updates:** Keep everything fresh with a single command.
- ✅ **Cloud made simple:** Automate Django deployment to Google Cloud Platform — build, push, migrate, and manage cloud services.

---

## 📑 Table of Contents

- [🧰 DevKit CLI](#-devkit-cli)
- [Who is it for?](#who-is-it-for)
- [Why DevKit?](#why-devkit)
- [✨ Features](#-features)
- [🚀 Installation Steps](#-installation-steps)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Features

DevKit CLI is packed with powerful commands, organized into core workflows and optional helper utilities to automate your development and deployment processes.

### 🚀 Core Automation Commands (Primary)

Your everyday essentials — the primary commands that do the heavy lifting:

- **⚙️ devkit-pc-setup**  
  Complete macOS development environment setup: Homebrew, Python, Node.js, Flutter, Docker, GCP SDK, and more.
- **🔄 devkit-pc-update**  
  One command to update system apps and dev tools: Homebrew, Python, Node.js, Flutter, Docker, GCP SDK, and App Store apps.
- **☁️ gcloud-project-django-setup**  
  Deploy your Django project to Google Cloud Platform — builds, provisions, and deploys services in one step.
- **🚢 gcloud-project-django-update**  
  Push updates to your Django app on GCP, rebuild containers, sync resources, and apply migrations.
- **🗑️ gcloud-project-django-teardown**  
  Cleanly tear down your Django cloud environment — Cloud Run, databases, buckets, and more.

### 🧩 Optional Helper Utilities

Handy tools to make your development flow smoother — use them as needed!

- **🖥️ System Utilities:** Network diagnostics, flush DNS, restart Mac, clean cache, and more.
- **🍺 Homebrew Management:** Install, update, prune, and backup Homebrew packages.
- **🐙 Git & GitHub Shortcuts:** Configure Git, manage SSH keys, sync branches, push tags, and automate workflows.
- **🐳 Docker Controls:** Start/stop Docker, clean containers and images, inspect logs, and shell into containers.
- **🐍 Python & Django Helpers:** Manage virtual environments, install dependencies, and open Django shells.
- **📱 Flutter & Firebase Tools:** Automate Flutter assets, builds, Firebase setup, and cache clearing.
- **🌐 Google Cloud Operations:** Manage Cloud SQL, secrets, Cloud Scheduler, App Engine, and more.

---

## 🚀 Installation Steps

- **🔧 Requirements**

  Before you begin, make sure you have the following:

  - macOS
  - Zsh shell
  - Git
  - Internet connection (for downloading and installing tools)

- **🛠️ Quick Install**

  Just run this one-liner in your terminal:

  - ```bash
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/YDA93/devkit/main/install.zsh)"
    ```

- **⚙️ What Happens Next**

  The installer will automatically:

  - Clone the DevKit repository to ~/devkit
  - Check for Oh My Zsh and install it if needed
  - Update your .zshrc to include DevKit configurations
  - Prompt you to enter setup details (name, email, preferences)
  - Install all required development tools

  > 💡 No manual steps required — just run and go!

---

## 📚 Documentation

Explore detailed guides for each tool:

- [⚙️ DevKit (Main)](./docs/devkit.md)
- [🐍 Python](./docs/python.md)
- [📱 Flutter](./docs/flutter.md)
- [🐳 Docker](./docs/docker.md)
- [☁️ Google Cloud Platform (GCP)](./docs/gcloud.md)
- [🚀 Django Project](./docs/django.md)
- [🍺 Homebrew](./docs/homebrew.md)
- [🔧 Xcode](./docs/xcode.md)
- [🐙 Git](./docs/git.md)
- [🧩 GitHub](./docs/github.md)
- [📦 NPM](./docs/npm.md)
- [💻 PostgreSQL](./docs/postgresql.md)
- [🍎 Mac App Store (mas)](./docs/mas.md)
- [🐚 Zsh Shell](./docs/zsh.md)

---

## 🤝 Contributing

Contributions are welcome!
Open an issue or submit a pull request if you have improvements, bug fixes, or ideas.

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---

> DevKit is your all-in-one, scriptable Swiss Army knife for macOS development environments. Automate everything — and focus on building.
