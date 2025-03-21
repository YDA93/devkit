# ------------------------------------------------------------------------------
# ⚙️ FlutterFire Utilities
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

# ------------------------------------------------------------------------------
# ⚙️ Flutter Utility Commands
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
# ⚙️ Flutter Update Commands
# ------------------------------------------------------------------------------

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
# ⚙️ Flutter Clean-Up Commands
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
