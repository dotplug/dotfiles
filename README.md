# Introduction

Dotfiles are tasked with **storing all your configuration** and **installing all Software necessary** in a deterministic way, making changing to a new machine _easy_ and _reproducible_.

## Installation

Open your terminal and execute:

```
/bin/bash -c "$(curl -fsSL https://gitlab.com/autentia/internal/dotfiles/dotfiles/-/raw/main/installer)"
```

Now you can check installation with:

```
dotfiles version
```

## Dotfiles

- `dotfiles install`: Install all required Software
- `dotfiles install-plugin <DOTFILES_GIT_URL>`: Install desired plugins
- `dotfiles help`: Shows all the available options
- `dotfiles version`: Displays the version

## How does it work?

The file's structure is important to handle the configuration, letting you separate each tool's configuration in different folders, allowing you to isolate each configuration.

These folders are what we call **topics**. The structure of each topic is as follows:

- **os/Brewfile**: This list represent all the applications and tools that will be installed with [Homebrew Cask](http://caskroom.io). All the Brewfile located inside the dotfiles will generate a Brewfile in $HOME/.Brewfile.
- **topic/bin/**: Anything inside the bin directory will be added to the $PATH, so you can use it with `dotfiles bin-path`.
- **topic/install.sh**: Any file named `install.sh` will be executed automatically when exeucting `dotfiles install`
- **topic/\<FILENAME | DIRNAME>.symlink**: Any file that ends with `*.symlink` will be added as a symlink to your $HOME.
- **projects/<PROJECT_NAME>**: Here we have all the project's configuration.

> The projects directory **should never be uploaded** as it could contain sensitive information

## Create a new topic

If you wanted to create a new topic you can create a directory `<TOPIC>` in the root of the dotfiles. Inside you can do some or all of the following:

1. Create an `install.sh` file that contains the installation process (only required for tools that are not present in Homebrew, if they are it's easier to install by updating the `Brewfile`)
2. Create an `alias.zsh` file that contains the commands you want
3. Create a file `functions.zsh` to create utility functions for that topic
4. Create a directory ending with `.symlink` that will symlink all the files inside that directory to your home directory
