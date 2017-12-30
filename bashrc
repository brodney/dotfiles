set -o vi

# Make autocompletion
complete -W "\`grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//'\`" make

# git autocompletion
export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"
source $DOTFILES/git-completion.bash

export PS1="(\w \j) \$ "
source '/Users/bjones/src/blessclient/lyftprofile' # bless ssh alias

# Enable aliases to be sudo'ed
alias sudo="sudo "

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Git
alias g="git"
alias G="git"

# Vim
alias v="vim"
alias vv="vim ."

# Archives
alias mktar="tar -pvczf"
alias untar="tar -zxvf"

# Remove all items from the dock
alias cleardock="defaults write com.apple.dock persistent-apps -array \"\" && killall Dock"
