# ------------------------------------------------------------------------------
# 🛒 Mac App Store (mas-cli) Utilities
# ------------------------------------------------------------------------------

# 💾 Saves a filtered list of App Store apps (excludes cask-preferred ones)
# 📄 Output: $DEVKIT_MODULES_PATH/mas/apps.txt
# 💡 Usage: mas-save-apps
function mas-save-apps() {
    local output="$DEVKIT_MODULES_PATH/mas/apps.txt"
    mkdir -p "$(dirname "$output")"

    # Cask-preferred keywords (lowercase, no spaces)
    local cask_preferred_keywords=(
        whatsapp onedrive skype zoom postman
        microsoft visualstudiocode pgadmin docker
        chatgpt flutter
    )

    echo "💾 Saving App Store apps to $output"

    mas list | while read -r id name version; do
        local clean_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')

        local skip=false
        for keyword in "${cask_preferred_keywords[@]}"; do
            if [[ "$clean_name" == *"$keyword"* ]]; then
                skip=true
                break
            fi
        done

        $skip || echo "$id  $name"
    done >"$output"

    echo "✅ Saved App Store apps to $output"
}

# 📦 Installs apps listed in apps.txt using mas
# 💡 Usage: mas-install-apps
function mas-install-apps() {
    local input="$DEVKIT_MODULES_PATH/mas/apps.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ App list not found at $input"
        return 1
    fi

    echo "📦 Installing App Store apps from $input"
    while read -r id _; do
        [[ -z "$id" || "$id" =~ ^# ]] && continue
        echo "🛍️  Installing app ID: $id"
        mas install "$id"
    done <"$input"

    echo "✅ App Store apps installed."
}

# 🔄 Updates installed App Store apps via mas
# 💡 Usage: mas-maintain
function mas-maintain() {
    echo "🔍 Checking for App Store updates..."
    mas outdated || return 1
    echo "⬆️  Upgrading App Store apps..."
    mas upgrade || return 1
    echo "✅ App Store apps updated."
}

# ⚙️ Full mas setup: installs saved apps and applies updates
# 💡 Usage: mas-setup
function mas-setup() {
    mas-install-apps || return 1
    mas-maintain || return 1
}
