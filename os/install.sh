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
  if test ! $(which brew); then
    blue "[OS] Installing Homebrew"

    if test "$(uname)" = "Darwin"; then
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
    fi
  else
    green "[OS] Homebrew is already installed"
  fi

  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# Summary: Search for all SOURCE_FILE inside SOURCE_FOLDER and generates the DESTINATION_FILE
function generate_brewfiles() {
  local SOURCE_FILE="Brewfile"
  local SOURCE_FOLDER="$DOTFILES_ROOT"
  local DESTINATION_FILE="$HOME/.Brewfile"

  blue "[OS] Cleanup $DESTINATION_FILE"
  rm -f $DESTINATION_FILE

  blue "[OS] Search for $SOURCE_FILE inside $SOURCE_FOLDER and generate a merged Brewfile"
  cat $(find -H "$SOURCE_FOLDER" -type f -name "$SOURCE_FILE") >>$DESTINATION_FILE

  green "[OS] Generated $DESTINATION_FILE"
}

# Summary: Trust every non-official tap declared in the merged Brewfile.
#
# Homebrew 6.0 refuses to load formulae or casks from non-official taps unless
# they are trusted (HOMEBREW_REQUIRE_TAP_TRUST), which makes `brew bundle` fail
# on a fresh machine for entries like `brew "owner/tap/formula"` until someone
# runs `brew trust` by hand. Declaring a tap in a Brewfile is already a decision
# to trust it, so trust each one here before bundling. Idempotent, and a no-op on
# a Homebrew without the `trust` subcommand.
function trust_brewfile_taps() {
  local BREWFILE="$HOME/.Brewfile"

  if ! brew trust --help >/dev/null 2>&1; then
    blue "[OS] Skip tap trust (this Homebrew has no 'trust' subcommand)"
    return 0
  fi
  [ -f "$BREWFILE" ] || return 0

  # Taps come from explicit `tap "owner/name"` lines and from the owner/tap
  # prefix of fully-qualified `brew`/`cask "owner/tap/name"` entries. Short names
  # (official taps) have no prefix and are skipped.
  local taps
  taps="$(
    {
      grep -hoE '^[[:space:]]*tap[[:space:]]+"[^"]+"' "$BREWFILE" 2>/dev/null \
        | sed -E 's/.*"([^"]+)".*/\1/'
      grep -hoE '^[[:space:]]*(brew|cask)[[:space:]]+"[^"/]+/[^"/]+/[^"]+"' "$BREWFILE" 2>/dev/null \
        | sed -E 's#.*"([^"/]+/[^"/]+)/[^"]+".*#\1#'
    } | sort -u || true
  )"
  [ -n "$taps" ] || return 0

  blue "[OS] Trust non-official taps declared in the Brewfile"
  local tap
  while IFS= read -r tap; do
    [ -n "$tap" ] || continue
    brew tap "$tap" >/dev/null 2>&1 || true
    if brew trust --tap "$tap" >/dev/null 2>&1; then
      green "[OS] Trusted tap $tap"
    fi
  done <<<"$taps"
}

# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything, so
# yeah, let's do that.
update_mac_apps_and_libraries() {
  if [[ "$DOTFILES_OS_UPDATE_OS" == "true" ]]; then
    blue "[OS] Update Mac App Store apps"
    sudo /usr/sbin/softwareupdate -i -r
    green "[OS] Updated!"
  else
    blue "[OS] Ignored MacOS updated"
  fi
}

# Install Rosetta
install_rosetta() {
  if [[ $(uname -m) == 'arm64' ]]; then
    blue "[OS] Install Rosetta"
    sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    green "[OS] Rosetta installed!"
  fi
}

# ============================================================================
# MAIN
# ============================================================================

if test "$(uname)" = "Darwin"; then
  blue "[OS] Request sudo password to future process"
  sudo echo "Password added!"

  if [[ "$DOTFILES_SKIP_DEPS_INSTALLATION" != "true" ]]; then
    blue "[OS] Install Homebrew"
    install_homebrew
    generate_brewfiles

    blue "[OS] Go to $HOME directory"
    cd $HOME

    trust_brewfile_taps

    blue "[OS] Install Brew apps defined in the Brewfile (Takes a lot of time first time to install everything)"
    brew bundle --global
    green "[OS] Installed!"

    # Removing apps not listed in the Brewfile is opt-in and off by default, so
    # an install never uninstalls anything you did not ask it to. Set
    # DOTFILES_OS_ENABLE_BREW_CLEANUP=true to enable it. The old `brew bundle
    # --cleanup` switch is deprecated, so this uses the `cleanup` subcommand.
    # `--force` performs the removal and avoids the exit code 1 that a dry run
    # returns, which would abort the script under `set -e`.
    if [[ "${DOTFILES_OS_ENABLE_BREW_CLEANUP:-false}" == "true" ]]; then
      blue "[OS] Remove Brew apps not listed in the Brewfile"
      brew bundle cleanup --global --force
      green "[OS] Removed apps not in the Brewfile!"
    else
      blue "[OS] Keep Brew apps not in the Brewfile (set DOTFILES_OS_ENABLE_BREW_CLEANUP=true to remove them)"
    fi

    blue "[OS] Update all the apps defined in the Brewfile"
    brew update
    green "[OS] Updated!"

    blue "[OS] Upgrade all the cask apps"
    brew upgrade
    green "[OS] Upgraded!"

    blue "[OS] Clean old stuff dont required"
    brew cleanup
    green "[OS] Cleaned!"

    if [[ "$DOTFILES_OS_ENABLE_DOCTOR" == "true" ]]; then
      blue "[OS] Pass Doctor to check everything is fine"
      brew doctor
      green "[OS] Updated!"
    else
      blue "[OS] Ignored Brew Doctor command"
    fi

    blue "[OS] Return to the last directory"
    cd -
  else
    blue "[OS] Skipping dependency installation (DOTFILES_SKIP_DEPS_INSTALLATION=true)"
  fi

  update_mac_apps_and_libraries

  install_rosetta

  green "[OS] Successful installation"
fi
