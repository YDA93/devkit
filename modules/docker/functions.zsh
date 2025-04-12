# ------------------------------------------------------------------------------
# 🐳 Docker Daemon Management
# ------------------------------------------------------------------------------

# ⏳ Starts Docker Desktop in the background
# - Waits until the daemon is ready
# - Use --quiet or -q to suppress logs
# 💡 Usage: docker-daemon-start [--quiet|-q]
function docker-daemon-start() {
    local quiet=false

    # Parse flags
    for arg in "$@"; do
        if [[ "$arg" == "--quiet" || "$arg" == "-q" ]]; then
            quiet=true
        fi
    done

    $quiet || echo "⏳ Starting Docker Daemon..."

    # Start Docker silently
    nohup open -a Docker --args --unattended &>/dev/null &
    disown

    # Wait for Docker to become ready
    while ! docker info &>/dev/null; do
        $quiet || echo "⏳ Waiting for Docker to start..."
        sleep 5
    done

    $quiet || _log_success "✅ Docker is now running!"
}

# ♻️ Restarts Docker Desktop
# - Stops all Docker processes and starts Docker again
# 💡 Usage: docker-daemon-restart
function docker-daemon-restart() {
    echo "♻️  Restarting Docker Desktop..."
    pkill -f Docker
    sleep 2
    docker-daemon-start
}

# ------------------------------------------------------------------------------
# 🧼 Docker Cleanup Commands
# ------------------------------------------------------------------------------

# 🛑 Kills all running Docker containers
# 💡 Usage: docker-kill-all
function docker-kill-all() {
    echo "🛑 Killing all running Docker containers..."
    docker ps -q | xargs -r docker kill
}

# 🧹 Removes stopped containers, unused images, volumes, and networks
# 💡 Usage: docker-clean-all
function docker-clean-all() {
    echo "🧹 Cleaning up Docker..."
    docker system prune -af --volumes
    _log_success "✅ Docker cleaned"
}

# ------------------------------------------------------------------------------
# 🧾 Docker Info & Versioning
# ------------------------------------------------------------------------------

# 📋 Displays Docker and Docker Compose versions
# 💡 Usage: docker-show-versions
function docker-show-versions() {
    echo "🐳 Docker CLI: $(docker --version | cut -d ' ' -f 3 | tr -d ',')"
    echo "🔧 Compose:    $(docker compose version --short 2>/dev/null || echo 'not installed')"
}

# ------------------------------------------------------------------------------
# 📦 Docker Listing Utilities
# ------------------------------------------------------------------------------

# 📦 Lists all Docker containers (running and stopped)
# 💡 Usage: docker-list-containers
function docker-list-containers() {
    echo "📦 All Docker containers:"
    docker ps -a --format "table {{.ID}}\t{{.Status}}\t{{.Names}}\t{{.Image}}"
}

# 🟢 Lists only running Docker containers
# 💡 Usage: docker-list-running
function docker-list-running() {
    echo "🟢 Running Docker containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# 🖼️ Lists all Docker images
# 💡 Usage: docker-list-images
function docker-list-images() {
    echo "🖼️ Docker images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
}

# 📁 Lists all Docker volumes
# 💡 Usage: docker-list-volumes
function docker-list-volumes() {
    echo "📁 Docker volumes:"
    docker volume ls
}

# 🌐 Lists all Docker networks
# 💡 Usage: docker-list-networks
function docker-list-networks() {
    echo "🌐 Docker networks:"
    docker network ls
}

# ------------------------------------------------------------------------------
# 🔍 Docker Debugging & Interaction
# ------------------------------------------------------------------------------

# 🔍 Shows detailed info about a specific container
# 💡 Usage: docker-inspect-container <container_id_or_name>
function docker-inspect-container() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: docker-inspect-container <container_name_or_id>"
        return 1
    fi

    docker inspect "$1"
}

# 🔎 Shows logs for a specific container
# 💡 Usage: docker-logs <container_id_or_name>
function docker-logs() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: docker-logs <container_name_or_id>"
        return 1
    fi

    docker logs -f "$1"
}

# 🚪 Opens a shell inside a running container
# 💡 Usage: docker-shell <container_id_or_name>
function docker-shell() {
    docker exec -it "$1" /bin/sh
}

# ------------------------------------------------------------------------------
# 🏗️ Docker Build Tools
# ------------------------------------------------------------------------------

# 🏗️ Builds a Docker image from the current directory
# 💡 Usage: docker-build <image_name>
function docker-build() {
    docker build -t "$1" .
}
