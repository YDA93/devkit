# ⏳ Starts Docker silently (with optional --quiet)
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

    $quiet || echo "✅ Docker is now running!"
}

# ♻️ Restarts Docker Desktop and waits for the daemon to be ready
function docker-daemon-restart() {
    echo "♻️  Restarting Docker Desktop..."
    pkill -f Docker
    sleep 2
    docker-daemon-start
}

# 🛑 Kills all running Docker containers
function docker-kill-all() {
    echo "🛑 Killing all running Docker containers..."
    docker ps -q | xargs -r docker kill
}

# 🧹 Removes stopped containers, unused images, volumes, and networks
function docker-clean-all() {
    echo "🧹 Cleaning up Docker..."
    docker system prune -af --volumes
    echo "✅ Docker cleaned"
}

# 📋 Shows Docker and Docker Compose versions
function docker-show-versions() {
    echo "🐳 Docker CLI: $(docker --version | cut -d ' ' -f 3 | tr -d ',')"
    echo "🔧 Compose:    $(docker compose version --short 2>/dev/null || echo 'not installed')"
}

# 📦 Lists all Docker containers (running and stopped)
function docker-list-containers() {
    echo "📦 All Docker containers:"
    docker ps -a --format "table {{.ID}}\t{{.Status}}\t{{.Names}}\t{{.Image}}"
}
# 🟢 Lists only running Docker containers
function docker-list-running() {
    echo "🟢 Running Docker containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
}
# 🖼️ Lists all Docker images
function docker-list-images() {
    echo "🖼️ Docker images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
}
# 📁 Lists all Docker volumes
function docker-list-volumes() {
    echo "📁 Docker volumes:"
    docker volume ls
}
# 🌐 Lists all Docker networks
function docker-list-networks() {
    echo "🌐 Docker networks:"
    docker network ls
}

# 🔍 Shows detailed info about a specific container
# 📥 Usage: docker-inspect-container <container_name_or_id>
function docker-inspect-container() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: docker-inspect-container <container_name_or_id>"
        return 1
    fi

    docker inspect "$1"
}

# 🔎 Shows logs for a specific container
# 📥 Usage: docker-logs <container_name_or_id>
function docker-logs() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: docker-logs <container_name_or_id>"
        return 1
    fi

    docker logs -f "$1"
}

# 🚪 Opens a shell inside a running container
function docker-shell() {
    docker exec -it "$1" /bin/sh
}

# 🏗️ Builds a Docker image from current directory
function docker-build() {
    docker build -t "$1" .
}
