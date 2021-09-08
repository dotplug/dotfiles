function finddir() {
    find . -type d -name "$1"
}

function findfile() {
    find . -type f -name "$1"
}

function grep_filtered(){
    grep --exclude-dir=.terragrunt-cache -i "$1" -R **
}
