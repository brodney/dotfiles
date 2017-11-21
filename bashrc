set -o vi

source '/Users/bjones/src/blessclient/lyftprofile' # bless ssh alias
source .alias

export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"
source $DOTFILES/git-completion.bash

export PS1="(\w \j) \$ "
