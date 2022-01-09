if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export EDITOR="nvim"
export VISUAL="nvim"

export HISTFILE="$HOME/.zhistory"
export HISTSIZE=1000000
export SAVEHIST=1000000

export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive # silence nix locale alert
export LANG=en_US.UTF-8
if [ -e /home/drake/.nix-profile/etc/profile.d/nix.sh ]; then . /home/drake/.nix-profile/etc/profile.d/nix.sh; fi
