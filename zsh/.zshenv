typeset -U path PATH

[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

export EDITOR="nvim"
export VISUAL="nvim"
export HISTFILE="$HOME/.zhistory"
export HISTSIZE=1000000
export SAVEHIST=1000000
export AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE=1

[[ -r "$HOME/.zshsecret" ]] && source "$HOME/.zshsecret"
