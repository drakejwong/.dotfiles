if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export EDITOR="nvim"
export VISUAL="nvim"

export HISTFILE="$HOME/.zhistory"
export HISTSIZE=1000000
export SAVEHIST=1000000

# export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive # silence nix locale alert
# export LANG=en_US.UTF-8
# if [ -e /home/drake/.nix-profile/etc/profile.d/nix.sh ]; then . /home/drake/.nix-profile/etc/profile.d/nix.sh; fi
# . "$HOME/.cargo/env"

# Load AWS credentials
export AWS_ACCESS_KEY_ID=$(awk '/aws_access_key_id/ {print $3}' ~/.aws/credentials)
export AWS_SECRET_ACCESS_KEY=$(awk '/aws_secret_access_key/ {print $3}' ~/.aws/credentials)
export AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE='1'

export PKG_CONFIG_PATH="/opt/homebrew/Library/Homebrew/os/mac/pkgconfig/"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export VOLTA_FEATURE_PNPM=1
