alias python='python3' # Replace Python3 to Python
alias pip='pip3' # Replace pip3 to pip

# Flutter Path
export PATH="$PATH:/Users/yousefalmutairi/flutter/bin"

# Latest Python Path
export PATH="$(brew --prefix)/opt/python@3/libexec/bin:$PATH"

# Flutter
alias flutter-clean='flutter clean && flutter pub upgrade && flutter pub outdated && flutter pub upgrade --major-versions'
alias flutter-dart-fix='dart fix --apply'
alias flutter-repair-cache='flutter pub cache repair'
alias flutter-ios-reinstall-podfile='cd ios && rm Podfile.lock && pod install --repo-update && flutter-clean'
alias flutter-build-ios='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-android='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'
alias flutter-build-runner='flutter packages pub run build_runner build --delete-conflicting-outputs'

# Django
alias django-run-server='python manage.py runserver 0.0.0.0:8000'
alias django-shell='python manage.py shell'
alias django-settings-local='export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-envoirnment-create="python -m venv venv && source venv/bin/activate"
alias django-envoirnment-activate='source venv/bin/activate'
alias django-pip-install='pip install -r requirements.txt'
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
