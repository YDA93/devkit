# Flutter
alias flutter-clean='flutter clean && flutter pub upgrade && flutter pub outdated && flutter pub upgrade --major-versions'
alias flutter-dart-fix='dart fix --apply'
alias flutter-repair-cache='flutter pub cache repair'
alias flutter-ios-reinstall-podfile='cd ios && rm Podfile.lock && pod install --repo-update && flutter-clean'
alias flutter-build-ios='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-android='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'
alias flutter-build-runner='flutter packages pub run build_runner build --delete-conflicting-outputs'