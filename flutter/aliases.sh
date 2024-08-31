# Flutterfire
alias flutter-flutterfire-activate='dart pub global activate flutterfire_cli;'
alias flutter-flutterfire-configure='flutterfire configure;'

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
alias flutter-update-icon='dart run flutter_launcher_icons'
alias flutter-open-xcode='open ios/Runner.xcworkspace'
