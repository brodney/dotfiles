# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export GOPATH="$HOME/src/go"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
HISTSIZE=5000000
SAVEHIST=5000000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT
setopt AUTO_PARAM_SLASH
setopt COMPLETE_ALIASES

# Completion setup 
autoload -Uz compinit
zmodload zsh/complist
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt autocd
compinit -i

# Colorize completion menus
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:messages' format '%F{purple}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
fi

if [ -z "$DOTFILES" ]; then
  if [ -L "$HOME/.zshrc" ]; then
    DOTFILES="$(dirname "$(readlink "$HOME/.zshrc")")"
  else
    DOTFILES="$HOME/dotfiles"
  fi
fi
[ -f "$DOTFILES/alias" ] && source "$DOTFILES/alias"

# --- Git-aware prompt (lightweight) ---
autoload -Uz vcs_info add-zsh-hook
setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr ' ✗'
zstyle ':vcs_info:git:*' unstagedstr ' ✗'
zstyle ':vcs_info:git:*' formats '%F{blue}(%b%f%F{red}%c%u%f%F{blue})%f'
add-zsh-hook precmd vcs_info

# Prompt: Show user@host only when SSH'd in
if [[ -n $SSH_CONNECTION ]]; then
  PROMPT='%F{green}%n@%m%f %F{cyan}%c%f ${vcs_info_msg_0_} $ '
else
  PROMPT='%F{cyan}%c%f ${vcs_info_msg_0_} $ '
fi

# --- Vi mode with indicator ---
bindkey -v
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    RPROMPT='%F{magenta}[N]%f'
  else
    RPROMPT='%F{magenta}[I]%f'
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

# Ensure Ctrl-R searches history in both vi modes
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M vicmd '^R' history-incremental-search-backward

# --- Bracketed paste ---
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# For a full list of active aliases, run `alias`.
om () {
  CSS='<link rel="stylesheet" type="text/css" href="https://raw.githubusercontent.com/simonlc/Markdown-CSS/master/markdown.css">'
  TEMPFILE="/tmp/tempfile.html"
  echo $CSS > $TEMPFILE
  python -m markdown -v -o html5 $1 >> $TEMPFILE && open -a "Google Chrome" $TEMPFILE
}

# --- Common aliases ---
alias ..="cd .."
alias ...="cd ../.."
alias v="vim"
alias vv="vim ."
 

# Add support for Go modules and Lyft's Athens module proxy/store
# These variables were added by 'hacktools/set_go_env_vars.sh'
export GOPROXY='https://athens.ingress.infra.us-east-1.k8s.lyft.net'
export GONOSUMDB='github.com/lyft/*,github.lyft.net/*'
export GO111MODULE='auto'

### lyft_localdevtools_shell_rc start
### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
if [[ -f "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh" ]]; then
    source "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh"
fi
### lyft_localdevtools_shell_rc end

### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fi

# Extract Modules/XXX pattern from any input
alias iosmodule='grep -o "Modules/[^/]*" | sort -u'

greplace () {
  git grep -l "$1" | xargs sed -i '' "s/$1/$2/g"
}

. "$HOME/.local/bin/env"
