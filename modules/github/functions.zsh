# 🚀 Commits all changes and pushes to remote
# - Prompts for confirmation
# - Uses default commit message if none is provided
# - Example: github-commit-and-push "Refactored login logic"
function github-commit-and-push() {

    _confirm_or_abort "This action will commit all changes and push them to the remote repository. Continue?" "$@" || return 1

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
# - Useful after .gitignore updates
# - Prompts before resetting index
# - Forcefully re-commits everything
function github-clear-cache-and-recommit-all-files() {

    _confirm_or_abort "This action will reset the Git cache and recommit all files. Continue?" "$@" || return 1

    # Step 1: Remove all files from the Git index (cache) without deleting them from the working directory.
    git rm -r --cached .

    # Step 2: Re-add all files to the Git index.
    git add .

    # Step 3: Commit the changes, effectively resetting the Git cache and recommitting all files.
    git commit -m "Reset Git cache and recommitted all files"

    # Step 4: Push the changes to the remote repository on the main branch.
    git push origin main
}

# ⏪ Reverts the last commit on GitHub (remote only)
# - Local repo remains unchanged
# - Force pushes to remove the last commit from remote
function github-undo-last-commit() {

    _confirm_or_abort "This action will revert the last commit on GitHub only. Continue?" "$@" || return 1

    # Step 1: Force push the current branch, resetting it to the previous commit on GitHub.
    # This will remove the last commit from the remote repository, effectively undoing it on GitHub.
    git push --force origin HEAD~1:main

    # Step 2: Confirm the action with a message to the user.
    echo "The last commit has been reverted on GitHub only. Your local repository remains unchanged."
}

# 📝 Renames the current branch locally and on GitHub
# 📥 Usage: github-branch-rename <new-branch-name>
function github-branch-rename() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: github-rename-branch <new-branch-name>"
        return 1
    fi

    _confirm_or_abort "This action will rename the current branch to '$1'. Continue?" "$@" || return 1

    local new_branch="$1"
    local old_branch
    old_branch=$(git rev-parse --abbrev-ref HEAD)

    git branch -m "$new_branch"
    git push origin :"$old_branch" "$new_branch"
    git push --set-upstream origin "$new_branch"
    echo "✅ Renamed branch '$old_branch' to '$new_branch'"
}

# 🌿 Creates a new branch and switches to it
# 📥 Usage: github-create-branch <branch-name>
function github-branch-create() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: github-create-branch <branch-name>"
        return 1
    fi

    _confirm_or_abort "Create a new branch '$1' and switch to it?" "$@" || return 1

    git checkout -b "$1"
    echo "✅ Created and switched to branch: $1"
}

# 🔥 Deletes a local and/or remote Git branch (with confirmation)
# 📥 Usage: github-delete-branch <branch-name>
function github-branch-delete() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        echo "❌ Usage: github-delete-branch <branch-name>"
        return 1
    fi

    _confirm_or_abort "Delete local branch '$branch'?" "$@" && git branch -d "$branch"
    _confirm_or_abort "Delete remote branch '$branch'?" "$@" && git push origin --delete "$branch"
}

# 🌲 Shows all branches with the current one highlighted
function github-branch-list() {
    echo "📄 Local branches:"
    git branch

    echo
    echo "🌐 Remote branches:"
    git branch -r
}

# 🧹 Deletes all local branches merged into main
function github-branches-clean() {
    _confirm_or_abort "This will delete all branches already merged into 'main'. Continue?" "$@" || return 1

    git branch --merged main | grep -v '^\*' | grep -v 'main' | xargs -n 1 git branch -d
    echo "✅ Cleaned up merged branches."
}

# 🔄 Resets local branch to match remote (forcefully)
function github-reset-to-remote() {
    _confirm_or_abort "This will reset your local branch to match remote. All local changes will be lost. Continue?" "$@" || return 1

    git fetch origin
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
    echo "✅ Local branch reset to match remote."
}

# 📥 Safely pulls latest changes after stashing
function github-stash-and-pull() {
    _confirm_or_abort "This will stash your local changes, pull the latest changes from remote, and then reapply your stashed changes. Continue?" "$@" || return 1

    echo "📦 Stashing local changes..."
    git stash push -m "Auto stash before pull"
    echo "⬇️ Pulling latest changes..."
    git pull
    echo "📤 Reapplying stashed changes..."
    git stash pop
}

# 📊 Shows a short, clean Git status and branch
function github-status-short() {
    echo "🔎 Current branch: $(git branch --show-current)"
    git status -s
}

# 🏷️ Creates and pushes a Git tag
# 📥 Usage: github-push-tag v1.0.0 [optional-message]
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

# 🔁 Rebases the current branch onto the latest main (or other)
# 📥 Usage: github-rebase-current [target-branch]
function github-rebase-current() {
    local target="${1:-main}"

    _confirm_or_abort "This will rebase current branch onto '$target'. Continue?" "$@" || return 1

    git fetch origin
    git rebase origin/"$target"
}

# 🔄 Syncs your fork with upstream main
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
