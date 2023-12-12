function github-commit-and-push() {
    if [ $# -eq 0 ]; then
        git add -A
        git commit -m "Updated code"
        git push
    else
        git add -A
        git commit -m $@
        git push

    fi
}

function github-reset-cache-and-re-added-all-files() {
    git rm -r --cached .
    git add .
    git commit -m "Reset cache and re-added all files"
    git push origin main
}
