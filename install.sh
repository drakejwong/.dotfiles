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
		case "$package/$relative" in
		herdr/.config/herdr/config.toml | karabiner/.config/karabiner/karabiner.json)
			continue
			;;
		esac
		backup_and_link "$source" "$HOME/$relative"
	done < <(find "$package_dir" -type f -print0)
}

install_mutable_config() {
	local source=$1 target=$2 relative
	mkdir -p "$(dirname "$target")"
	if [[ -e $target || -L $target ]]; then
		if [[ -L $target ]]; then
			if [[ $target -ef $source ]]; then
				rm "$target"
			else
				relative=${target#"$HOME"/}
				mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
				mv "$target" "$BACKUP_DIR/$relative"
				printf 'Backed up %s -> %s\n' "$target" "$BACKUP_DIR/$relative"
			fi
		elif cmp -s "$source" "$target"; then
			return
		else
			relative=${target#"$HOME"/}
			mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
			mv "$target" "$BACKUP_DIR/$relative"
			printf 'Backed up %s -> %s\n' "$target" "$BACKUP_DIR/$relative"
		fi
	fi
	install -m 0644 "$source" "$target"
	printf 'Installed mutable config %s\n' "$target"
}

prune_retired_links() {
	local target link
	local targets=(
		"$HOME/.tmux.conf"
		"$HOME/.tmux.conf.local"
		"$HOME/.wezterm.lua"
		"$HOME/.config/alacritty"
		"$HOME/.config/zellij"
		"$HOME/.config/bin"
		"$HOME/.local/bin/zt-new-tab"
		"$HOME/.zfunc/_poetry"
		"$HOME/.zfunc/_poetry.zwc"
	)
	for target in "${targets[@]}"; do
		if [[ -L $target && ! -e $target ]]; then
			link=$(readlink "$target")
			if [[ $link == "$DOTFILES_DIR/"* ]]; then
				rm "$target"
				printf 'Removed obsolete link %s\n' "$target"
			fi
		fi
	done
}

install_mise() {
	if [[ ! -x "$HOME/.local/bin/mise" ]] && ! command -v mise >/dev/null 2>&1; then
		curl -fsSL https://mise.run | sh
	fi
	export PATH="$HOME/.local/bin:$PATH"
	eval "$(mise activate bash)"
	mise install
}

install_neovim_resources() {
	nvim --headless '+TSInstallConfigured' '+qa'
}

install_fonts() {
	local font_dir="$HOME/Library/Fonts" archive
	if [[ ${UPDATE_NATIVE_TOOLS:-0} != 1 && -f "$font_dir/HackNerdFontMono-Regular.ttf" ]]; then
		return
	fi
	mkdir -p "$font_dir"
	archive=$(mktemp "${TMPDIR:-/tmp}/Hack.zip.XXXXXX")
	curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -o "$archive"
	unzip -jqo "$archive" 'HackNerdFontMono-*.ttf' -d "$font_dir"
	rm -f "$archive"
}

migrate_zsh_secret() {
	local old_secret="$DOTFILES_DIR/zsh/.zshsecret"
	local new_secret="$HOME/.zshsecret"
	if [[ -f $old_secret && ! -e $new_secret ]]; then
		mv "$old_secret" "$new_secret"
		chmod 0600 "$new_secret"
		printf 'Moved %s -> %s\n' "$old_secret" "$new_secret"
	elif [[ -f $old_secret && -e $new_secret ]]; then
		printf 'Both %s and %s exist; keeping both.\n' "$old_secret" "$new_secret" >&2
	fi
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
	if [[ ! -d "$PIBERT_DIR/.git" ]]; then
		git clone https://github.com/drakejwong/pibert.git "$PIBERT_DIR"
	fi
	"$PIBERT_DIR/install.sh"
}

migrate_zsh_secret
for package in "${PACKAGES[@]}"; do
	link_package "$package"
done
install_mutable_config "$DOTFILES_DIR/herdr/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
install_mutable_config "$DOTFILES_DIR/karabiner/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
prune_retired_links

install_mise
install_neovim_resources
install_fonts

install_yabai_now=false
install_skhd_now=false
if [[ ${UPDATE_NATIVE_TOOLS:-0} == 1 ]] || ! command -v yabai >/dev/null 2>&1; then
	install_yabai_now=true
fi
if [[ ${UPDATE_NATIVE_TOOLS:-0} == 1 ]] || ! command -v skhd >/dev/null 2>&1; then
	install_skhd_now=true
fi
if $install_yabai_now || $install_skhd_now; then
	stop_window_manager_services
fi
if $install_yabai_now; then
	install_yabai
fi
if $install_skhd_now; then
	if ! xcode-select -p >/dev/null 2>&1 || ! command -v clang >/dev/null 2>&1; then
		printf '%s\n' 'Xcode Command Line Tools are required. Run xcode-select --install, then retry.' >&2
		exit 1
	fi
	install_skhd
fi

install_pibert

if [[ ${SKIP_HERDR_BUILD:-0} != 1 ]] && { [[ ${UPDATE_NATIVE_TOOLS:-0} == 1 ]] || ! command -v herdr >/dev/null 2>&1; }; then
	install_herdr_build_dependencies
	herdr-patched-update
fi

# Both generated LaunchAgents use RunAtLoad, so they start now and at login.
yabai --start-service
skhd --start-service

if [[ ! -d /Applications/Ghostty.app ]]; then
	printf 'Ghostty is not installed; get the signed macOS app from https://ghostty.org/download.\n' >&2
fi

cat <<'EOF'
Dotfiles and CLI tools are installed.
yabai and skhd are enabled now and at login. Set UPDATE_NATIVE_TOOLS=1 to
refresh native tools on a later run. Run ~/.dotfiles/install-karabiner.sh from
an interactive terminal if Karabiner-Elements is not installed, then approve
its requested permissions.
EOF
