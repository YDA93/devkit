# 🐍 Python

DevKit includes helpers to manage Python virtual environments and dependencies with ease.

## 🐍 Virtual Environment Commands

- `python-environment-create` — Creates a new `./venv` and activates it
- `python-environment-activate` — Activates the `./venv` if available
- `python-environment-is-active` — Checks if the current environment is active
- `python-environment-delete` — Deletes the `./venv`
- `python-environment-setup` — Recreates, activates `./venv`, and installs dependencies

## 🐚 Python Shell

- `python-shell [env]` — Activates environment, sets settings, and opens Django shell  
  (supports `local`, `dev`, `prod`, `test`)

## 📦 Pip Dependency Management

- `pip-install [--main|--test]` — Installs dependencies from requirements files
- `pip-update [--main|--test]` — Updates installed packages and regenerates requirements

## 🧩 Python Aliases

- `python` — Points to `python3`
- `pip` — Points to `pip3`
