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
        echo "❌ No SSH keys found in ~/.ssh/"
    fi
}

# 🛠️ Creates and sets up an SSH key for GitHub (with port 443 fallback)
# - Generates key if missing, adds to ssh-agent, and copies to clipboard
# - Opens GitHub SSH key page for easy paste
# 💡 Usage: github-ssh-setup
function github-ssh-setup() {
    echo "📧 Enter your GitHub email:"
    read -r github_email

    key_path="$HOME/.ssh/id_ed25519"

    # Check if key already exists
    if [[ -f "$key_path" ]]; then
        echo "✅ SSH key already exists at $key_path"
    else
        echo "🔑 Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$github_email" -f "$key_path"
    fi

    echo "📋 Your public SSH key:"
    cat "${key_path}.pub"

    echo "🛠️  Updating SSH config to use port 443 for GitHub..."
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
        echo "✅ SSH config updated."
    else
        echo "⚠️  SSH config already contains a block for github.com. Skipping."
    fi

    echo "🔐 Starting ssh-agent and adding your key..."
    eval "$(ssh-agent -s)"
    if ! ssh-add -l | grep -q "$key_path"; then
        ssh-add "$key_path"
        echo "✅ SSH key added to agent."
    else
        echo "ℹ️  SSH key already added to agent. Skipping."
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
    echo "💡 To add it to GitHub:"
    echo "1. Go to https://github.com/settings/keys"
    echo "2. Click the green button: 'New SSH key'"
    echo "3. Give it a title like 'My MacBook' or 'Dev Machine'"
    echo "4. Paste the key into the 'Key' field (Cmd+V)"
    echo "5. Click 'Add SSH key'"

    echo ""
    echo "📌 Press enter after you've added the key to GitHub..."
    read

    echo "🚀 Testing SSH connection to GitHub..."
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
        echo "❌ No SSH key pairs found."
        return
    fi

    echo ""
    echo "🗑️  Enter the number of the key you want to delete (or press Enter to cancel):"
    read -r choice

    if [[ -z "$choice" ]]; then
        echo "❌ Cancelled. No key deleted."
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#keys[@]})); then
        echo "❌ Invalid selection."
        return
    fi

    key_path="${keys[$choice]}"

    echo ""
    echo "⚠️  You selected: $key_path"
    echo "Are you sure you want to delete this key from disk and unload from agent? (yes/no)"
    read -r confirm

    if [[ "$confirm" == "yes" ]]; then
        ssh-add -d "$key_path" 2>/dev/null && echo "🧼 Removed from ssh-agent."
        [[ -f "$key_path" ]] && rm "$key_path" && echo "🗑️  Deleted: $key_path"
        [[ -f "${key_path}.pub" ]] && rm "${key_path}.pub" && echo "🗑️  Deleted: ${key_path}.pub"
    else
        echo "❌ Cancelled. No key deleted."
    fi
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

# ------------------------------------------------------------------------------
# 🌿 Branch Management Shortcuts
# ------------------------------------------------------------------------------

# 📝 Renames the current Git branch locally and remotely
# 💡 Usage: github-branch-rename <new-branch-name>
function github-branch-rename() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: github-rename-branch <new-branch-name>"
        return 1
    fi

    _confirm-or-abort "This action will rename the current branch to '$1'. Continue?" "$@" || return 1

    local new_branch="$1"
    local old_branch
    old_branch=$(git rev-parse --abbrev-ref HEAD)

    git branch -m "$new_branch"
    git push origin :"$old_branch" "$new_branch"
    git push --set-upstream origin "$new_branch"
    echo "✅ Renamed branch '$old_branch' to '$new_branch'"
}

# 🌿 Creates and switches to a new Git branch
# 💡 Usage: github-branch-create <branch-name>
function github-branch-create() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: github-create-branch <branch-name>"
        return 1
    fi

    _confirm-or-abort "Create a new branch '$1' and switch to it?" "$@" || return 1

    git checkout -b "$1"
    echo "✅ Created and switched to branch: $1"
}

# 🔥 Deletes a local and/or remote Git branch with confirmation
# 💡 Usage: github-branch-delete <branch-name>
function github-branch-delete() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        echo "❌ Usage: github-delete-branch <branch-name>"
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
    echo "✅ Cleaned up merged branches."
}

# 🔄 Resets local branch to match the remote (destructive)
# 💡 Usage: github-reset-to-remote
function github-reset-to-remote() {
    _confirm-or-abort "This will reset your local branch to match remote. All local changes will be lost. Continue?" "$@" || return 1

    git fetch origin
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
    echo "✅ Local branch reset to match remote."
}

# ------------------------------------------------------------------------------
# 📥 Pulling & Tagging Enhancements
# ------------------------------------------------------------------------------

# 📥 Safely stashes changes, pulls, and reapplies stashed work
# 💡 Usage: github-stash-and-pull
function github-stash-and-pull() {
    _confirm-or-abort "This will stash your local changes, pull the latest changes from remote, and then reapply your stashed changes. Continue?" "$@" || return 1

    echo "📦 Stashing local changes..."
    git stash push -m "Auto stash before pull"
    echo "⬇️ Pulling latest changes..."
    git pull
    echo "📤 Reapplying stashed changes..."
    git stash pop
}

# 🏷️ Creates a Git tag and pushes it to origin
# 💡 Usage: github-push-tag <tag-name> [message]
function github-push-tag() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: github-push-tag <tag-name> [message]"
        return 1
    fi
    local tag="$1"
    shift
    local message="${*:-"Release $tag"}"

    confirm_or_abort "This will create and push the tag '$tag' with message '$message'. Continue?" "$@" || return 1

    git tag -a "$tag" -m "$message"
    git push origin "$tag"
    echo "✅ Tag '$tag' pushed to origin."
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
        echo "❌ No upstream remote found. Add one like:"
        echo "   git remote add upstream https://github.com/ORIGINAL_OWNER/REPO.git"
        return 1
    fi

    confirm_or_abort "This will sync your fork with upstream main. Continue?" "$@" || return 1

    git fetch upstream
    git checkout main
    git reset --hard upstream/main
    git push origin main --force
    echo "✅ Fork synced with upstream."
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
