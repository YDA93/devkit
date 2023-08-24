# Update Software and Packages
function update_software_and_packages() {
    function update_package(){
        name=$1 # First Aurgment
        shift   # Remove first aurgment
        echo "--------------------------------------------------"
        echo "Updating $name.."
        echo "--------------------------------------------------"
        $@  # All Aurgments
        echo "--------------------------------------------------"
        echo "$name updated."
        echo "--------------------------------------------------\n"
    }

    # Clear Terminal and run sudo to avoid entering password multiple times
    sudo clear
    
    # Brew
    function pass_commands(){
        echo -e "Brew doctor: "$(brew doctor)
        echo -e "Brew update: "$(brew update)
        echo -e "Brew upgrade: "$(brew upgrade)
        echo -e "Brew autoremove: "$(brew autoremove)
        echo -e "Brew cleanup: "$(brew cleanup)
    }
    update_package "Brew and its packages" pass_commands

    # gcloud
    function pass_commands(){
        gcloud components update
    }
    update_package "gcloud CLI" pass_commands

    # Flutter
    function pass_commands(){
        flutter upgrade
        flutter doctor -v
    }
    update_package "Flutter" pass_commands

    # NPM
    function pass_commands(){
        echo -e "NPM install latest: "$(npm install -g npm@latest)
        sudo npm-check -u
        echo -e "NPM audit fix: "$(npm audit fix --force)
    }
    update_package "NPM and its dependencies" pass_commands

    # Firebase CLI
    function pass_commands(){
        echo -e "Firebase install latest from npm: "$(npm install -g firebase-tools)
        echo -e "NPM audit fix: "$(npm audit fix --force)
    }
    update_package "Firebase CLI" pass_commands

    # Rosetta
    function pass_commands(){
        softwareupdate --install-rosetta --agree-to-license
    }
    update_package "Rosetta" pass_commands
    
    # Cocoapods
    function pass_commands(){
        echo -e "Gem update system: "$(gem update --system)
        echo -e "Gem update cocoapods: "$(gem update cocoapods)
        echo -e "Gem update ffi: "$(gem update ffi)
        echo -e "Gem cleanup: "$(gem cleanup)
    }
    update_package "Gems and Cocoapods" pass_commands

    # App Store
    function pass_commands(){
        echo -e "Check app store outdated apps: "$(mas outdated)
        echo -e "Update app store apps: "$(mas upgrade)   
    }
    update_package "App Store apps" pass_commands

    # macOS
    function pass_commands(){
        softwareupdate -ia --verbose
    }
    update_package "macOS" pass_commands
}
