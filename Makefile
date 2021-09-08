.DEFAULT_GOAL := help

export DOTFILES_DIR ?= ${HOME}/.dotfiles

.PHONY: help
help: Makefile
	@printf "\nChoose a command run in $(shell basename ${PWD}):\n"
	@sed -n 's/^##//p' $< | column -t -s ":" |  sed -e 's/^/ /'
	@echo

## unset: remove variables from terminal session `source <(make unset)`
.PHONY: unset
unset:
	@echo 'unset DOTFILES_DIR'

## env: print required variables
.PHONY: env
env:
	@echo 'export DOTFILES_DIR=${DOTFILES_DIR}'

## setup: Install all dependencies
.PHONY: setup
setup:
	@sudo mkdir -p /usr/local/bin   # dotfiles bin-path add links inside /usr/local/bin and this folder may not exists in new versions of mac.
	@sudo chmod 755 /usr/local/bin  # dotfiles bin-path add links inside /usr/local/bin and this folder may not exists in new versions of mac.
	@cd ${DOTFILES_DIR}/bin && ./dotfiles bin-path
	@cd ${DOTFILES_DIR}/bin && ./dotfiles install
	@cd ${DOTFILES_DIR}/bin && ./dotfiles symlink
	@cd ${DOTFILES_DIR}/bin && ./dotfiles git-setup
