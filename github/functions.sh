function github-commit-and-push() {
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

function github-clear-cache-and-recommit-all-files() {
    # Step 1: Remove all files from the Git index (cache) without deleting them from the working directory.
    git rm -r --cached .

    # Step 2: Re-add all files to the Git index.
    git add .

    # Step 3: Commit the changes, effectively resetting the Git cache and recommitting all files.
    git commit -m "Reset Git cache and recommitted all files"

    # Step 4: Push the changes to the remote repository on the main branch.
    git push origin main
}

function github-undo-last-commit() {
    # Step 1: Force push the current branch, resetting it to the previous commit on GitHub.
    # This will remove the last commit from the remote repository, effectively undoing it on GitHub.
    git push --force origin HEAD~1:main

    # Step 2: Confirm the action with a message to the user.
    echo "The last commit has been reverted on GitHub only. Your local repository remains unchanged."
}
