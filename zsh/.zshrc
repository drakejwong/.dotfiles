# anitbody install plugins
source $HOME/.zsh_plugins.sh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# history settings
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt inc_append_history     # share history
setopt hist_verify            # show command with history expansion to user before running it

# cd if command fails
setopt autocd

# hjkl for completion selection
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# enable fzf
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

# enable fasd
eval "$(fasd --init auto)"

# emacs keys
bindkey -e

# TODO: move these
# improved backward word delete
special-backward-delete-word () {
  # default WORDCHARS: *?_-.[]~=/&;!#$%^(){}<>
  local WORDCHARS='*~&#$%^<>'
  zle backward-delete-word
}
zle -N special-backward-delete-word
bindkey '^[^?' special-backward-delete-word

special-backward-word () {
  # default WORDCHARS: *?_-.[]~=/&;!#$%^(){}<>
  local WORDCHARS='*~&#$%^<>'
  zle backward-word
}
zle -N special-backward-word
bindkey '^[b' special-backward-word

special-forward-word () {
  # default WORDCHARS: *?_-.[]~=/&;!#$%^(){}<>
  local WORDCHARS='*~&#$%^<>'
  zle forward-word
}
zle -N special-forward-word
bindkey '^[f' special-forward-word

alias srz='source $HOME/.zshrc'
alias vi=nvim
alias py=python3.8
alias rip=rg
alias ta='tmux attach'
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

autoload edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

alias ga='git add'
alias gc='git commit -v'
alias gp='git push -u origin HEAD'
alias gr='git reset'
alias grh='git reset --hard'
alias gco='git checkout'
alias gnew='git checkout -b'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch --all --prune'
alias gl='git pull'
alias grb='git rebase'
alias grbc='git rebase --continue'

source "$HOME/.dotfiles/zsh/.zshscale"
