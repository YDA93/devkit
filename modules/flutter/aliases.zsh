# ------------------------------------------------------------------------------
# 🚀 Flutterfire CLI
# ------------------------------------------------------------------------------

alias flutter-flutterfire-activate='dart pub global activate flutterfire_cli'
alias flutter-flutterfire-configure='flutterfire configure'

# ------------------------------------------------------------------------------
# 🛠️ Flutter Build Commands
# ------------------------------------------------------------------------------

# Warm-up builds using precompiled SKSL shaders for performance boost
alias flutter-build-ios-warm-up='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-android-warm-up='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'

# Standard builds
alias flutter-build-android='flutter build appbundle'
alias flutter-build-runner='dart run build_runner build --delete-conflicting-outputs'

# Android obfuscated APK with debug symbols for Crashlytics
alias flutter-android-build-debug-symbols='flutter build apk --obfuscate --split-debug-info=./symbols/'

# ------------------------------------------------------------------------------
# 🧨 Firebase Crashlytics Symbols Upload
# ------------------------------------------------------------------------------

# Upload debug symbols to Firebase Crashlytics
# Notes:
# - Replace APP_ID with your Firebase Android app ID (not package name)
# - Ensure ./symbols/ contains the output from the obfuscated build
alias flutter-upload-crashlytics-symbols='firebase crashlytics:symbols:upload --app=1:1052922103635:android:0cdec5371d763eb74a03a6 ./symbols/'

# ------------------------------------------------------------------------------
# 🧹 Flutter Utilities
# ------------------------------------------------------------------------------

alias flutter-dart-fix='dart fix --apply'
alias flutter-update-icon='dart run flutter_launcher_icons'
alias flutter-open-xcode='open ios/Runner.xcworkspace'
