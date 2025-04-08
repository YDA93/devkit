# 🐳 Docker

DevKit includes handy Docker utilities to manage Docker Desktop, containers, images, and debug your environment with ease.

## 📑 Table of Contents

- [🧰 Daemon Control](#-daemon-control)
- [🧹 Cleanup & Maintenance](#-cleanup--maintenance)
- [📋 Listing Tools](#-listing-tools)
- [🔍 Debugging & Interaction](#-debugging--interaction)
- [🔨 Build Tools](#-build-tools)

---

## 🧰 Daemon Control

- **`docker-daemon-start [--quiet|-q]`** — Start Docker and wait until it's ready.
- **`docker-daemon-restart`** — Restart Docker Desktop.

---

## 🧹 Cleanup & Maintenance

- **`docker-kill-all`** — Kill all running containers.
- **`docker-clean-all`** — Clean up unused containers, images, volumes, and networks.
- **`docker-show-versions`** — Show Docker and Docker Compose versions.

---

## 📋 Listing Tools

- **`docker-list-containers`** — List all containers (running and stopped).
- **`docker-list-running`** — Show only running containers.
- **`docker-list-images`** — List all Docker images.
- **`docker-list-volumes`** — Show all Docker volumes.
- **`docker-list-networks`** — List all Docker networks.

---

## 🔍 Debugging & Interaction

- **`docker-inspect-container <name|id>`** — Inspect detailed container metadata.
- **`docker-logs <name|id>`** — Stream logs from a container.
- **`docker-shell <name|id>`** — Open an interactive shell inside a container.

---

## 🔨 Build Tools

- **`docker-build <image_name>`** — Build an image from the current directory.

---

> 🚀 Pro tip: Most DevKit Docker commands include helpful logging and smart defaults to streamline your workflow.
