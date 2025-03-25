# 🚀 Commits all changes and pushes to remote
# - Prompts for confirmation
# - Uses default commit message if none is provided
# - Example: github-commit-and-push "Refactored login logic"
function github-commit-and-push() {

    confirm_or_abort "This action will commit all changes and push them to the remote repository. Continue?" "$@" || return 1

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

    confirm_or_abort "This action will reset the Git cache and recommit all files. Continue?" "$@" || return 1

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

    confirm_or_abort "This action will revert the last commit on GitHub only. Continue?" "$@" || return 1

    # Step 1: Force push the current branch, resetting it to the previous commit on GitHub.
    # This will remove the last commit from the remote repository, effectively undoing it on GitHub.
    git push --force origin HEAD~1:main

    # Step 2: Confirm the action with a message to the user.
    echo "The last commit has been reverted on GitHub only. Your local repository remains unchanged."
}
