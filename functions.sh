# Update Software and Packages
update_software_and_packages() {
    update_package(){
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
    pass_commands(){
        brew update
        brew upgrade
        brew autoremove
        brew cleanup
    }
    update_package "Brew and its packages" pass_commands

    # gcloud
    pass_commands(){
        gcloud components update
    }
    update_package "gcloud CLI" pass_commands

    # Flutter
    pass_commands(){
        flutter upgrade
        flutter doctor -v
    }
    update_package "Flutter" pass_commands

    # NPM
    pass_commands(){
        npm install -g npm@latest
        sudo npm-check -u
        npm audit fix --force
    }
    update_package "NPM and its dependencies" pass_commands

    # Firebase CLI
    pass_commands(){
        npm install -g firebase-tools
        npm audit fix --force
    }
    update_package "Firebase CLI" pass_commands

    # Rosetta
    pass_commands(){
        softwareupdate --install-rosetta --agree-to-license
    }
    update_package "Rosetta" pass_commands
    
    # Cocoapods
    pass_commands(){
        gem update --system
        gem update cocoapods
        gem cleanup
    }
    update_package "Gems and Cocoapods" pass_commands

    # App Store
    pass_commands(){
        mas outdated
        mas upgrade
    }
    update_package "App Store apps" pass_commands

    # macOS
    pass_commands(){
        softwareupdate -ia --verbose
    }
    update_package "macOS" pass_commands
}
