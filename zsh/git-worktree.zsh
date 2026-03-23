# Git worktree helpers (zsh). Sourced from zshrc after compinit.

# Prefix short names with brodney/ for gwab (skip if already has brodney/ or another slash).
__gwa_brodney_branch() {
  local b=$1
  [[ $b == brodney/* ]] && { print -r -- $b; return }
  [[ $b == */* ]] && { print -r -- $b; return }
  print -r -- "brodney/$b"
}

# Sibling worktree: ../<dir>. No brodney/ rewriting — use gwab for that.
#   gwa dir [ref…]       →  git worktree add ../dir …
#   gwa -b|-B br dir [start]  →  git worktree add -b|-B br ../dir [start]  (literal branch name)
# Other leading flags → pass through to git worktree add.
gwa() {
  (( $# )) || { command git worktree add; return; }

  if [[ $1 == -b || $1 == -B ]]; then
    (( $# >= 3 )) || { command git worktree add "$@"; return; }
    local flag=$1 br=$2 d=$3
    shift 3
    command git worktree add "$flag" "$br" "../${d#./}" "$@"
    return
  fi

  if [[ $1 == -* ]]; then
    command git worktree add "$@"
    return
  fi

  command git worktree add "../${1#./}" "${@:2}"
}

# Like: gwa -b brodney/<name> <name> [start] — new branch under brodney/, sibling dir ../<name>.
gwab() {
  (( $# )) || { print -u2 "gwab: usage: gwab <name> [start-point]"; return 1; }
  local n=$1 br wtpath
  shift
  br=$(__gwa_brodney_branch "$n")
  wtpath="../${n#./}"
  command git worktree add -b "$br" "$wtpath" "$@" || return
  builtin cd -- "$wtpath" || return
}

# Populates __gws_paths and __gws_labels (basename, or parent/basename if basenames collide; full path if labels still collide).
__gws_paths_labels() {
  local top
  top=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  __gws_paths=( "${(@f)$(git -C "$top" worktree list --porcelain 2>/dev/null | awk '/^worktree / { sub(/^worktree /, ""); print }')}" )
  (( $#__gws_paths )) || return 1
  local -a labels
  local p b q n
  local i j c
  for p in $__gws_paths; do
    b=${p:t}
    n=0
    for q in $__gws_paths; do
      [[ ${q:t} == $b ]] && ((n++))
    done
    if (( n == 1 )); then
      labels+=($b)
    else
      labels+=("${${p:h}:t}/$b")
    fi
  done
  for i in {1..$#labels}; do
    c=0
    for j in {1..$#labels}; do
      [[ $labels[i] == $labels[j] ]] && ((c++))
    done
    if (( c > 1 )); then
      labels[i]=$__gws_paths[i]
    fi
  done
  __gws_labels=("${labels[@]}")
}

# cd to a worktree of the current repo (shared DB). Tab completes short names (see __gws_paths_labels).
# Refs/objects update from any tree (fetch/pull updates remotes for all); files on disk update per tree when you pull/switch there.
gws() {
  local dest
  local -a paths labels
  local arg i matches
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    print -u2 "gws: not inside a git repository"
    return 1
  fi
  __gws_paths_labels || return 1
  paths=("${__gws_paths[@]}")
  labels=("${__gws_labels[@]}")
  unset __gws_paths __gws_labels
  if [[ -z "$1" ]]; then
    git worktree list
    return 0
  fi
  arg=$1
  matches=()
  for i in {1..$#paths}; do
    [[ $arg == $paths[i] ]] || [[ $arg == $labels[i] ]] && matches+=($paths[i])
  done
  case ${#matches} in
    1) dest=$matches[1] ;;
    0)
      matches=()
      for i in {1..$#paths}; do
        [[ $paths[i] == *$arg* ]] || [[ $labels[i] == *$arg* ]] && matches+=($paths[i])
      done
      case ${#matches} in
        0) print -u2 "gws: no worktree matching: $arg"; return 1 ;;
        1) dest=$matches[1] ;;
        *)
          print -u2 "gws: ambiguous — matches:"
          for p in $matches; do print -u2 "  $p"; done
          return 1
          ;;
      esac
      ;;
    *)
      print -u2 "gws: ambiguous — matches:"
      for p in $matches; do print -u2 "  $p"; done
      return 1
      ;;
  esac
  [[ -d "$dest" ]] || { print -u2 "gws: not a directory: $dest"; return 1; }
  builtin cd "$dest" || return
}

_gws() {
  local -a labels
  __gws_paths_labels || return 1
  labels=("${__gws_labels[@]}")
  unset __gws_paths __gws_labels
  (( $#labels )) || return 1
  _describe -t worktrees 'worktree' labels
}

compdef _gws gws
compdef _git gwa=git-worktree
compdef _git gwab=git-worktree
