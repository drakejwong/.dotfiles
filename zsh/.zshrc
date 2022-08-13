# znap
# Download Znap, if it's not there yet.
[[ -f ~/.config/zsh/znap/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \ https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap/zsh-snap/znap.zsh
source ~/.config/zsh/znap/zsh-snap/znap.zsh # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt sindresorhus/pure

# `znap source` automatically downloads and starts your plugins.
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

# `znap eval` caches and runs any kind of command output for you.
# znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# `znap function` lets you lazy-load features you don't always need.
# znap function _pyenv pyenv 'eval "$( pyenv init - --no-rehash )"'
# compctl -K    _pyenv pyenv

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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

alias l='ls -lAh'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias srz='source $HOME/.zshrc'
alias vi=lvim
alias py=ptipython
alias ta='tmux attach'
alias apt='apt -y'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

autoload edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

# git
alias g='git'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push -u origin HEAD'
alias gr='git reset'
alias grh='git reset --hard'
# alias gco='git checkout'
gco() {
  git fetch origin $1 ; \
  git checkout FETCH_HEAD -b $1
}
alias gnew='git checkout -b'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch --all --prune'
alias gl='git pull'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always"

export LESS='MR'

boy() {
    curl -s "cheat.sh/$1"
}

SCALE_ZSHRC="$HOME/.dotfiles/zsh/.zshscale"
if [[ -f $SCALE_ZSHRC ]]; then
    source $SCALE_ZSHRC
fi
