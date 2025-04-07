# 🐳 Docker

DevKit offers convenient functions to manage Docker Desktop, containers, images, and debug your environment.

## 📑 Table of Contents

- [🐳 Docker](#-docker)
  - [🧰 Daemon Control](#-daemon-control)
  - [🧹 Cleanup & Maintenance](#-cleanup--maintenance)
  - [📋 Listing Tools](#-listing-tools)
  - [🔍 Debugging & Interaction](#-debugging--interaction)
  - [🔨 Build Tools](#-build-tools)

## 🧰 Daemon Control

- `docker-daemon-start [--quiet|-q]` — Start Docker and wait for it to become ready
- `docker-daemon-restart` — Restart Docker Desktop

## 🧹 Cleanup & Maintenance

- `docker-kill-all` — Kill all running containers
- `docker-clean-all` — Remove unused containers, images, volumes, and networks
- `docker-show-versions` — Show Docker and Compose versions

## 📋 Listing Tools

- `docker-list-containers` — Show all containers (running or not)
- `docker-list-running` — Show only running containers
- `docker-list-images` — Show all Docker images
- `docker-list-volumes` — List all Docker volumes
- `docker-list-networks` — List all Docker networks

## 🔍 Debugging & Interaction

- `docker-inspect-container <name|id>` — Show detailed container metadata
- `docker-logs <name|id>` — Tail logs of a running container
- `docker-shell <name|id>` — Open a shell inside a running container

## 🔨 Build Tools

- `docker-build <image_name>` — Build a Docker image from the current directory
