# ------------------------------------------------------------------------------
# 🔥 FlutterFire & Firebase CLI Tools
# ------------------------------------------------------------------------------

# Activate the FlutterFire CLI (one-time or when outdated)
alias flutter-flutterfire-activate='dart pub global activate flutterfire_cli'

# Launch the interactive Firebase project configuration tool
alias flutter-flutterfire-configure='firebase-login-check && flutterfire configure'

# ------------------------------------------------------------------------------
# 🚀 Flutter Project Build Commands
# ------------------------------------------------------------------------------

# Rebuild generated files (e.g., JSON serializers, freezed, etc.)
alias flutter-build-runner='dart run build_runner build --delete-conflicting-outputs'

# iOS warm-up build using precompiled SKSL shaders for faster startup performance
alias flutter-build-ios-warm-up='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'

# Android warm-up build using precompiled SKSL shaders for smoother startup
alias flutter-build-android-warm-up='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'

# 📦 Production-ready Android build with code obfuscation and symbol upload
alias flutter-build-android='flutter build appbundle --obfuscate --split-debug-info=./symbols/ && flutter-firebase-upload-crashlytics-symbols'

# ------------------------------------------------------------------------------
# 🧩 Flutter Development Utilities
# ------------------------------------------------------------------------------

# Open the iOS project in Xcode
alias flutter-xcode-open='open ios/Runner.xcworkspace'

# Launch iOS Simulator
alias flutter-ios-simulator-open='open -a Simulator'

# List available iOS devices
alias flutter-ios-devices='xcrun simctl list devices'

# List available Android devices
alias flutter-android-devices='adb devices'

# Launch Flutter DevTools (performance inspector)
alias flutter-devtools='flutter pub global run devtools'

# Analyze Dart code for errors and lints
alias flutter-analyze='flutter analyze'

# Outdated package check
alias flutter-outdated='flutter pub outdated'

# Upgrade all dependencies to latest allowed versions
alias flutter-upgrade='flutter pub upgrade'

# Apply recommended Dart fixes automatically
alias flutter-dart-fix='dart fix --apply'

# ------------------------------------------------------------------------------
# 🎨 Flutter App Visuals & Assets
# ------------------------------------------------------------------------------

# Regenerate app launcher icons based on `pubspec.yaml` config
alias flutter-update-icon='dart run flutter_launcher_icons'

# ------------------------------------------------------------------------------
# 🧪 Flutter Testing Utilities
# ------------------------------------------------------------------------------

# Run all Flutter unit tests
alias flutter-test='flutter test'

# Run tests with coverage report
alias flutter-test-coverage='flutter test --coverage'
