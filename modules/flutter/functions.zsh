# ------------------------------------------------------------------------------
# 🚀 Flutter Project Build Commands
# ------------------------------------------------------------------------------

# 🏗️ Run code generation using build_runner (e.g., for JSON serialization, Freezed classes, etc.)
# 📦 Deletes conflicting outputs to ensure clean generation
# 💡 Usage: flutter-build-runner
function flutter-build-runner() {
    _log-info "🔹 Running build_runner to rebuild generated files..."

    dart run build_runner build --delete-conflicting-outputs || {
        _log-error "✗ build_runner failed to build generated files"
        return 1
    }

    _log-success "✓ build_runner completed successfully"
}

# 🏗️ Build a production-ready Android app bundle with obfuscation and symbol splitting
# ☁️ Automatically uploads Crashlytics symbols to Firebase for de-obfuscation
# 💡 Usage: flutter-build-android
function flutter-build-android() {
    _log-info "🔹 Building production-ready Android app bundle..."

    flutter build appbundle --obfuscate --split-debug-info=./symbols/ || {
        _log-error "✗ Failed to build Android app bundle"
        return 1
    }

    _log-info "🔹 Uploading Crashlytics symbols..."
    flutter-firebase-upload-crashlytics-symbols || {
        _log-error "✗ Failed to upload Crashlytics symbols"
        return 1
    }

    _log-success "✓ Android app built and symbols uploaded successfully"
}

# 🧊 Build an iOS app using precompiled SKSL shaders for faster startup performance
# 💡 Usage: flutter-build-ios-warm-up
function flutter-build-ios-warm-up() {
    _log-info "🔹 Starting iOS warm-up build with precompiled SKSL shaders..."

    flutter build ipa --bundle-sksl-path flutter_01_ios.sksl.json || {
        _log-error "✗ iOS warm-up build failed"
        return 1
    }

    _log-success "✓ iOS warm-up build completed successfully"
}

# 🧊 Build an Android app using precompiled SKSL shaders for smoother launch experience
# 💡 Usage: flutter-build-android-warm-up
function flutter-build-android-warm-up() {
    _log-info "🔹 Starting Android warm-up build with precompiled SKSL shaders..."

    flutter build appbundle --bundle-sksl-path flutter_01_android.sksl.json || {
        _log-error "✗ Android warm-up build failed"
        return 1
    }

    _log-success "✓ Android warm-up build completed successfully"
}

# ------------------------------------------------------------------------------
# 🧩 Flutter Development Utilities
# ------------------------------------------------------------------------------

# 🧩 Open the iOS project in Xcode for manual editing or platform-specific configuration
# 💡 Usage: flutter-xcode-open
function flutter-xcode-open() {
    _log-info "🔹 Opening iOS project in Xcode..."

    open ios/Runner.xcworkspace || {
        _log-error "✗ Failed to open iOS project in Xcode"
        return 1
    }

    _log-success "✓ iOS project opened in Xcode"
}

# 📱 Launch the iOS Simulator app
# 💡 Usage: flutter-ios-simulator-open
function flutter-ios-simulator-open() {
    _log-info "🔹 Launching iOS Simulator..."

    open -a Simulator || {
        _log-error "✗ Failed to launch iOS Simulator"
        return 1
    }

    _log-success "✓ iOS Simulator launched"
}

# 📋 List all available iOS devices (simulators and physical)
# 💡 Usage: flutter-ios-devices
function flutter-ios-devices() {
    _log-info "🔹 Listing available iOS devices..."

    xcrun simctl list devices || {
        _log-error "✗ Failed to list iOS devices"
        return 1
    }

    _log-success "✓ iOS devices listed"
}

# 🤖 List all connected Android devices and emulators
# 💡 Usage: flutter-android-devices
function flutter-android-devices() {
    _log-info "🔹 Listing available Android devices..."

    adb devices || {
        _log-error "✗ Failed to list Android devices"
        return 1
    }

    _log-success "✓ Android devices listed"
}

# 🛠️ Launch the Flutter DevTools suite (performance, inspector, logs, memory, etc.)
# 💡 Usage: flutter-devtools
function flutter-devtools() {
    _log-info "🔹 Launching Flutter DevTools..."

    flutter pub global run devtools || {
        _log-error "✗ Failed to launch Flutter DevTools"
        return 1
    }

    _log-success "✓ Flutter DevTools launched"
}

# 🧪 Analyze your Dart codebase for static analysis issues, lints, and hints
# 💡 Usage: flutter-analyze
function flutter-analyze() {
    _log-info "🔹 Analyzing Dart code for issues..."

    flutter analyze || {
        _log-error "✗ Dart code analysis failed"
        return 1
    }

    _log-success "✓ Dart code analysis completed successfully"
}

# 📦 Check which Flutter or Dart dependencies are outdated in your project
# 💡 Usage: flutter-outdated
function flutter-outdated() {
    _log-info "🔹 Checking for outdated Flutter/Dart packages..."

    flutter pub outdated || {
        _log-error "✗ Failed to check for outdated packages"
        return 1
    }

    _log-success "✓ Outdated package check completed"
}

# ⬆️ Upgrade all Flutter and Dart dependencies to their latest allowed versions
# 💡 Usage: flutter-upgrade
function flutter-upgrade() {
    _log-info "🔹 Upgrading Flutter/Dart dependencies to latest allowed versions..."

    flutter pub upgrade || {
        _log-error "✗ Failed to upgrade dependencies"
        return 1
    }

    _log-success "✓ Dependencies upgraded successfully"
}

# 🧹 Automatically apply safe, recommended fixes for Dart issues and deprecations
# 💡 Usage: flutter-dart-fix
function flutter-dart-fix() {
    _log-info "🔹 Applying recommended Dart fixes..."

    dart fix --apply || {
        _log-error "✗ Failed to apply Dart fixes"
        return 1
    }

    _log-success "✓ Dart fixes applied successfully"
}

# ------------------------------------------------------------------------------
# 🔥 FlutterFire Initialization & Integration
# ------------------------------------------------------------------------------

# 🔥 Activate the FlutterFire CLI globally using Dart's pub global activate
# 💡 Usage: flutter-flutterfire-activate
function flutter-flutterfire-activate() {
    _log-info "🔹 Activating FlutterFire CLI..."
    dart pub global activate flutterfire_cli || {
        _log-error "✗ Failed to activate FlutterFire CLI"
        return 1
    }
    _log-success "✓ FlutterFire CLI activated"
}

# 🔧 Configure your Flutter app with Firebase (sets up native platforms & services)
# 💡 Usage: flutter-flutterfire-configure
function flutter-flutterfire-configure() {
    _log-info "🔹 Configuring Firebase project..."
    flutterfire configure || {
        _log-error "✗ FlutterFire configuration failed"
        return 1
    }
    _log-success "✓ Firebase project configured successfully"
}

# 🚀 Initialize Firebase for the Flutter project (login, activate CLI, configure project)
# 💡 Usage: flutter-flutterfire-init
function flutter-flutterfire-init() {
    _log-info "🔹 Logging into Firebase CLI..."
    firebase login || {
        _log-error "✗ Firebase login failed. Please log in to Firebase CLI"
        return 1
    }
    echo

    flutter-flutterfire-activate || return 1
    echo

    flutter-flutterfire-configure || return 1
}

# 🌱 Create and activate a new Python virtual environment for Firebase Functions
# 🐍 Uses Python 3.12 to create `venv/` and activates it
# 💡 Usage: flutter-firebase-environment-create
function flutter-firebase-environment-create() {
    python3.12 -m venv venv || {
        _log-error "✗ Failed to create virtual environment"
        return 1
    }
    source venv/bin/activate || {
        _log-error "✗ Failed to activate virtual environment"
        return 1
    }
    _log-success '✓ Environment created & activated' || {
        _log-error "✗ Failed to activate virtual environment"
        return 1
    }
}

# 🧹 Delete existing Python virtual environment, create a fresh one, and update pip
# 💡 Usage: flutter-firebase-environment-setup
function flutter-firebase-environment-setup() {
    python-environment-delete || {
        _log-error "✗ Failed to delete existing virtual environment"
        return 1
    }
    flutter-firebase-environment-create || {
        _log-error "✗ Failed to create virtual environment"
        return 1
    }
    pip-update || {
        _log-error "✗ Failed to update pip"
        return 1
    }
}

# ♻️ Rebuild the Firebase Functions environment from scratch
# 💡 Usage: flutter-firebase-update-functions
function flutter-firebase-update-functions() {
    if [ ! -d "firebase/functions" ]; then
        _log-error "✗ No Firebase functions directory found at firebase/functions"
        return 1
    fi

    cd firebase/functions || {
        _log-error "✗ Failed to change directory to firebase/functions"
        return 1
    }

    flutter-firebase-environment-setup || {
        _log-error "✗ Failed to set up Firebase environment"
        cd ../.. # Ensure we try to go back even on failure
        return 1
    }

    cd ../.. || {
        _log-error "✗ Failed to change directory back to root"
        return 1
    }
}

# 🚀 Upload obfuscation symbols to Firebase Crashlytics for deobfuscating stack traces
# 💡 Usage: flutter-firebase-upload-crashlytics-symbols
function flutter-firebase-upload-crashlytics-symbols() {
    local SYMBOLS_PATH="./symbols"

    # Prompt user for Firebase App ID
    _log-hint "🆔 Please enter your Firebase App ID:"
    _log-hint "💡 Hint: Check 'firebase_options.dart' under:"
    _log-hint "     static const FirebaseOptions android = FirebaseOptions(..."
    _log-hint "     appId: 'YOUR_APP_ID_HERE',"
    echo ""
    APP_ID=$(gum input --placeholder "your-app-id" --prompt "🆔 App ID: ")

    # Validate input
    if [[ -z "$APP_ID" ]]; then
        _log-error "✗ App ID is required. Aborting"
        return 1
    fi

    # Check if symbols directory exists
    if [[ ! -d "$SYMBOLS_PATH" ]]; then
        _log-error "✗ Symbols directory not found at: $SYMBOLS_PATH"
        _log-error "📁 Please make sure obfuscated symbols are built and placed there"
        return 1
    fi

    # Run upload
    _log-info "🔹 Uploading symbols to Firebase Crashlytics..."
    _log-info-2 "🔸 App ID: $APP_ID"
    _log-info-2 "🔸 Symbols Path: $SYMBOLS_PATH"
    echo ""

    firebase crashlytics:symbols:upload --app="$APP_ID" "$SYMBOLS_PATH"

    if [[ $? -eq 0 ]]; then
        _log-success "✓ Symbols uploaded successfully!"
    else
        _log-warning "⚠️ Upload failed. Please check the App ID and symbols path"
    fi
}

# ------------------------------------------------------------------------------
# 🧠 Android & JDK Setup Helpers
# ------------------------------------------------------------------------------

# 🔍 Gets the latest available Android build-tools version
# 💡 Usage: _android-latest-build-tools
function _android-latest-build-tools() {
    sdkmanager --list 2>/dev/null |
        awk '/^ +build-tools;[0-9]/ { gsub(/^ +| +$/, "", $1); split($1, parts, ";"); print parts[2] }' |
        grep -Ev 'rc|beta|alpha' |
        sort -Vr | head -n1
}

# ☕️ Symlinks Homebrew-installed OpenJDK to macOS Java VirtualMachines
# 💡 Usage: java-symlink-latest
function java-symlink-latest() {
    _log-info "🔹 Checking for Homebrew OpenJDK installation..."
    local brew_jdk_path="$HOMEBREW_OPT_PREFIX/openjdk/libexec/openjdk.jdk"

    if [[ ! -d "$brew_jdk_path" ]]; then
        _log-error "✗ Homebrew OpenJDK not found at $brew_jdk_path"
        echo
        return 1
    fi

    # Extract the actual JDK version using `java -version`
    local version
    version=$("$brew_jdk_path/Contents/Home/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)

    local target="/Library/Java/JavaVirtualMachines/openjdk-${version}.jdk"

    if [[ ! -d "$target" ]]; then
        _log-info "🔹 Symlinking OpenJDK $version to $target..."
        sudo ln -sfn "$brew_jdk_path" "$target" || {
            _log-error "✗ Failed to create symlink at $target"
            echo
            return 1
        }
        _log-success "✓ Symlinked OpenJDK to $target"
    fi
}

# ⚙️ Sets up Android SDK and accepts licenses
# 💡 Usage: flutter-android-sdk-setup
function flutter-android-sdk-setup() {
    _run-or-abort "🔹 Symlinking OpenJDK" \
        "✓ OpenJDK symlinked." \
        java-symlink-latest || return 1

    echo

    _log-info "🔹 Fetching latest Android build-tools version..."
    local latest_build_tools
    latest_build_tools=$(_android-latest-build-tools)

    _run-or-abort "🔹 Installing Android SDK packages (build-tools:$latest_build_tools)" \
        "" \
        sdkmanager \
        "platforms;android-35" \
        "build-tools;$latest_build_tools" \
        "platform-tools" \
        "emulator" \
        "cmdline-tools;latest" || return 1

    _log-success "✓ Android SDK packages installed"
    echo

    _run-or-abort "🔹 Accepting Android SDK licenses (non-interactive)" \
        "" \
        bash -c "yes | sdkmanager --licenses" || return 1
    _log-success "✓ Android SDK licenses accepted"
    echo

    _run-or-abort "🔹 Accepting Flutter Android licenses (interactive)" \
        "" \
        flutter doctor --android-licenses || return 1
    _log-success "✓ Flutter Android licenses accepted"
    echo

}

# ------------------------------------------------------------------------------
# 🎨 Flutter App Visuals
# ------------------------------------------------------------------------------

# 🎨 Regenerate app launcher icons from configuration in `pubspec.yaml`
# 💡 Usage: flutter-update-icon
function flutter-update-icon() {
    _log-info "🔹 Regenerating app launcher icons using flutter_launcher_icons..."

    dart run flutter_launcher_icons || {
        _log-error "✗ Failed to regenerate app launcher icons"
        return 1
    }

    _log-success "✓ App launcher icons updated successfully"
}

# 🌊 Updates splash screen assets using flutter_native_splash
# 💡 Usage: flutter-update-splash
function flutter-update-splash() {
    _log-info "🔹 Removing existing splash screen..."
    dart run flutter_native_splash:remove || {
        _log-error "✗ Failed to remove existing splash screen"
        return 1
    }
    echo

    _log-info "🔹 Creating new splash screen..."
    dart run flutter_native_splash:create || {
        _log-error "✗ Failed to create new splash screen"
        return 1
    }
}

# 🎨 Updates FontAwesome icons from the CLI utility
# 💡 Usage: flutter-update-fontawesome
function flutter-update-fontawesome() {
    if [ ! -d "assets/font_awesome_flutter" ]; then
        _log-error "✗ No FontAwesome directory found at assets/font_awesome_flutter"
        return 1
    fi

    cd assets/font_awesome_flutter || {
        _log-error "✗ Failed to change directory to assets/font_awesome_flutter"
        return 1
    }

    flutter-clean || {
        _log-error "✗ Failed to clean Flutter project"
        cd ../..
        return 1
    }

    flutter-dart-fix || {
        _log-error "✗ Failed to apply Dart fixes"
        cd ../..
        return 1
    }

    cd util || {
        _log-error "✗ Failed to change directory to util"
        cd ../..
        return 1
    }

    sh ./configurator.sh || {
        _log-error "✗ Failed to run configurator.sh"
        cd ../..
        return 1
    }

    cd ../../.. || {
        _log-error "✗ Failed to change directory back to root"
        return 1
    }
}

# ------------------------------------------------------------------------------
# 🔌 Flutter Development Utilities
# ------------------------------------------------------------------------------

# 🌐 Connects to a device over ADB and updates .vscode/launch.json
# 💡 Usage: flutter-adb-connect <IP_ADDRESS> <PORT>
function flutter-adb-connect() {
    # Assign the first and second argument to variables
    IP_ADDRESS=$1
    PORT=$2

    # Step 1: List the devices
    _log-info "🔹 Listing connected devices..."
    adb devices || {
        _log-error "✗ Failed to list devices. Ensure adb is installed and running"
        return 1
    }

    # Step 2: Connect to the device using adb
    _log-info "🔹 Connecting to device at $IP_ADDRESS:$PORT..."
    adb connect "$IP_ADDRESS:$PORT" || {
        _log-error "✗ Failed to connect to $IP_ADDRESS:$PORT. Ensure the device is reachable"
        return 1
    }

    # Step 3: Verify the connection
    _log-info "🔹 Verifying connection..."
    adb devices || {
        _log-error "✗ Failed to verify connection. Ensure adb is installed and running"
        return 1
    }

    # Step 4: Update .vscode/launch.json with the new port for the provided IP address
    # Navigate to the directory containing launch.json if necessary
    # cd /path/to/your/project

    # Define the pattern to search for and the replacement string
    SEARCH_PATTERN="$IP_ADDRESS:[0-9]+"
    REPLACE_PATTERN="$IP_ADDRESS:$PORT"

    # Update launch.json in place with the new port
    _log-info "🔹 Updating .vscode/launch.json with new port..."
    sed -i '' -E "s/$SEARCH_PATTERN/$REPLACE_PATTERN/g" .vscode/launch.json || {
        _log-error "✗ Failed to update .vscode/launch.json. Ensure the file exists and is writable"
        return 1
    }

    _log-success "✓ Updated .vscode/launch.json with new port for IP $IP_ADDRESS"
}

# ------------------------------------------------------------------------------
# 🧹 Flutter Clean-Up Commands
# ------------------------------------------------------------------------------

# 🧼 Deletes unused translation keys from .arb files
# 💡 Usage: flutter-delete-unused-strings
function flutter-delete-unused-strings() {
    dart pub global activate l10nization_cli || {
        _log-error "✗ Failed to activate l10nization_cli"
        return 1
    }

    # Temporary file to store unused translation keys
    temp_file="unused_keys.txt"

    # Directories and files
    arb_path="./l10n"                                # Adjust this path to where your .arb files are located
    declare -a arb_files=("app_ar.arb" "app_en.arb") # List your .arb files here

    # Run l10nization check-unused and capture the output of unused translations
    _log-info "🔹 Checking for unused translations..."
    l10nization check-unused | awk '/The list of unused translations:/{flag=1; next} flag' >"$temp_file"

    # Trim leading and trailing blank lines from the temp_file
    sed -i '' '/^$/d' "$temp_file"               # This removes empty lines
    sed -i '' '1{/^$/d;};${/^$/d;}' "$temp_file" # Additional check for the very first and last line if they are empty

    # Verify if unused keys were found
    if [ ! -s "$temp_file" ]; then
        _log-info-2 "🔸 No unused translations found"
        rm "$temp_file"
        return
    fi

    _log-info "🔹 Unused translations found. Starting cleanup process..."

    # Read the temp file line by line
    while IFS= read -r key; do
        # Loop through each .arb file
        for file in "${arb_files[@]}"; do
            full_path="$arb_path/$file"
            # Check if the file exists before trying to edit
            if [ -f "$full_path" ]; then
                # Use sed to delete the lines containing the keys
                # This command now modifies the file in-place without creating a backup
                sed -i '' "/\"$key\":/d" "$full_path"
                _log-success "✓ Removed $key from $file"
            else
                _log-error "✗ File $full_path not found"
            fi
        done
    done <"$temp_file"

    _log-success "✓ Cleanup completed"
}

# 🧹 Clears Pod, Flutter, and Ccache caches
# 💡 Usage: flutter-cache-reset
function flutter-cache-reset() {
    _log-info "🔹 Clearing cache of Pod..."
    cd ios || {
        _log-error "✗ Failed to change directory to ios"
        return 1
    }
    pod cache clean --all || {
        _log-error "✗ Failed to clean Pod cache"
        return 1
    }
    cd .. || {
        _log-error "✗ Failed to change directory back to root"
        return 1
    }
    _log-info "🔹 Clearing cache of Flutter..."
    flutter pub cache repair || {
        _log-error "✗ Failed to repair Flutter pub cache"
        return 1
    }

    _log-info "🔹 Clearing cache of Ccache..."
    ccache -z || {
        _log-error "✗ Failed to Resets the cache statistics"
        return 1
    }
    ccache -C || {
        _log-error "✗ Failed to Clears the cache contents"
        return 1
    }

    _log-success "✓ Cache cleared successfully"
}

# 🔧 Reinstalls iOS Podfile dependencies from scratch
# 💡 Usage: flutter-ios-reinstall-podfile
function flutter-ios-reinstall-podfile() {
    cd ios || {
        _log-error "✗ Failed to change directory to ios"
        return 1
    }
    _log-info "🔹 Removing existing Podfile.lock..."
    rm Podfile.lock || {
        _log-info "🔹 No Podfile.lock found. Skipping removal"
    }
    _log-info "🔹 Reinstalling pods..."
    pod install --repo-update || {
        _log-error "✗ Failed to install pods"
        return 1
    }
    cd .. || {
        _log-error "✗ Failed to change directory back to root"
        return 1
    }
    _log-success "✓ Podfile dependencies reinstalled successfully"
}

# 🧽 Runs a full Flutter clean and updates dependencies
# 💡 Usage: flutter-clean
function flutter-clean() {
    _log-info "🔹 Cleaning Flutter project..."
    flutter clean || {
        _log-error "✗ Failed to clean Flutter project"
        return 1
    }
    echo

    _log-info "🔹 Updating Flutter dependencies..."
    flutter pub upgrade || {
        _log-error "✗ Failed to upgrade Flutter packages"
        return 1
    }
    echo

    _log-info "🔹 Checking for outdated packages..."
    flutter pub outdated || {
        _log-error "✗ Failed to check for outdated packages"
        return 1
    }
    echo

    _log-info "🔹 Upgrading major versions of packages..."
    flutter pub upgrade --major-versions || {
        _log-error "✗ Failed to upgrade major versions of packages"
        return 1
    }
    echo

    flutter-dart-fix || {
        _log-error "✗ Failed to apply Dart fixes"
        return 1
    }
}

# 🧼 Performs a deep clean and rebuild of the entire Flutter project
# 💡 Usage: flutter-maintain
function flutter-maintain() {
    {
        flutter-flutterfire-activate || return 1

        flutter-firebase-update-functions
        flutter-update-fontawesome
        flutter-ios-reinstall-podfile || {
            _log-error "✗ Failed to reinstall Podfile"
            return 1
        }

        flutter-update-icon || {
            _log-error "✗ Failed to update app icons"
            return 1
        }
        flutter-update-splash || {
            _log-error "✗ Failed to update splash screen"
            return 1
        }
        flutter-build-runner || return 1
        flutter-clean || {
            _log-error "✗ Failed to clean Flutter project"
            return 1
        }
    } | tee -a ./flutter-maintain.log
}

# ------------------------------------------------------------------------------
# 🧪 Flutter Testing Utilities
# ------------------------------------------------------------------------------

# ✅ Run all Flutter unit and widget tests
# 💡 Usage: flutter-test
function flutter-test() {
    _log-info "🔹 Running all Flutter unit tests..."

    flutter test || {
        _log-error "✗ Unit tests failed"
        return 1
    }

    _log-success "✓ All unit tests passed"
}

# 📊 Run all Flutter tests and generate a code coverage report
# 💡 Usage: flutter-test-coverage
function flutter-test-coverage() {
    _log-info "🔹 Running Flutter tests with coverage report..."

    flutter test --coverage || {
        _log-error "✗ Tests or coverage report generation failed"
        return 1
    }

    _log-success "✓ Tests completed with coverage report"
}
