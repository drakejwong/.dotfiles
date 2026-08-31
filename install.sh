#!/usr/bin/env bash
# Bootstrap this macOS development environment with mise and upstream installers.

set -euo pipefail

if [[ $(uname -s) != Darwin ]]; then
	printf 'This bootstrap currently supports macOS only.\n' >&2
	exit 1
fi

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PIBERT_DIR="$HOME/.pibert"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PACKAGES=(mise git jj ghostty herdr nvim zsh karabiner yabai skhd)

backup_and_link() {
	local source=$1 target=$2 relative
	mkdir -p "$(dirname "$target")"

	if [[ -e "$target" || -L "$target" ]]; then
		if [[ "$target" -ef "$source" ]]; then
			return
		fi
		relative=${target#"$HOME"/}
		mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
		mv "$target" "$BACKUP_DIR/$relative"
		printf 'Backed up %s -> %s\n' "$target" "$BACKUP_DIR/$relative"
	fi

	ln -s "$source" "$target"
	printf 'Linked %s -> %s\n' "$target" "$source"
}

link_package() {
	local package=$1 package_dir="$DOTFILES_DIR/$1" source relative
	[[ -d "$package_dir" ]] || return
	while IFS= read -r -d '' source; do
		relative=${source#"$package_dir"/}
		backup_and_link "$source" "$HOME/$relative"
	done < <(find "$package_dir" -type f -print0)
}

install_mise() {
	if [[ ! -x "$HOME/.local/bin/mise" ]] && ! command -v mise >/dev/null 2>&1; then
		curl -fsSL https://mise.run | sh
	fi
	export PATH="$HOME/.local/bin:$PATH"
	eval "$(mise activate bash)"
	mise install
	mise exec -- git lfs install
}

install_neovim_resources() {
	nvim --headless '+TSInstallConfigured' '+qa'
}

install_fonts() {
	local font_dir="$HOME/Library/Fonts" archive
	mkdir -p "$font_dir"
	archive=$(mktemp "${TMPDIR:-/tmp}/Hack.zip.XXXXXX")
	curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -o "$archive"
	unzip -jqo "$archive" 'HackNerdFontMono-*.ttf' -d "$font_dir"
	rm -f "$archive"
}

stop_window_manager_services() {
	local uid
	uid=$(id -u)
	launchctl bootout "gui/$uid/com.asmvik.yabai" 2>/dev/null || true
	launchctl bootout "gui/$uid/com.asmvik.skhd" 2>/dev/null || true
	pgrep -x yabai >/dev/null || rm -f "/tmp/yabai_$USER.lock" "/tmp/yabai_$USER.socket"
	pgrep -x skhd >/dev/null || rm -f "/tmp/skhd_$USER.pid"
}

install_yabai() {
	mkdir -p "$HOME/.local/bin" "$HOME/.local/share/man/man1"
	local work_dir installer
	work_dir=$(mktemp -d "${TMPDIR:-/tmp}/yabai-install.XXXXXX")
	installer="$work_dir/install.sh"
	curl -fsSL https://raw.githubusercontent.com/asmvik/yabai/master/scripts/install.sh -o "$installer"
	(cd "$work_dir" && sh "$installer" "$HOME/.local/bin" "$HOME/.local/share/man/man1")
	rm -rf "$work_dir"
}

install_skhd() {
	local work_dir
	work_dir=$(mktemp -d "${TMPDIR:-/tmp}/skhd-install.XXXXXX")
	git clone --quiet --depth 1 https://github.com/asmvik/skhd.git "$work_dir/skhd"
	make -C "$work_dir/skhd" install
	install -m 0755 "$work_dir/skhd/bin/skhd" "$HOME/.local/bin/skhd"
	rm -rf "$work_dir"
}

install_herdr_build_dependencies() {
	# Herdr upstream uses Homebrew's patched Zig build on Tahoe because the
	# official Zig archive cannot link build runners against the Tahoe SDK.
	if brew_prefix=$(brew --prefix zig@0.15 2>/dev/null) && [[ -x "$brew_prefix/bin/zig" ]]; then
		return
	fi
	command -v brew >/dev/null 2>&1 || {
		printf 'Homebrew is required only for the Tahoe-compatible Zig 0.15 build.\n' >&2
		exit 1
	}
	HOMEBREW_NO_AUTO_UPDATE=1 brew install zig@0.15
}

install_pibert() {
	if [[ -d "$PIBERT_DIR/.git" ]]; then
		git -C "$PIBERT_DIR" pull --ff-only
	else
		git clone https://github.com/drakejwong/pibert.git "$PIBERT_DIR"
	fi
	"$PIBERT_DIR/install.sh"
}

printf 'Updating %s...\n' "$DOTFILES_DIR"
git -C "$DOTFILES_DIR" pull --ff-only

for package in "${PACKAGES[@]}"; do
	link_package "$package"
done

install_mise
install_neovim_resources
install_fonts
stop_window_manager_services
install_yabai
install_skhd

install_pibert

if [[ ${SKIP_HERDR_BUILD:-0} != 1 ]]; then
	install_herdr_build_dependencies
	herdr-patched-update
fi

# Both generated LaunchAgents use RunAtLoad, so they start now and at login.
yabai --start-service
skhd --start-service

cat <<'EOF'
Dotfiles and CLI tools are installed.
yabai and skhd are enabled now and at login. Run
~/.dotfiles/install-karabiner.sh from an interactive terminal if
Karabiner-Elements is not installed, then approve its requested permissions.
EOF
