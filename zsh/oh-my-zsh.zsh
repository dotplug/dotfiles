export ZSH=$HOME/.oh-my-zsh
export ZSH_DISABLE_COMPFIX="true"

ZSH_THEME="robbyrussell"
HIST_STAMPS="dd.mm.yyyy"
plugins=(git)

# If Homebrew is installed under /opt/homebrew folder
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

source $ZSH/oh-my-zsh.sh
