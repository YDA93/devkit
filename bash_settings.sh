# Update System and Packages
update_system_and_packages() {
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
        sudo npm install -g npm@latest
        sudo npm-check -u
        sudo npm audit fix --force
    }
    update_package "NPM and its dependencies" pass_commands

    # Firebase CLI
    pass_commands(){
        sudo npm install -g firebase-tools
        sudo npm audit fix --force
    }
    update_package "Firebase CLI" pass_commands

    # Rosetta
    pass_commands(){
        sudo softwareupdate --install-rosetta --agree-to-license
    }
    update_package "Rosetta" pass_commands
    
    # Cocoapods
    pass_commands(){
        sudo gem update
        sudo gem update cocoapods
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
        sudo softwareupdate -ia --verbose
    }
    update_package "macOS" pass_commands
}

# Flutter
alias flutter-clean='flutter clean && flutter pub upgrade && flutter pub outdated && flutter pub upgrade --major-versions'
alias flutter-dart-fix='dart fix --apply'
alias flutter-repair-cache='flutter pub cache repair'
alias flutter-update-ios-pods='cd ios && rm Podfile.lock && pod install --repo-update && flutter-clean'
alias flutter-build-android='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'
alias flutter-build-ios='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-runner='flutter packages pub run build_runner build --delete-conflicting-outputs'

# Django
alias django-run-server='python manage.py runserver 0.0.0.0:8000'
alias django-local='export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-dev='export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-prod='export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-env-new="python -m venv venv && source venv/bin/activate"
alias django-env-activate='source venv/bin/activate'
alias django-pip-install-prod='pip install -r requirements.txt'
alias django-pip-install-test='pip install -r requirements-test.txt'
alias django-pip-install-all='pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='pip freeze > requirements.txt'

# FeCare
alias fecare-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'
alias code-fecare-django='code Desktop/dev/fecare-django/'
alias code-fecare-flutter='code Desktop/dev/fecare_flutter/'

# FeSale
alias fesale-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
alias code-fesale-django='code Desktop/dev/fesale-django/'
alias code-fesale-flutter='code Desktop/dev/fesale_flutter/'
alias fesale-build='gcloud builds submit --config cloudmigrate.yaml --substitutions _INSTANCE_NAME=fesale-cloud,_REGION=europe-west3'
alias fesale-deploy='gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service --add-cloudsql-instances fe-sale:europe-west3:fesale-cloud --allow-unauthenticated'
alias fesale-redeploy='gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service'
alias fesale-redeploy-build='gcloud builds submit --config cloudmigrate.yaml --substitutions _INSTANCE_NAME=fesale-cloud,_REGION=europe-west3 && gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service'

# Replace Python3 to Python
alias python='python3'
alias pip3='pip'

# Brew Path
export PATH=/opt/homebrew/bin:$PATH

# Flutter Path
export PATH="$PATH:/Users/yousefalmutairi/flutter/bin"

# Java Path
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/yousefalmutairi/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# The next line updates PATH for the Google Cloud SDK.
source '/Users/yousefalmutairi/google-cloud-sdk/path.zsh.inc'
# The next line enables bash completion for gcloud.
source '/Users/yousefalmutairi/google-cloud-sdk/completion.zsh.inc'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Latest Python Path
export PATH="$(brew --prefix)/opt/python@3/libexec/bin:$PATH"