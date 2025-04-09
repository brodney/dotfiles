set -o vi

export PATH=$PATH:~/bin

# Make autocompletion
complete -W "\`grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//'\`" make

# git autocompletion
export DOTFILES="$(dirname "$(readlink "$HOME/.bashrc")")"
source $DOTFILES/git-completion.bash

export PS1="(\w \j) \$ "

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

### lyft_localdevtools_shell_rc start
### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
if [[ -f "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh" ]]; then
    source "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh"
fi
### lyft_localdevtools_shell_rc end

### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
