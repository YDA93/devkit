# ------------------------------------------------------------------------------
# 🚀 FlutterFire CLI Tools
# ------------------------------------------------------------------------------

# Activate the FlutterFire CLI (one-time or when outdated)
alias flutter-flutterfire-activate='dart pub global activate flutterfire_cli'

# Launch the interactive Firebase project configuration tool
alias flutter-flutterfire-configure='flutterfire configure'

# ------------------------------------------------------------------------------
# 🛠️ Flutter Build Commands
# ------------------------------------------------------------------------------

# iOS warm-up build using precompiled SKSL shaders for faster startup performance
alias flutter-build-ios-warm-up='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'

# Android warm-up build using precompiled SKSL shaders for smoother startup
alias flutter-build-android-warm-up='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'

# 📦 Production-ready Android build with code obfuscation and symbol upload
alias flutter-build-android='flutter build appbundle --obfuscate --split-debug-info=./symbols/ && flutter-firebase-upload-crashlytics-symbols'

# Rebuild generated files (e.g., JSON serializers, freezed, etc.)
alias flutter-build-runner='dart run build_runner build --delete-conflicting-outputs'

# ------------------------------------------------------------------------------
# 🧹 Flutter Utilities
# ------------------------------------------------------------------------------

# Apply recommended Dart fixes automatically
alias flutter-dart-fix='dart fix --apply'

# Regenerate app launcher icons based on `pubspec.yaml` config
alias flutter-update-icon='dart run flutter_launcher_icons'

# Open the iOS project in Xcode
alias flutter-open-xcode='open ios/Runner.xcworkspace'
