#!/bin/bash

set -euo pipefail
IFS=$'\n\t'


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
        blue "[OS] Installing Homebrew"

        # Install the correct homebrew for each OS type
        if test "$(uname)" = "Darwin"
        then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 1>/dev/null
        elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
        then
           ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)" 1>/dev/null
        fi
    else
        green "[OS] Homebrew is already installed"
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

    blue "[OS] Cleanup $DESTINATION_FILE"
    rm $DESTINATION_FILE

    blue "[OS] Search for $SOURCE_FILE inside $SOURCE_FOLDER and generate a merged Brewfile"
    cat $(find -H "$SOURCE_FOLDER" -type f -name "$SOURCE_FILE") >> $DESTINATION_FILE

    green "[OS] Generated $DESTINATION_FILE"
}

# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything, so
# yeah, let's do that.
update_mac_apps_and_libraries() {
    blue "[OS] Update Mac App Store apps"
    sudo /usr/sbin/softwareupdate -i -r 1>/dev/null
    green "[OS] Updated!"
}

# Install Rosetta
install_rosetta() {
    if [[ `uname -m` == 'arm64' ]]; then
        blue "[OS] Install Rosetta"
        sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license 1>/dev/null
        green "[OS] Rosetta installed!"
    fi
}

# ============================================================================
# MAIN
# ============================================================================

if test "$(uname)" = "Darwin"
then
    blue "[OS] Request sudo password to future process"
    sudo echo "Password added!"

    blue "[OS] Install Homebrew"
    install_homebrew
    generate_brewfiles

    blue "[OS] Go to $HOME directory"
    cd $HOME

    blue "[OS] Install Brew apps defined in the Brewfile (Takes a lot of time first time to install everything)"
    brew bundle --cleanup --global 1>/dev/null
    green "[OS] Installed!"

    blue "[OS] Update all the apps defined in the Brewfile"
    brew update 1>/dev/null
    green "[OS] Updated!"

    blue "[OS] Upgrade all the cask apps"
    brew upgrade
    green "[OS] Upgraded!"

    blue "[OS] Clean old stuff dont required"
    brew cleanup
    green "[OS] Cleaned!"

    blue "[OS] Pass Doctor to check everything is fine"
    brew doctor
    green "[OS] Everything OK!"

    update_mac_apps_and_libraries

    install_rosetta

    blue "[OS] Return to the last directory"
    cd -

    green "[OS] Successful installation"
fi
