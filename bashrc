set -o vi

source '/Users/bjones/src/blessclient/lyftprofile' # bless ssh alias

export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"
