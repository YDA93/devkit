# 🐍 Python

DevKit includes helpers to manage Python virtual environments and dependencies with ease.  
Easily create, activate, and maintain your environment — plus automate requirements updates.

## 📑 Table of Contents

- [🐍 Virtual Environment Commands](#-virtual-environment-commands)
- [🐚 Python Shell](#-python-shell)
- [📦 Pip Dependency Management](#-pip-dependency-management)
- [🧩 Python Aliases](#-python-aliases)

---

## 🐍 Virtual Environment Commands

- **`python-environment-create`** — Creates a new `./venv` and activates it.
- **`python-environment-activate`** — Activates the `./venv` if available.
- **`python-environment-is-active`** — Checks if the current environment is active.
- **`python-environment-delete`** — Deletes the `./venv`.
- **`python-environment-setup`** — Deletes, recreates, activates `./venv`, and installs dependencies.

---

## 🐚 Python Shell

- **`python-shell [env]`** — Activates environment, sets Django settings, and opens the Django shell.  
  _(Supports `local`, `dev`, `prod`, `test`)_

---

## 📦 Pip Dependency Management

- **`pip-install [--main|--test]`** — Installs dependencies from `requirements.txt` and/or `requirements-test.txt`.
- **`pip-update [--main|--test]`** — Updates installed packages and regenerates the pinned requirements files.

---

## 🧩 Python Aliases

- **`python`** — Points to `python3`.
- **`pip`** — Points to `pip3`.

---

> 💡 Tip:  
> Use `python-environment-setup` for a full clean start:  
> fresh environment + dependencies installed.
