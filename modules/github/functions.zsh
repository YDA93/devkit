# ------------------------------------------------------------------------------
# 🔐 GitHub SSH Key Utilities
# ------------------------------------------------------------------------------

# 📋 Lists SSH key pairs found in ~/.ssh/
# - Shows private and public key pairs with optional comments
# 💡 Usage: github-ssh-list
function github-ssh-list() {
    echo "📂 SSH keys in ~/.ssh/:"

    setopt local_options null_glob # Allow empty glob without error

    found_any=false

    # Loop through all private keys (id_*) that are not .pub files
    for priv in ~/.ssh/id_*; do
        [[ "$priv" == *.pub ]] && continue
        [[ -e "$priv" ]] || continue

        echo "🗝️  Private Key: $priv"
        pub="${priv}.pub"
        if [[ -f "$pub" ]]; then
            echo "🔑 Public Key: $pub"
            comment=$(awk '{print $3}' "$pub")
            [[ -n "$comment" ]] && echo "   └─ Comment: $comment"
        fi
        found_any=true
    done

    if [[ "$found_any" == false ]]; then
        _log_error "❌ No SSH keys found in ~/.ssh/"
    fi
}

# 🛠️ Creates and sets up an SSH key for GitHub (with port 443 fallback)
# - Generates key if missing, adds to ssh-agent, and copies to clipboard
# - Opens GitHub SSH key page for easy paste
# 💡 Usage: github-ssh-setup
function github-ssh-setup() {
    github_email=$(gum input --placeholder "you@example.com" --prompt "📧 Enter your GitHub email: ")

    if [[ ! "$github_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        _log_error "❌ Invalid email format."
        return 1
    fi

    key_path="$HOME/.ssh/id_ed25519"

    # Check if key already exists
    if [[ -f "$key_path" ]]; then
        _log_success "✅ SSH key already exists at $key_path"
    else
        _log_info "🔑 Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$github_email" -f "$key_path"
    fi

    echo "📋 Your public SSH key:"
    cat "${key_path}.pub"

    _log_info "🛠️  Updating SSH config to use port 443 for GitHub..."
    mkdir -p ~/.ssh
    touch ~/.ssh/config

    # Append config if it doesn't already exist
    if ! grep -q "Host github.com" ~/.ssh/config; then
        {
            echo ""
            echo "Host github.com"
            echo "  Hostname ssh.github.com"
            echo "  Port 443"
            echo "  User git"
        } >>~/.ssh/config
        _log_success "✅ SSH config updated."
    else
        _log_warning "⚠️  SSH config already contains a block for github.com. Skipping."
    fi

    _log_info "🔐 Starting ssh-agent and adding your key..."
    eval "$(ssh-agent -s)"
    if ! ssh-add -l | grep -q "$key_path"; then
        ssh-add "$key_path"
        _log_success "✅ SSH key added to agent."
    else
        _log_info "ℹ️  SSH key already added to agent. Skipping."
    fi

    echo ""
    echo "📎 Your SSH public key is now copied below. Add it to GitHub:"
    echo "👉 https://github.com/settings/keys"
    echo "----- COPY BELOW -----"
    cat "${key_path}.pub"
    echo "------ END KEY -------"

    pbcopy <~/.ssh/id_ed25519.pub
    open "https://github.com/settings/keys"

    echo ""
    echo "📎 Your SSH key has been copied to the clipboard."
    _log_hint "💡 To add it to GitHub:"
    echo "1. Go to https://github.com/settings/keys"
    echo "2. Click the green button: 'New SSH key'"
    echo "3. Give it a title like 'My MacBook' or 'Dev Machine'"
    echo "4. Paste the key into the 'Key' field (Cmd+V)"
    echo "5. Click 'Add SSH key'"

    echo ""
    echo "📌 Press enter after you've added the key to GitHub..."
    read

    _log_info "🚀 Testing SSH connection to GitHub..."
    ssh -T git@github.com

    echo ""
    echo "📂 SSH keys currently loaded into your agent:"
    ssh-add -l
}

# 🗑️ Deletes an SSH key from your system and ssh-agent
# - Lists key pairs and allows you to select which to delete
# 💡 Usage: github-ssh-delete
function github-ssh-delete() {
    echo "📂 SSH key pairs found in ~/.ssh/:"

    setopt local_options null_glob # 👈 This prevents errors if no matches

    keys=()
    i=1
    for key in ~/.ssh/id_*; do
        [[ "$key" == *.pub ]] && continue
        [[ -e "$key" ]] || continue

        keys+=("$key")
        echo "$i. $key"
        ((i++))
    done

    if [[ ${#keys[@]} -eq 0 ]]; then
        _log_error "❌ No SSH key pairs found."
        return
    fi

    echo
    choice=$(gum input --placeholder "Enter number (or leave empty to cancel)" --prompt "🗑️  Enter the number of the key you want to delete:")

    if [[ -z "$choice" ]]; then
        _log_error "❌ Cancelled. No key deleted."
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#keys[@]})); then
        _log_error "❌ Invalid selection."
        return
    fi

    key_path="${keys[$choice]}"

    echo ""
    _log_warning "⚠️  You selected: $key_path"
    if gum confirm "🗝️  Are you sure you want to delete this key from disk and unload from agent?"; then
        ssh-add -d "$key_path" 2>/dev/null && echo "🧼 Removed from ssh-agent."
        [[ -f "$key_path" ]] && rm "$key_path" && echo "🗑️  Deleted: $key_path"
        [[ -f "${key_path}.pub" ]] && rm "${key_path}.pub" && echo "🗑️  Deleted: ${key_path}.pub"
    else
        _log_error "❌ Cancelled. No key deleted."
    fi
}

# 🔍 Tests your GitHub SSH connection
# - Verifies if SSH access to GitHub is working correctly
# 💡 Usage: github-ssh-connection-test
function github-ssh-connection-test() {
    _log_info "🚀 Testing SSH connection to GitHub..."
    ssh -T git@github.com
}

# ------------------------------------------------------------------------------
# 🚀 GitHub Workflow Automation
# ------------------------------------------------------------------------------

# 🚀 Commits all changes and pushes to remote
# - Uses default commit message if none provided
# - Prompts before pushing
# 💡 Usage: github-commit-and-push ["Your commit message"]
function github-commit-and-push() {

    _confirm-or-abort "This action will commit all changes and push them to the remote repository. Continue?" "$@" || return 1

    # Check if a commit message is provided
    if [ $# -eq 0 ]; then
        # No commit message provided, use a default message
        git add -A
        git commit -m "Updated code"
    else
        # Use the provided commit message
        git add -A
        git commit -m "$@"
    fi

    # Push the committed changes to the remote repository
    git push
}

# 🔄 Clears Git cache and recommits all files
# - Useful after updating .gitignore
# - Prompts for confirmation
# 💡 Usage: github-clear-cache-and-recommit-all-files
function github-clear-cache-and-recommit-all-files() {

    _confirm-or-abort "This action will reset the Git cache and recommit all files. Continue?" "$@" || return 1

    # Step 1: Remove all files from the Git index (cache) without deleting them from the working directory.
    git rm -r --cached .

    # Step 2: Re-add all files to the Git index.
    git add .

    # Step 3: Commit the changes, effectively resetting the Git cache and recommitting all files.
    git commit -m "Reset Git cache and recommitted all files"

    # Step 4: Push the changes to the remote repository on the main branch.
    git push origin main
}

# ⏪ Reverts the last commit from the remote repository only
# - Local history remains unchanged
# - Force-pushes to main
# 💡 Usage: github-undo-last-commit
function github-undo-last-commit() {

    _confirm-or-abort "This action will revert the last commit on GitHub only. Continue?" "$@" || return 1

    # Step 1: Force push the current branch, resetting it to the previous commit on GitHub.
    # This will remove the last commit from the remote repository, effectively undoing it on GitHub.
    git push --force origin HEAD~1:main

    # Step 2: Confirm the action with a message to the user.
    echo "The last commit has been reverted on GitHub only. Your local repository remains unchanged."
}

# 🚀 Creates a new version tag based on user input (major, minor, patch, or custom)
# 💡 Usage: github-version-bump
function github-version-bump() {

    # 🧩 Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        _log_warning "⚠️  You have uncommitted changes."

        if gum confirm "❓ Do you want to commit all changes before tagging?"; then
            commit_message=$(gum input --placeholder "Commit message" --prompt "📝 Enter commit message: ")

            # Fallback to default message if input is empty
            commit_message=${commit_message:-"Auto commit before tagging $new_version"}

            git add -A || {
                _log_error "❌ Failed to add files to staging area."
                return 1
            }

            git commit -m "$commit_message" || {
                _log_error "❌ Failed to commit changes."
                return 1
            }

            gum spin --spinner dot --title "🚀 Pushing commit..." -- git push || {
                _log_error "❌ Failed to push changes."
                return 1
            }

        else
            _log_error "❌ Operation cancelled to avoid inconsistent tag."
            return 1
        fi
    fi

    # 🧩 Check for unpushed commits
    if [[ $(git log --branches --not --remotes) ]]; then
        _log_warning "⚠️  You have unpushed commits."

        if gum confirm "❓ Do you want to push them before tagging?"; then
            git push || {
                _log_error "❌ Failed to push changes."
                return 1
            }
        else
            _log_error "❌ Operation cancelled to avoid inconsistent tag."
            return 1
        fi
    fi

    _log_info "🔍 Fetching the latest tags from origin..."
    git fetch --tags || {
        _log_error "❌ Failed to fetch tags."
        return 1
    }

    # Get the latest version tag
    latest_tag=$(git tag --sort=-v:refname | head -n 1)

    if [[ -z "$latest_tag" ]]; then
        latest_tag="0.0.0"
        _log_info "ℹ️  No tags found. Starting from version: $latest_tag"
    else
        echo "🔖 Latest version: $latest_tag"
    fi

    IFS='.' read -r major minor patch <<<"$latest_tag"

    # 🧩 Prompt for the type of version bump
    bump_choice=$(
        gum choose --cursor "👉" --header "🚀 What type of version bump?" \
            "Major ($major.$minor.$patch → $((major + 1)).0.0)" \
            "Minor ($major.$minor.$patch → $major.$((minor + 1)).0)" \
            "Patch ($major.$minor.$patch → $major.$minor.$((patch + 1)))" \
            "Custom version (you will enter manually)"
    )

    # 🧩 Determine new version
    case "$bump_choice" in
    *"Major"*)
        new_version="$((major + 1)).0.0"
        ;;
    *"Minor"*)
        new_version="$major.$((minor + 1)).0"
        ;;
    *"Patch"*)
        new_version="$major.$minor.$((patch + 1))"
        ;;
    *"Custom version"*)
        new_version=$(gum input --placeholder "e.g., 2.5.0" --prompt "✍️  Enter the custom version: ")
        if ! [[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            _log_error "❌ Invalid version format."
            return 1
        fi
        ;;
    *)
        _log_error "❌ Invalid choice."
        return 1
        ;;
    esac

    # 🧩 Confirm final version before proceeding
    echo ""
    _log_info "🚀 New version to be created: $new_version"

    if gum confirm "❓ Do you want to proceed with creating and pushing this tag?"; then
        _log_info "✅ Proceeding with version $new_version..."
    else
        _log_error "❌ Operation cancelled."
        return 1
    fi

    # Create and push the new tag
    git tag -a "$new_version" -m "Release version $new_version" || {
        _log_error "❌ Failed to create tag."
        return 1
    }
    git push origin "$new_version" || {
        _log_error "❌ Failed to push tag."
        return 1
    }

    _log_success "✅ Version $new_version has been tagged and pushed to origin."
}

# ------------------------------------------------------------------------------
# 🌿 Branch Management Shortcuts
# ------------------------------------------------------------------------------

# 📝 Renames the current Git branch locally and remotely
# 💡 Usage: github-branch-rename <new-branch-name>
function github-branch-rename() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: github-rename-branch <new-branch-name>"
        return 1
    fi

    _confirm-or-abort "This action will rename the current branch to '$1'. Continue?" "$@" || return 1

    local new_branch="$1"
    local old_branch
    old_branch=$(git rev-parse --abbrev-ref HEAD)

    git branch -m "$new_branch"
    git push origin :"$old_branch" "$new_branch"
    git push --set-upstream origin "$new_branch"
    _log_success "✅ Renamed branch '$old_branch' to '$new_branch'"
}

# 🌿 Creates and switches to a new Git branch
# 💡 Usage: github-branch-create <branch-name>
function github-branch-create() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: github-create-branch <branch-name>"
        return 1
    fi

    _confirm-or-abort "Create a new branch '$1' and switch to it?" "$@" || return 1

    git checkout -b "$1"
    _log_success "✅ Created and switched to branch: $1"
}

# 🔥 Deletes a local and/or remote Git branch with confirmation
# 💡 Usage: github-branch-delete <branch-name>
function github-branch-delete() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        _log_error "❌ Usage: github-delete-branch <branch-name>"
        return 1
    fi

    _confirm-or-abort "Delete local branch '$branch'?" "$@" && git branch -d "$branch"
    _confirm-or-abort "Delete remote branch '$branch'?" "$@" && git push origin --delete "$branch"
}

# 🌲 Lists all local and remote branches
# 💡 Usage: github-branch-list
function github-branch-list() {
    echo "📄 Local branches:"
    git branch

    echo
    echo "🌐 Remote branches:"
    git branch -r
}

# 🧹 Deletes all local branches merged into main
# 💡 Usage: github-branches-clean
function github-branches-clean() {
    _confirm-or-abort "This will delete all branches already merged into 'main'. Continue?" "$@" || return 1

    git branch --merged main | grep -v '^\*' | grep -v 'main' | xargs -n 1 git branch -d
    _log_success "✅ Cleaned up merged branches."
}

# 🔄 Resets local branch to match the remote (destructive)
# 💡 Usage: github-reset-to-remote
function github-reset-to-remote() {
    _confirm-or-abort "This will reset your local branch to match remote. All local changes will be lost. Continue?" "$@" || return 1

    git fetch origin
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
    _log_success "✅ Local branch reset to match remote."
}

# ------------------------------------------------------------------------------
# 📥 Pulling & Tagging Enhancements
# ------------------------------------------------------------------------------

# 📥 Safely stashes changes, pulls, and reapplies stashed work
# 💡 Usage: github-stash-and-pull
function github-stash-and-pull() {
    _confirm-or-abort "This will stash your local changes, pull the latest changes from remote, and then reapply your stashed changes. Continue?" "$@" || return 1

    _log_info "📦 Stashing local changes..."
    git stash push -m "Auto stash before pull"
    _log_info "⬇️ Pulling latest changes..."
    git pull
    _log_info "📤 Reapplying stashed changes..."
    git stash pop
}

# 🏷️ Creates a Git tag and pushes it to origin
# 💡 Usage: github-push-tag <tag-name> [message]
function github-push-tag() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: github-push-tag <tag-name> [message]"
        return 1
    fi
    local tag="$1"
    shift
    local message="${*:-"Release $tag"}"

    confirm_or_abort "This will create and push the tag '$tag' with message '$message'. Continue?" "$@" || return 1

    git tag -a "$tag" -m "$message"
    git push origin "$tag"
    _log_success "✅ Tag '$tag' pushed to origin."
}

# 🔁 Rebases current branch onto another (default: main)
# 💡 Usage: github-rebase-current [target-branch]
function github-rebase-current() {
    local target="${1:-main}"

    _confirm-or-abort "This will rebase current branch onto '$target'. Continue?" "$@" || return 1

    git fetch origin
    git rebase origin/"$target"
}

# 🔄 Syncs your forked repo with upstream/main
# - Requires upstream to be configured
# 💡 Usage: github-sync-fork
function github-sync-fork() {
    if ! git remote get-url upstream &>/dev/null; then
        _log_error "❌ No upstream remote found. Add one like:"
        echo "   git remote add upstream https://github.com/ORIGINAL_OWNER/REPO.git"
        return 1
    fi

    confirm_or_abort "This will sync your fork with upstream main. Continue?" "$@" || return 1

    git fetch upstream
    git checkout main
    git reset --hard upstream/main
    git push origin main --force
    _log_success "✅ Fork synced with upstream."
}

# ------------------------------------------------------------------------------
# 📊 Git Status & Info
# ------------------------------------------------------------------------------

# 📊 Shows current Git branch and a short status summary
# 💡 Usage: github-status-short
function github-status-short() {
    echo "🔎 Current branch: $(git branch --show-current)"
    git status -s
}

# 📊 Shows detailed Git status with branch info
# 💡 Usage: github-status-detailed
function github-open() {
    # Check if inside a Git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        _log_error "❌ Not inside a Git repository."
        return 1
    fi

    local remote_url branch url

    # Get remote URL
    remote_url=$(git config --get remote.origin.url)
    if [[ -z "$remote_url" ]]; then
        _log_error "❌ No remote origin URL found."
        return 1
    fi

    # Get current branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z "$branch" ]]; then
        _log_error "❌ Could not determine current branch."
        return 1
    fi

    # Normalize remote URL (handle both git@ and https:// URLs)
    if [[ "$remote_url" == git@github.com:* ]]; then
        url="https://github.com/${remote_url#git@github.com:}"
    elif [[ "$remote_url" == https://github.com/* ]]; then
        url="$remote_url"
    else
        _log_error "❌ Unsupported remote URL format: $remote_url"
        return 1
    fi

    # Remove .git suffix if present
    url="${url%.git}"

    # Append branch path
    url="$url/tree/$branch"

    _log_info "🌐 Opening $url"
    open "$url"
}
