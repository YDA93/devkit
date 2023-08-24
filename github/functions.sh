# Run Server
function github-commit-and-push() {
    if [ $# -eq 0 ]
        then
            git add .
            git commit -m "Updated code"
            git push
        else
            git add .
            git commit -m $@
            git push

    fi
}