# Summary: Search for all SOURCE_FILE inside SOURCE_FOLDER and generates the DESTINATION_FILE
function merge_files() {
    local SOURCE_FILE=$1
    local SOURCE_FOLDER=$2
    local DESTINATION_FILE=$3

    blue "Cleanup $DESTINATION_FILE"
    rm $DESTINATION_FILE

    blue "Search for $SOURCE_FILE inside $SOURCE_FOLDER"
    cat $(find -H "$SOURCE_FOLDER" -type f -name "$SOURCE_FILE") >> $DESTINATION_FILE

    green "Generated $DESTINATION_FILE"
}
