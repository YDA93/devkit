# Flutter
alias flutter-dart-fix='dart fix --apply'
alias flutter-clean='flutter clean && flutter pub upgrade && flutter pub outdated && flutter pub upgrade --major-versions; flutter-dart-fix'
alias flutter-repair-cache='flutter pub cache repair'
alias flutter-ios-reinstall-podfile='cd ios && rm Podfile.lock && pod install --repo-update && cd .. && flutter-clean'
alias flutter-build-ios='flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json'
alias flutter-build-android='flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json'
alias flutter-build-runner='dart run build_runner build --delete-conflicting-outputs'
alias flutter-update-icon='dart run flutter_launcher_icons:main'
alias flutter-update-splash='dart run flutter_native_splash:remove && dart run flutter_native_splash:create'
alias flutter-update-fontawesome='cd assets/font_awesome_flutter && flutter-clean && flutter-dart-fix && cd util && sh ./configurator.sh && cd ../../..'
alias flutter-clean-deep='flutter-update-fontawesome && flutter-ios-reinstall-podfile && flutter-update-icon && flutter-update-splash && flutter-build-runner'
alias flutter-open-xcode='open ios/Runner.xcworkspace'