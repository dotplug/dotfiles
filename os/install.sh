#!/usr/bin/env bash

# ============================================================================
# FUNCTIONS
# ============================================================================

# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.
install_homebrew() {
    if test ! $(which brew)
    then
        blue "Installing Homebrew"

        # Install the correct homebrew for each OS type
        if test "$(uname)" = "Darwin"
        then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
        then
           ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
        fi
    else
        green "Homebrew is already installed"
    fi

    # If Homebrew is installed under /opt/homebrew folder
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# Summary: Search for all SOURCE_FILE inside SOURCE_FOLDER and generates the DESTINATION_FILE
function generate_brewfiles() {
    local SOURCE_FILE="Brewfile"
    local SOURCE_FOLDER="$DOTFILES_DIR"
    local DESTINATION_FILE="$HOME/.Brewfile"

    blue "Cleanup $DESTINATION_FILE"
    rm $DESTINATION_FILE

    blue "Search for $SOURCE_FILE inside $SOURCE_FOLDER"
    cat $(find -H "$SOURCE_FOLDER" -type f -name "$SOURCE_FILE") >> $DESTINATION_FILE

    green "Generated $DESTINATION_FILE"
}

# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything, so
# yeah, let's do that.
update_mac_apps_and_libraries() {
    local update_command="sudo softwareupdate -i -r"
    blue "› $update_command"
    $update_command
}

# Install Rosetta
install_rosetta() {
    if [[ `uname -m` == 'arm64' ]]; then
        blue "Install Rosetta"
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
}

# ============================================================================
# MAIN
# ============================================================================

if test "$(uname)" = "Darwin"
then
    blue "Install Homebrew"
    install_homebrew
    generate_brewfiles

    blue "Go to $HOME directory"
    cd $HOME

    blue "Install Brew apps defined in the Brewfile"
    brew bundle --cleanup --global

    blue "Update all the apps defined in the Brewfile"
    brew update

    blue "Upgrade all the cask apps"
    brew upgrade

    blue "Clean old stuff dont required"
    brew cleanup

    blue "Pass Doctor to check everything is fine"
    brew doctor

    blue "Update Mac App Store apps"
    update_mac_apps_and_libraries

    install_rosetta

    blue "Return to the last directory"
    cd -

    green "Successful installation"
fi
