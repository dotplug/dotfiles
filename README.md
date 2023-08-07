<div style="text-align: center;">
    <h1>dotfiles</h1>
    <h3>Automate the configuration of your computer</h3>
</div>
<hr>

[![License](https://img.shields.io/badge/License-Apache_2.0-yellowgreen.svg)](#license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green)](http://makeapullrequest.com)
<img src="https://img.shields.io/badge/macOS-ready-green" alt="macOs support ready" >
<img src="https://img.shields.io/badge/linux-in%20progress-orange" alt="Linux support in progress" >



- [Introduction](#introduction)
- [Installation](#installation)
- [Getting started](#getting-started)
    - [Plugins, how does it work?](#plugins-how-does-it-work)
    - [Installing a plugin](#installing-a-plugin)
    - [Creating a plugin](#creating-a-plugin)
    - [Topics](#topics)
- [Usage reference](#usage-reference)
- [License](#license)


## Introduction

Dotfiles are tasked with **storing all your configuration** and **installing all Software necessary** in a deterministic way, making changing to a new machine _easy_ and _reproducible_.

It works **based on plugins** that you can add to extend and automate the configuration of your computer.

## Installation

Open your terminal and execute:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/autentia/dotfiles/main/installer)"
```

Now you can check installation with:

```
dotfiles version
```

## Getting started

Once dotfiles is installed you would need to create or install a plugin to see changes in your configuration.

### Plugins, how does it work?

The file's structure is important to handle the configuration, letting you separate each tool's configuration in different folders, allowing you to isolate each configuration.

These folders are what we call **topics**. The structure of each topic is as follows:

- **os/Brewfile**: This list represent all the applications and tools that will be installed with [Homebrew Cask](http://caskroom.io). All the Brewfiles located inside the dotfiles will generate a Brewfile in $HOME/.Brewfile.
- **topic/bin/**: Anything inside the bin directory will be added to the $PATH, so you can use it with `dotfiles bin-path`.
- **topic/install.sh**: Any file named `install.sh` will be executed automatically when exeucting `dotfiles install`
- **topic/\<FILENAME | DIRNAME>.symlink**: Any file that ends with `*.symlink` will be added as a symlink to your $HOME.
- **projects/<PROJECT_NAME>**: Here we have all the project's configuration.

> The plugins directory **should never be uploaded** as it could contain sensitive information

### Installing a plugin

If you have your plugin configured you would need to push it to your favorite repository manager. Then you can add it to ```dotfiles``` in your computer executing:

```shell
dotfiles install-plugin <GIT_REPOSITORY_URL>
```

For example:

```shell
dotfiles install-plugin git@github.com:autentia/my-awesome-plugin-template.git
```

### Creating a plugin

You can start to create your plugin using ```dotfiles``` command to initialize your plugin executing the following command replacing "<PLUGIN_NAME>" with the desired name:

```shell
dotfiles create-plugin <PLUGIN_NAME>
```

For example:

```shell
dotfiles create-plugin my-awesome-plugin
```

This command will create a directory with the plugin name provided. You will have a plugin template inside that you can customise. 

### Topics

If you wanted to create a new topic you can create a directory `<TOPIC>` in the root of the dotfiles. Inside you can do some or all of the following:

1. Create an `install.sh` file that contains the installation process (only required for tools that are not present in Homebrew, if they are it's easier to install by updating the `Brewfile`)
2. Create an `alias.zsh` file that contains the commands you want
3. Create a file `functions.zsh` to create utility functions for that topic
4. Create a directory ending with `.symlink` that will symlink all the files inside that directory to your home directory

### Uninstalling a plugin

If you have a plugin that you no longer want to use, you can remove it executing:

```shell
dotfiles uninstall-plugin <PLUGIN_NAME>
```

For example:

```shell
dotfiles uninstall-plugin my-awesome-plugin
```

## Usage reference

- `dotfiles install`: Install all required software. To avoid software installation use the DOTFILES_OS_UPDATE_OS envvar set to "false".
- `dotfiles install-plugin [-nh] <DOTFILES_GIT_URL>`: Install desired plugins
  - `-h, --help`          Display help
  - `-n, --no-reload`     The installer will not refresh the session at the end
- `dotfiles git-setup`: Create the .gitconfig and .gitconfig.local files. Use the DOTFILES_GIT_AUTHORNAME and DOTFILES_GIT_AUTHOREMAIL environment variables to use it non interactive.
- `dotfiles update-plugin <PLUGIN_NAME>`: Update a given plugin
- `dotfiles uninstall-plugin <PLUGIN_NAME>`: Uninstall a given plugin
- `dotfiles create-plugin <PLUGIN_NAME>`: Create a plugin using the base template
- `dotfiles plugins`: Shows all plugins installed
- `dotfiles help`: Shows all the available options
- `dotfiles update`: Update to latest version of dotfiles
- `dotfiles uninstall`: Search for all uninstall.sh files and execute it
- `dotfiles apply`: Apply all configuration again: execute install.sh, create symlinks, etc
- `dotfiles version`: Display the version

## License

[Apache License](https://github.com/autentia/dotfiles/blob/main/LICENSE.txt)

