# 💙 Flutter

A collection of custom Zsh functions and aliases to automate Flutter, Firebase, and Android/iOS environment setup and maintenance.

Boost your productivity with quick commands to manage Firebase functions, Android tools, iOS Pods, icons, translations, and more!

## 📑 Table of Contents

- [💙 Flutter](#-flutter)
  - [🔥 Firebase & FlutterFire](#-firebase--flutterfire)
  - [🧠 Android & JDK Setup](#-android--jdk-setup)
  - [🎨 Flutter App Visuals](#-flutter-app-visuals)
  - [🔌 Development Utilities](#-development-utilities)
  - [🧹 Clean-Up & Maintenance](#-clean-up--maintenance)

## 🔥 Firebase & FlutterFire

- `flutter-flutterfire-init` — Initialize Firebase & FlutterFire CLI for your project.
- `flutter-firebase-environment-create` - Create and activate a new Python venv for Firebase functions.
- `flutter-firebase-environment-setup` - Delete and recreate Firebase functions virtual environment.
- `flutter-firebase-update-functions` - Rebuild Firebase functions environment from scratch.
- `flutter-firebase-upload-crashlytics-symbols` - Upload obfuscation symbols to Firebase Crashlytics manually.
- `flutter-flutterfire-activate` - Activate FlutterFire CLI.
- `flutter-flutterfire-configure` - Launch Firebase project config tool.

## 🧠 Android & JDK Setup

- `java-symlink-latest` - Symlink latest Homebrew-installed OpenJDK to system.
- `flutter-android-sdk-setup` - Install Android SDK packages and accept licenses.

## 🎨 Flutter App Visuals

- `flutter-update-icon` - Update app launcher icons.
- `flutter-update-splash` - Update splash screen assets using flutter_native_splash.
- `flutter-update-fontawesome` - Update FontAwesome icons (local CLI utility).

## 🔌 Development Utilities

- `flutter-adb-connect <IP> <PORT>` - Connect device via ADB and update VSCode launch config.
- `flutter-build-runner` - Rebuild code generators (JSON serialization, etc.).
- `flutter-open-xcode` - Open iOS project in Xcode.
- `flutter-build-ios-warm-up` - iOS build with SKSL shaders.
- `flutter-build-android-warm-up` - Android build with SKSL shaders.
- `flutter-build-android` - Android production build + upload Crashlytics symbols.
- `flutter-dart-fix` - Apply Dart code fixes.

## 🧹 Clean-Up & Maintenance

- `flutter-clean` - Clean, upgrade dependencies, and apply Dart fixes.
- `flutter-maintain` - Full maintenance: Firebase, icons, pods, build runner, clean, etc.
- `flutter-delete-unused-strings` - Delete unused translation keys from .arb files.
- `flutter-cache-reset` - Clear Pod, Flutter, and Ccache caches.
- `flutter-ios-reinstall-podfile` - Reinstall iOS Podfile dependencies.
