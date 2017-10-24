set -o vi

source '/Users/bjones/src/blessclient/lyftprofile' # bless ssh alias

export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"

export PS1="(\w \j) \$ "
