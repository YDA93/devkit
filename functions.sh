# Update Software and Packages
function update_software_and_packages() {
    function update_package() {
        name=$1 # First Aurgment
        shift   # Remove first aurgment
        echo "--------------------------------------------------"
        echo "Updating $name.."
        echo "--------------------------------------------------"
        $@ # All Aurgments
        echo "--------------------------------------------------"
        echo "$name updated."
        echo "--------------------------------------------------\n"
    }

    # Clear Terminal and run sudo to avoid entering password multiple times
    sudo clear

    # Brew
    function pass_commands() {
        echo -e "Brew doctor: "$(brew doctor)
        echo -e "Brew update: "$(brew update)
        echo -e "Brew upgrade: "$(brew upgrade)
        echo -e "Brew autoremove: "$(brew autoremove)
        echo -e "Brew cleanup: "$(brew cleanup)
    }
    update_package "Brew and its packages" pass_commands

    # gcloud
    function pass_commands() {
        gcloud components update
    }
    update_package "gcloud CLI" pass_commands

    # Flutter
    function pass_commands() {
        flutter upgrade --force
        flutter doctor -v
    }
    update_package "Flutter" pass_commands

    # NPM
    function pass_commands() {
        echo -e "NPM install latest: "$(npm install -g npm@latest)
        sudo npm-check -u
        echo -e "NPM audit fix: "$(npm audit fix --force)
    }
    update_package "NPM and its dependencies" pass_commands

    # Firebase CLI
    function pass_commands() {
        echo -e "Firebase install latest from npm: "$(npm install -g firebase-tools)
        echo -e "NPM audit fix: "$(npm audit fix --force)
    }
    update_package "Firebase CLI" pass_commands

    # Rosetta
    function pass_commands() {
        softwareupdate --install-rosetta --agree-to-license
    }
    update_package "Rosetta" pass_commands

    # Cocoapods
    function pass_commands() {
        echo -e "Gem update system: "$(gem update --system)
        echo -e "Gem update cocoapods: "$(gem update cocoapods)
        echo -e "Gem update ffi: "$(gem update ffi)
        echo -e "Gem cleanup: "$(sudo gem cleanup)
    }
    update_package "Gems and Cocoapods" pass_commands

    # App Store
    function pass_commands() {
        echo -e "Check app store outdated apps: "$(mas outdated)
        echo -e "Update app store apps: "$(mas upgrade)
    }
    update_package "App Store apps" pass_commands

    # macOS
    function pass_commands() {
        softwareupdate -ia --verbose
    }
    update_package "macOS" pass_commands
}

function check_env_variable_exists() {
    # Check if .env file exists
    if [[ ! -f .env ]]; then
        echo "Error: .env file does not exist!"
        return 1
    fi

    local variable_name="$1"
    local file_path="$2"

    # Default to .env if no file_path is provided
    if [ -z "$file_path" ]; then
        file_path=".env"
    fi

    # Check if the variable is set in the given file
    if ! grep -q "${variable_name}=" "$file_path"; then
        echo "Error: ${variable_name} is not set in ${file_path}!"
        return 1
    fi

    # Check if the variable is not just empty
    if grep -q "^${variable_name}=$" "$file_path"; then
        echo "Error: ${variable_name} is set but is empty in ${file_path}!"
        return 1
    fi
}

function update_env_key_value() {
    local key=$1
    local value=$2

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Error: Key or value is not provided!"
        return 1
    fi

    # Update the .env file with the given key and value
    echo "Updating $key value in .env file to $value..."

    # Check if the key exists in the .env file
    if grep -q "^$key=" .env; then
        # Key exists, update its value
        sed -i '' "s/$key=\"[^\"]*\"/$key=\"$value\"/" .env
    else
        # Key doesn't exist, add it to the file
        echo "$key=\"$value\"" >>.env
    fi

    echo "$key updated."
    sleep 2
}

function prompt_confirmation() {
    local message=$1

    # Check if message is provided
    if [ -z "$message" ]; then
        echo "Error: No message provided for confirmation prompt!"
        return 1
    fi

    # Prompt user for confirmation
    while true; do
        echo -n "$message (yes/no): "
        read confirm
        case $confirm in
        [Yy][Ee][Ss])
            return 0
            ;;
        [Nn][Oo])
            echo "Operation canceled."
            return 1
            ;;
        *)
            echo "Please answer yes or no."
            ;;
        esac
    done
}
