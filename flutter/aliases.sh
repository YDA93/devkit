# Firebase Functions
alias flutter-firebase-environment-create="python3.12 -m venv venv && source venv/bin/activate && echo 'environment created. & activated.'"
alias flutter-firebase-environment-setup='python-environment-delete && flutter-firebase-environment-create && pip-update'

# Flutterfire
alias flutter-flutterfire-activate='dart pub global activate flutterfire_cli;'
alias flutter-flutterfire-configure='flutterfire configure;'
alias flutter-flutterfire-init='firebase login; flutter-flutterfire-activate; flutterfire configure;'

# Flutter Build
alias flutter-build-ios-warm-up='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-android-warm-up='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'
alias flutter-build-android='flutter build appbundle'
alias flutter-build-runner='dart run build_runner build --delete-conflicting-outputs'
# Android Build Debug Symbols
alias flutter-android-build-debug-symbols='flutter build apk --obfuscate --split-debug-info=./symbols/'
# firebase crashlytics:symbols:upload --app=FIREBASE_APP_ID PATH/TO/symbols
# FIREBASE_APP_ID is Firebase Android App ID (not your package name)
# PATH/TO/symbols is the path to the symbols folder
alias flutter-upload-crashlytics-symbols='firebase crashlytics:symbols:upload --app=1:1052922103635:android:0cdec5371d763eb74a03a6 ./symbols/'

# Flutter
alias flutter-dart-fix='dart fix --apply'
alias flutter-clean='flutter clean && flutter pub upgrade && flutter pub outdated && flutter pub upgrade --major-versions; flutter-dart-fix'
alias flutter-pub-repair-cache='flutter pub cache repair'
alias flutter-ios-reinstall-podfile='cd ios && rm Podfile.lock; pod install --repo-update; cd .. && flutter-clean'
alias flutter-update-icon='dart run flutter_launcher_icons'
alias flutter-update-splash='dart run flutter_native_splash:remove && dart run flutter_native_splash:create'
alias flutter-update-fontawesome='cd assets/font_awesome_flutter && flutter-clean && flutter-dart-fix && cd util && sh ./configurator.sh && cd ../../..'
alias flutter-update-firebase-functions='cd firebase/functions && flutter-firebase-environment-setup && cd ../..'
alias flutter-clean-deep='flutter-flutterfire-activate; flutter-update-firebase-functions; flutter-update-fontawesome && flutter-ios-reinstall-podfile && flutter-update-icon && flutter-update-splash && flutter-build-runner'
alias flutter-open-xcode='open ios/Runner.xcworkspace'
