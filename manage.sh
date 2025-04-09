#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform detection
PLATFORM="$(uname -s)"
case "$PLATFORM" in
  Darwin) PLATFORM="osx" ;;
  Linux) PLATFORM="linux" ;;
  *) PLATFORM="unknown" ;;
esac

# Configuration files to manage
files=(\
  alias \
  bash_profile \
  bashrc \
  ctags \
  git_template \
  gitconfig \
  tmux.conf \
  vim \
  vimrc \
  zshrc \
)

# Directories to manage
directories=(\
  config \
)

# Script settings
VERBOSE=false
DRY_RUN=false

# Print usage information
usage() {
  echo -e "${BLUE}Usage:${NC} ./manage.sh [options] {install|remove|check|clean|status}"
  echo -e "${BLUE}Options:${NC}"
  echo -e "  -v, --verbose    Show detailed output"
  echo -e "  -d, --dry-run    Show what would be done without making changes"
  echo -e "${BLUE}Commands:${NC}"
  echo -e "  install          Create symlinks for all configuration files"
  echo -e "  remove           Remove all symlinks"
  echo -e "  check            Check for broken symlinks"
  echo -e "  clean            Remove broken symlinks"
  echo -e "  status           Show current dotfiles status"
  exit 1
}

# Print verbose messages if enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}[INFO]${NC} $1"
  fi
}

# Print error message and exit
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Validate environment
validate_env() {
  if [ ! -d "$HOME" ]; then
    error "Home directory not found"
  fi

  if [ ! -w "$HOME" ]; then
    error "Home directory is not writable"
  fi
}

new_path() {
  echo "$HOME/.$1"
}

# Links the passed filename to its new location
link() {
  local filename="$1"
  local target="$(new_path "$filename")"

  if [[ ! -e "$filename" ]]; then
    error "$filename doesn't exist"
  fi

  if [[ -e "$target" ]]; then
    if [[ -L "$target" ]]; then
      log "Symlink already exists: $target"
    else
      log "File exists at $target, skipping"
    fi
  else
    log "Linking $filename to $target"
    if [ "$DRY_RUN" = false ]; then
      ln -sf "$PWD/$filename" "$target"
    fi
  fi
}

# Links the contents of a directory to its new location
link_directory() {
  local dirname="$1"
  local target_dir="$HOME/.$dirname"

  if [[ ! -d "$dirname" ]]; then
    error "Directory $dirname doesn't exist"
  fi

  if [[ ! -d "$target_dir" ]]; then
    log "Creating directory $target_dir"
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$target_dir"
    fi
  fi

  # Link each file in the directory
  for file in "$dirname"/*; do
    if [[ -e "$file" ]]; then
      local target="$target_dir/$(basename "$file")"
      if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
          log "Symlink already exists: $target"
        else
          log "File exists at $target, skipping"
        fi
      else
        log "Linking $file to $target"
        if [ "$DRY_RUN" = false ]; then
          ln -sf "$PWD/$file" "$target"
        fi
      fi
    fi
  done
}

# Delete the linked file
unlink() {
  local target="$(new_path "$1")"

  if [[ -L "$target" ]]; then
    log "Removing symlink: $target"
    if [ "$DRY_RUN" = false ]; then
      rm "$target"
    fi
  elif [[ -e "$target" ]]; then
    log "Not a symlink, skipping: $target"
  fi
}

# Delete the contents of a linked directory
unlink_directory() {
  local dirname="$1"
  local target_dir="$HOME/.$dirname"

  if [[ -d "$target_dir" ]]; then
    for file in "$target_dir"/*; do
      if [[ -L "$file" ]]; then
        log "Removing symlink: $file"
        if [ "$DRY_RUN" = false ]; then
          rm "$file"
        fi
      fi
    done
  fi
}

# Show current status of dotfiles
status() {
  echo -e "${BLUE}Current dotfiles status:${NC}"
  for file in "${files[@]}"; do
    local target="$(new_path "$file")"
    if [[ -L "$target" ]]; then
      if [[ -e "$target" ]]; then
        echo -e "${GREEN}✓ $file${NC} (symlinked)"
      else
        echo -e "${RED}✗ $file${NC} (broken symlink)"
      fi
    elif [[ -e "$target" ]]; then
      echo -e "${YELLOW}? $file${NC} (exists but not symlinked)"
    else
      echo -e "  $file (not installed)"
    fi
  done

  for dir in "${directories[@]}"; do
    local target_dir="$HOME/.$dir"
    echo -e "\n${BLUE}Directory $dir status:${NC}"
    if [[ -d "$target_dir" ]]; then
      for file in "$target_dir"/*; do
        if [[ -L "$file" ]]; then
          if [[ -e "$file" ]]; then
            echo -e "${GREEN}✓ $(basename "$file")${NC} (symlinked)"
          else
            echo -e "${RED}✗ $(basename "$file")${NC} (broken symlink)"
          fi
        elif [[ -e "$file" ]]; then
          echo -e "${YELLOW}? $(basename "$file")${NC} (exists but not symlinked)"
        fi
      done
    else
      echo -e "  (directory not created)"
    fi
  done
}

# Main functions
install_links() {
  log "Installing dotfiles..."
  for file in "${files[@]}"; do
    link "$file"
  done
  for dir in "${directories[@]}"; do
    link_directory "$dir"
  done
  log "Installation complete!"
}

remove_links() {
  log "Removing dotfiles..."
  for file in "${files[@]}"; do
    unlink "$file"
  done
  for dir in "${directories[@]}"; do
    unlink_directory "$dir"
  done
  log "Removal complete!"
}

check_links() {
  log "Checking for broken symlinks..."
  find -L "$HOME" -maxdepth 1 -type l -print
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    install|remove|check|clean|status)
      COMMAND="$1"
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# Validate environment
validate_env

# Execute command
case "$COMMAND" in
  install)
    install_links
    ;;
  remove)
    remove_links
    ;;
  check)
    check_links
    ;;
  clean)
    find -L "$HOME" -maxdepth 1 -type l -exec rm -i {} \;
    ;;
  status)
    status
    ;;
  *)
    usage
    ;;
esac
