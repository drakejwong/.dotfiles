#!/usr/bin/env bash
# Configure macOS screenshot shortcuts without intercepting application shortcuts.

set -euo pipefail

if [[ $(uname -s) != Darwin ]]; then
	printf 'macOS shortcuts can only be configured on macOS.\n' >&2
	exit 1
fi

set_symbolic_hotkey() {
	local id=$1 enabled=$2 character=$3 keycode=$4 modifiers=$5 enabled_xml
	if [[ $enabled == true ]]; then
		enabled_xml='<true/>'
	else
		enabled_xml='<false/>'
	fi

	/usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "
<dict>
  <key>enabled</key>$enabled_xml
  <key>value</key>
  <dict>
    <key>parameters</key>
    <array>
      <integer>$character</integer>
      <integer>$keycode</integer>
      <integer>$modifiers</integer>
    </array>
    <key>type</key><string>standard</string>
  </dict>
</dict>"
}

# Disable file and clipboard captures on Command-Shift-3 and Command-Shift-4.
set_symbolic_hotkey 28 false 51 20 1179648
set_symbolic_hotkey 29 false 51 20 1441792
set_symbolic_hotkey 30 false 52 21 1179648
set_symbolic_hotkey 31 false 52 21 1441792

# Disable the native Command-Shift-5 toolbar shortcut; skhd owns Command-Shift-S.
set_symbolic_hotkey 184 false 53 23 1179648

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
