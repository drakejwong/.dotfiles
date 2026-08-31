#!/usr/bin/env bash
# Install Karabiner-Elements and link the version-controlled configuration.

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TARGET_DIR="$HOME/.config/karabiner"
SOURCE_DIR="$DOTFILES_DIR/karabiner/.config/karabiner"

if [[ $(uname -s) != Darwin ]]; then
  printf 'Karabiner-Elements requires macOS.\n' >&2
  exit 1
fi

command -v brew >/dev/null 2>&1 || {
  printf 'Homebrew is required. Install it from https://brew.sh, then rerun this script.\n' >&2
  exit 1
}

brew bundle --file "$DOTFILES_DIR/Brewfile.macos"
command -v stow >/dev/null 2>&1 || brew install stow

mkdir -p "$HOME/.config"
if [[ -e $TARGET_DIR || -L $TARGET_DIR ]]; then
  source_real=$(cd "$SOURCE_DIR" && pwd -P)
  target_real=$(cd "$TARGET_DIR" 2>/dev/null && pwd -P || true)
  if [[ $target_real != "$source_real" ]]; then
    backup="$HOME/.config/karabiner.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
    mv "$TARGET_DIR" "$backup"
    printf 'Backed up the existing Karabiner configuration to %s\n' "$backup"
  fi
fi

stow --restow --dir "$DOTFILES_DIR" --target "$HOME" karabiner

uid=$(id -u)
for label in \
  org.pqrs.service.agent.Karabiner-Console-User-Server \
  org.pqrs.service.agent.karabiner_console_user_server
do
  if launchctl print "gui/$uid/$label" >/dev/null 2>&1; then
    launchctl kickstart -k "gui/$uid/$label"
    break
  fi
done

open -a Karabiner-Elements
cat <<'EOF'
Karabiner-Elements is installed and its dotfiles configuration is linked.
Follow the app prompts to approve background services, Accessibility,
Input Monitoring, and the virtual HID Driver Extension.
EOF
