.DEFAULT_GOAL := help

export DOTFILES_ROOT ?= ${HOME}/.dotfiles

zsh-reload:
	@zsh -l

.PHONY: help
help: Makefile
	@printf "\nChoose a command run in $(shell basename ${PWD}):\n"
	@sed -n 's/^##//p' $< | column -t -s ":" |  sed -e 's/^/ /'
	@echo

## unset: remove variables from terminal session `source <(make unset)`
.PHONY: unset
unset:
	@echo 'unset DOTFILES_ROOT'

## env: print required variables
.PHONY: env
env:
	@echo 'export DOTFILES_ROOT=${DOTFILES_ROOT}'

## setup: Install all dependencies
.PHONY: setup
setup : setup-no-reload zsh-reload

.PHONY: setup-no-reload
setup-no-reload:
	@# dotfiles bin-path links inside /usr/local/bin, which may not exist or may be
	@# root-owned on a fresh mac. Once it is user-writable no sudo is ever needed again.
	@if [ ! -w /usr/local/bin ]; then \
		sudo mkdir -p /usr/local/bin; \
		sudo chmod 755 /usr/local/bin; \
		sudo chown -R ${USER} /usr/local/bin; \
	fi
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles bin-path
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles symlink
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles git-setup
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles install

.PHONY: update
update:
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles update
