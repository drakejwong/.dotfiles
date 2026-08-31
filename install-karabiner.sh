#!/usr/bin/env bash
# Install the official Karabiner-Elements package and link its configuration.

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SOURCE="$DOTFILES_DIR/karabiner/.config/karabiner/karabiner.json"
TARGET="$HOME/.config/karabiner/karabiner.json"

if [[ $(uname -s) != Darwin ]]; then
	printf 'Karabiner-Elements requires macOS.\n' >&2
	exit 1
fi

release_json=$(mktemp "${TMPDIR:-/tmp}/karabiner-release.XXXXXX")
dmg=$(mktemp "${TMPDIR:-/tmp}/karabiner.XXXXXX.dmg")
mountpoint=$(mktemp -d "${TMPDIR:-/tmp}/karabiner-mount.XXXXXX")
cleanup() {
	hdiutil detach "$mountpoint" -quiet >/dev/null 2>&1 || true
	rm -f "$release_json" "$dmg"
	rmdir "$mountpoint" >/dev/null 2>&1 || true
}
trap cleanup EXIT

curl -fsSL -H 'Accept: application/vnd.github+json' \
	https://api.github.com/repos/pqrs-org/Karabiner-Elements/releases/latest \
	-o "$release_json"
download_url=$(
	/usr/bin/python3 - "$release_json" <<'PY'
import json, sys
release = json.load(open(sys.argv[1]))
for asset in release.get("assets", []):
    if asset["name"].endswith(".dmg"):
        print(asset["browser_download_url"])
        break
else:
    raise SystemExit("release has no DMG asset")
PY
)

printf 'Downloading Karabiner-Elements from %s\n' "$download_url"
curl -fL "$download_url" -o "$dmg"
hdiutil attach "$dmg" -nobrowse -quiet -mountpoint "$mountpoint"
pkg=$(find "$mountpoint" -maxdepth 2 -name '*.pkg' -print -quit)
[[ -n "$pkg" ]] || {
	printf 'No installer package found in the DMG.\n' >&2
	exit 1
}

sudo installer -pkg "$pkg" -target /

mkdir -p "$(dirname "$TARGET")"
if [[ -e "$TARGET" || -L "$TARGET" ]]; then
	if [[ ! "$TARGET" -ef "$SOURCE" ]]; then
		backup="$TARGET.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
		mv "$TARGET" "$backup"
		printf 'Backed up the existing Karabiner configuration to %s\n' "$backup"
	fi
fi
[[ -e "$TARGET" || -L "$TARGET" ]] || ln -s "$SOURCE" "$TARGET"

uid=$(id -u)
for label in \
	org.pqrs.service.agent.Karabiner-Core-Service-rev2 \
	org.pqrs.service.agent.Karabiner-Console-User-Server; do
	if launchctl print "gui/$uid/$label" >/dev/null 2>&1; then
		launchctl kickstart -k "gui/$uid/$label"
	fi
done

open -a Karabiner-Elements
cat <<'EOF'
Karabiner-Elements is installed and its configuration is linked.
Approve its background services, Accessibility, Input Monitoring, and virtual
HID Driver Extension when macOS asks.
EOF
