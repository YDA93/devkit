# 🧰 DevKit CLI

**DevKit** is a comprehensive automation toolkit specifically designed for macOS developers working primarily with Django and Flutter applications, particularly those deploying to Google Cloud Platform. It streamlines the setup, configuration, and deployment processes, allowing developers to focus entirely on coding rather than managing their development environment.

> ⚙️ Built for Mac pros, automation fans, and dev teams who want to skip the setup pain and jump straight to building.

---

## Who is it for?

- **macOS developers** using Django and Flutter
- Teams deploying apps to **Google Cloud Platform**
- Anyone who wants fast, reproducible environments and one-command deployments

## Why DevKit?

- ✅ **One-command setup:** Get your full dev environment running instantly.
- ✅ **Easy updates:** Keep tools and packages fresh with a single command.
- ✅ **Cloud made simple:** Seamlessly deploy Django apps to GCP, with full teardown and update flows.

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

Your everyday essentials — the main commands that do the heavy lifting:

- **⚙️ devkit-pc-setup**  
  Complete macOS development environment setup: installs tools like Homebrew, Python, Node.js, Flutter, Docker, GCP SDK, and more.
- **🔄 devkit-pc-update**  
  One command to update system apps and dev tools: brew, Python packages, Node.js, Flutter, Docker, GCP SDK, and App Store apps.
- **☁️ gcloud-project-django-setup**  
  Deploy your Django project to Google Cloud Platform using environment variables. Builds, provisions, and deploys your cloud services in one step.
- **🚢 gcloud-project-django-update**  
  Push updates to your Django app on GCP. Rebuilds containers, syncs cloud resources, and applies migrations seamlessly.
- **🗑️ gcloud-project-django-teardown**  
  Cleanly tears down your Django cloud environment. Deletes Cloud Run services, databases, buckets, and all associated GCP resources.

### 🧩 Helper Utilities (Optional, On-Demand)

Extra tools to make your development flow smoother. Use them when you need them!

- **🖥️ System Utilities**
  Network diagnostics, flush DNS, restart Mac, clean up cache, and more quick system commands.
- **🍺 Homebrew & Package Management**
  Install, update, and clean up brew packages. Back up and restore your development package list.
- **🧩 Git & GitHub Shortcuts**
  Configure Git, manage SSH keys, sync branches, push tags, and automate repository tasks.
- **🐳 Docker Controls**
  Start/stop Docker, clean containers and images, inspect logs, and run interactive container sessions.
- **🐍 Python & Django Helpers**
  Manage virtual environments, install Python dependencies, and open Django shells with environment variables preloaded.
- **📱 Flutter & Firebase Tools**
  Automate Flutter tasks: asset generation, build runners, Firebase setup, cache clearing, and mobile platform maintenance.
- **🌐 Google Cloud Operations**
  Advanced GCP commands: manage Cloud SQL, handle secrets, sync Cloud Scheduler jobs, deploy App Engine services, and more.

---

## 🚀 Installation Steps

- **🔧 Requirements**
  - macOS
  - Zsh shell
  - Git
  - Internet access (for installs and updates)

Install DevKit by cloning the repository and running the installer:

- **1. Clone the repository to your Mac (e.g., into ~/devkit)**

  - ```bash
    git clone https://github.com/YDA93/devkit.git ~/devkit
    ```

- **2. Run the installer script**

  - ```bash
    cd ~/devkit
    zsh install.zsh
    ```

This will set up DevKit on your system. The installer may prompt you for some info (like your name, email, and preferences) and then install all necessary tools.  
Once the installer finishes, DevKit’s commands will be available in your shell (you might need to open a new terminal session or source your shell config if instructed). Now you’re ready to use the DevKit CLI.

---

## 📚 Documentation

Explore detailed guides for each tool:

- [⚙️ DevKit CLI](./docs/devkit.md)
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
