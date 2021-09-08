#!/usr/bin/env bash

function repositories_status() {
    local BASE_DIR=$1
    local GREEN='\033[0;32m'

    # 1. Check if directory listed have ".git directory
    # 2. Print the repository name
    # 4. Execute git status command (coloured)
    find $BASE_DIR -type d -name ".git" -maxdepth 3 -exec blue "Repository: {}" \; -execdir git status \;
}


