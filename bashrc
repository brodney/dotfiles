set -o vi

source '/Users/bjones/src/blessclient/lyftprofile' # bless ssh alias
source .alias
complete -W "\`grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//'\`" make


export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"
source $DOTFILES/git-completion.bash

export PS1="(\w \j) \$ "
