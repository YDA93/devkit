# ------------------------------------------------------------------------------
# 🔥 FlutterFire Utilities
# ------------------------------------------------------------------------------

function flutter-flutterfire-init() {
    firebase login
    flutter-flutterfire-activate
    flutterfire configure
}

function flutter-firebase-environment-create() {
    python3.12 -m venv venv
    source venv/bin/activate
    echo 'environment created. & activated.'
}

function flutter-firebase-environment-setup() {
    python-environment-delete
    flutter-firebase-environment-create
    pip-update
}

function flutter-firebase-update-functions() {
    cd firebase/functions
    flutter-firebase-environment-setup
    cd ../..
}

# Upload debug symbols to Firebase Crashlytics
# 💡 Usage: flutter_upload_crashlytics_symbols
# 👉 You can find your appId in `firebase_options.dart`:
#    Look for: `FirebaseOptions.android` → `appId: '...'`

function flutter_upload_crashlytics_symbols() {
    local SYMBOLS_PATH="./symbols"

    # Prompt user for Firebase App ID
    echo "🆔 Please enter your Firebase App ID:"
    echo "💡 Hint: Check 'firebase_options.dart' under:"
    echo "     static const FirebaseOptions android = FirebaseOptions(..."
    echo "     appId: 'YOUR_APP_ID_HERE',"
    echo ""
    printf "App ID: "
    read APP_ID

    # Validate input
    if [[ -z "$APP_ID" ]]; then
        echo "❌ App ID is required. Aborting."
        return 1
    fi

    # Check if symbols directory exists
    if [[ ! -d "$SYMBOLS_PATH" ]]; then
        echo "❌ Symbols directory not found at: $SYMBOLS_PATH"
        echo "📁 Please make sure obfuscated symbols are built and placed there."
        return 1
    fi

    # Run upload
    echo "🚀 Uploading symbols to Firebase Crashlytics..."
    echo "🆔 App ID: $APP_ID"
    echo "📁 Symbols Path: $SYMBOLS_PATH"
    echo ""

    firebase crashlytics:symbols:upload --app="$APP_ID" "$SYMBOLS_PATH"

    if [[ $? -eq 0 ]]; then
        echo "✅ Symbols uploaded successfully!"
    else
        echo "⚠️ Upload failed. Please check the App ID and symbols path."
    fi
}

# ------------------------------------------------------------------------------
# 🛠️ Flutter Utility Commands
# ------------------------------------------------------------------------------

function flutter-adb-connect() {
    # Assign the first and second argument to variables
    IP_ADDRESS=$1
    PORT=$2

    # Step 1: List the devices
    adb devices

    # Step 2: Connect to the device using adb
    adb connect "$IP_ADDRESS:$PORT"

    # Step 3: Verify the connection
    adb devices

    # Step 4: Update .vscode/launch.json with the new port for the provided IP address
    # Navigate to the directory containing launch.json if necessary
    # cd /path/to/your/project

    # Define the pattern to search for and the replacement string
    SEARCH_PATTERN="$IP_ADDRESS:[0-9]+"
    REPLACE_PATTERN="$IP_ADDRESS:$PORT"

    # Update launch.json in place with the new port
    sed -i '' -E "s/$SEARCH_PATTERN/$REPLACE_PATTERN/g" .vscode/launch.json

    echo "Updated .vscode/launch.json with new port for IP $IP_ADDRESS."
}

# ------------------------------------------------------------------------------
# 🔄 Flutter Update Commands
# ------------------------------------------------------------------------------

# 🔎 Gets the latest stable Android build-tools version (excludes rc/beta)
function _android-latest-build-tools() {
    sdkmanager --list 2>/dev/null |
        awk '/^ +build-tools;[0-9]/ { gsub(/^ +| +$/, "", $1); split($1, parts, ";"); print parts[2] }' |
        grep -Ev 'rc|beta|alpha' |
        sort -Vr | head -n1
}

# ☕️ Automatically symlinks the installed OpenJDK into macOS’s expected location
function java-symlink-latest() {
    local brew_jdk_path="$HOMEBREW_OPT_PREFIX/openjdk/libexec/openjdk.jdk"

    if [[ ! -d "$brew_jdk_path" ]]; then
        echo "❌ Homebrew OpenJDK not found at $brew_jdk_path"
        return 1
    fi

    # Extract the actual JDK version using `java -version`
    local version
    version=$("$brew_jdk_path/Contents/Home/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)

    local target="/Library/Java/JavaVirtualMachines/openjdk-${version}.jdk"

    if [[ ! -d "$target" ]]; then
        echo "☕️ Symlinking OpenJDK $version to $target..."
        sudo ln -sfn "$brew_jdk_path" "$target"
    else
        echo "☕️ OpenJDK $version already symlinked at $target"
    fi
}

# 📱 Sets up the Android SDK environment for CLI builds and emulators
function flutter-android-sdk-setup() {
    _run_or_abort "☕️ Symlinking OpenJDK" \
        "✅ OpenJDK symlinked." \
        java-symlink-latest || return 1

    local latest_build_tools
    latest_build_tools=$(_android-latest-build-tools)

    _run_or_abort "📦 Installing Android SDK packages (build-tools:$latest_build_tools)" \
        "" \
        sdkmanager \
        "platforms;android-35" \
        "build-tools;$latest_build_tools" \
        "platform-tools" \
        "emulator" \
        "cmdline-tools;latest" || return 1

    _run_or_abort "📜 Accepting Android SDK licenses (non-interactive)" \
        "" \
        bash -c "yes | sdkmanager --licenses" || return 1

    _run_or_abort "📜 Accepting Flutter Android licenses (interactive)" \
        "" \
        flutter doctor --android-licenses || return 1

    zsh-reset || return 1
}

function flutter-update-splash() {
    dart run flutter_native_splash:remove
    dart run flutter_native_splash:create
}

function flutter-update-fontawesome() {
    cd assets/font_awesome_flutter
    flutter-clean
    flutter-dart-fix
    cd util
    sh ./configurator.sh
    cd ../../..
}

# ------------------------------------------------------------------------------
# 🧹 Flutter Clean-Up Commands
# ------------------------------------------------------------------------------

function flutter-delete-unused-strings() {
    dart pub global activate l10nization_cli

    # Temporary file to store unused translation keys
    temp_file="unused_keys.txt"

    # Directories and files
    arb_path="./l10n"                                # Adjust this path to where your .arb files are located
    declare -a arb_files=("app_ar.arb" "app_en.arb") # List your .arb files here

    # Run l10nization check-unused and capture the output of unused translations
    echo "Checking for unused translations..."
    l10nization check-unused | awk '/The list of unused translations:/{flag=1; next} flag' >"$temp_file"

    # Trim leading and trailing blank lines from the temp_file
    sed -i '' '/^$/d' "$temp_file"               # This removes empty lines
    sed -i '' '1{/^$/d;};${/^$/d;}' "$temp_file" # Additional check for the very first and last line if they are empty

    # Verify if unused keys were found
    if [ ! -s "$temp_file" ]; then
        echo "No unused translations found."
        rm "$temp_file"
        return
    fi

    echo "Unused translations found. Starting cleanup process..."

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
                echo "Removed $key from $file"
            else
                echo "File $full_path not found."
            fi
        done
    done <"$temp_file"

    echo "Cleanup completed."
}

function flutter-cache-reset() {
    echo "Clearing cache of Pod, Flutter, and Ccache..."
    cd ios
    pod cache clean --all
    cd ..
    flutter pub cache repair
    ccache -z
    ccache -C
}

function flutter-ios-reinstall-podfile() {
    cd ios
    rm Podfile.lock
    pod install --repo-update
    cd ..
    flutter-clean
}

function flutter-clean() {
    flutter clean
    flutter pub upgrade
    flutter pub outdated
    flutter pub upgrade --major-versions
    flutter-dart-fix
}

function flutter-clean-deep() {
    {
        flutter-flutterfire-activate
        flutter-firebase-update-functions
        flutter-update-fontawesome
        flutter-ios-reinstall-podfile
        flutter-update-icon
        flutter-update-splash
        flutter-build-runner
    } | tee -a ./flutter-clean-deep.log
}
