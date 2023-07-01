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
	@sudo mkdir -p /usr/local/bin   # dotfiles bin-path add links inside /usr/local/bin and this folder may not exists in new versions of mac.
	@sudo chmod 755 /usr/local/bin  # dotfiles bin-path add links inside /usr/local/bin and this folder may not exists in new versions of mac.
	@sudo chown -R ${USER} /usr/local/bin  # dotfiles bin-path add links inside /usr/local/bin and this folder may not exists in new versions of mac.
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles bin-path
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles symlink
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles git-setup
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles install

.PHONY: update
update:
	@cd ${DOTFILES_ROOT}/bin && ./dotfiles update
