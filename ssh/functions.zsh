#!/usr/bin/env bash

function create_ssh_config() {
    merge_files "ssh-config" "$DOTFILES_DIR" "$HOME/.ssh/config"
}
