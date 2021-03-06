#!/bin/bash
#
# Bootstrap development environment.

# install and nix
curl -L https://nixos.org/nix/install | sh
. $HOME/.nix-profile/etc/profile.d/nix.sh

# nix install packages
nix-env -iA \
	nixpkgs.zsh \
	nixpkgs.antibody \
	nixpkgs.git \
	nixpkgs.gh \
	nixpkgs.neovim \
	nixpkgs.tmux \
	nixpkgs.stow \
	nixpkgs.yarn \
	nixpkgs.fzf \
	nixpkgs.ripgrep \
	nixpkgs.fasd \
	nixpkgs.exa \
	nixpkgs.direnv \
	nixpkgs.bat \
	nixpkgs.pgcli

# stow dotfiles
stow git
stow nvim
stow tmux
stow zsh

# install MesloLGS NF font for p10k
FONTS_DIR=$HOME/.local/share/fonts
[ -d foo ] || mkdir -p $FONTS_DIR
for font_type in Regular Bold Italic Bold%20Italic; do \
    wget -nc -P $FONTS_DIR https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$font_type.ttf ; \
done

# make zsh default shell
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s $(which zsh) $USER

# antibody bundle
antibody bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.sh
source $HOME/.zshrc

# clone knowledge base
gh repo clone drakejwong/bigbrain $HOME/bigbrain

# tpm install
gh repo clone tmux-plugins/tpm $HOME/.tmux/plugins/tpm

# alacritty for MacOS
[ `uname -s` = 'Darwin' ] && stow alacritty
