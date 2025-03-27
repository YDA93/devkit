# 🚀 Run Docker daemon startup once per login session
if ! pgrep -f 'Docker.app' >/dev/null && ! docker info &>/dev/null; then
    docker_daemon_start --quiet
fi

# ⏳ Starts Docker silently (with optional --quiet)
function docker_daemon_start() {
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
function docker_daemon_restart() {
    echo "♻️ Restarting Docker Desktop..."
    osascript -e 'quit app "Docker"'
    sleep 2
    open -a Docker
    docker_daemon_start
}

# 🔹 Opens the Docker Desktop GUI
function docker_open_desktop() {
    echo "🔹 Opening Docker Desktop..."
    open -a Docker
}

# 🛑 Kills all running Docker containers
function docker_kill_all() {
    echo "🛑 Killing all running Docker containers..."
    docker ps -q | xargs -r docker kill
}

# 🧹 Removes stopped containers, unused images, volumes, and networks
function docker_clean_all() {
    echo "🧹 Cleaning up Docker..."
    docker system prune -af --volumes
    echo "✅ Docker cleaned"
}

# 📋 Shows Docker and Docker Compose versions
function docker_show_versions() {
    echo "🐳 Docker CLI: $(docker --version | cut -d ' ' -f 3 | tr -d ',')"
    echo "🔧 Compose:    $(docker compose version --short 2>/dev/null || echo 'not installed')"
}

# 📦 Lists all Docker containers (running and stopped)
function docker_list_containers() {
    echo "📦 All Docker containers:"
    docker ps -a --format "table {{.ID}}\t{{.Status}}\t{{.Names}}\t{{.Image}}"
}
# 🟢 Lists only running Docker containers
function docker_list_running() {
    echo "🟢 Running Docker containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
}
# 🖼️ Lists all Docker images
function docker_list_images() {
    echo "🖼️ Docker images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
}
# 📁 Lists all Docker volumes
function docker_list_volumes() {
    echo "📁 Docker volumes:"
    docker volume ls
}
# 🌐 Lists all Docker networks
function docker_list_networks() {
    echo "🌐 Docker networks:"
    docker network ls
}

# 🔍 Shows detailed info about a specific container
# 📥 Usage: docker_inspect_container <container_name_or_id>
function docker_inspect_container() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: docker_inspect_container <container_name_or_id>"
        return 1
    fi

    docker inspect "$1"
}

# 🔎 Shows logs for a specific container
# 📥 Usage: docker_logs <container_name_or_id>
function docker_logs() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: docker_logs <container_name_or_id>"
        return 1
    fi

    docker logs -f "$1"
}

# 🚪 Opens a shell inside a running container
function docker_shell() {
    docker exec -it "$1" /bin/sh
}

# 🏗️ Builds a Docker image from current directory
function docker_build() {
    docker build -t "$1" .
}
