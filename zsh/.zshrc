# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# znap
# Download Znap, if it's not there yet.
[[ -f $HOME/.config/zsh/znap/znap.zsh ]] ||
    git clone --depth 1 -- "https://github.com/marlonrichert/zsh-snap.git" "$HOME/.config/zsh/znap"
source $HOME/.config/zsh/znap/znap.zsh
zstyle ':znap:*' repos-dir $HOME/.config/zsh/znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt romkatv/powerlevel10k

# `znap source` automatically downloads and starts your plugins.
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search
znap source agkozak/zsh-z

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
alias vi=nvim
alias py=ptipython
alias ta='tmux attach'
alias apt='apt -y'
alias p='pnpm'

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
alias gb="git branch"
alias gc='git commit --verbose'
alias gcm='git commit --amend --no-edit'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git sync' # requires .gitconfig
alias gl='git pull'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always"
alias gm='git merge'
alias gma='git merge --abort'
alias gmm='git merge origin/$(basename $(git symbolic-ref refs/remotes/origin/HEAD))'
alias gp='git push -u origin HEAD'
alias gr='git reset'
alias grh='git reset --hard'
alias gs='git status'
alias grb='git rebase'
alias grbm='git rebase origin/$(basename $(git symbolic-ref refs/remotes/origin/HEAD))'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gss="git stash save -u"
alias gsp="git stash pop"
alias gnew='git checkout -b'

export LESS='MR'

boy() {
    curl -s "cheat.sh/$1"
}

SCALE_ZSHRC="$HOME/.dotfiles/zsh/.zshscale"
if [[ -f $SCALE_ZSHRC ]]; then
    source $SCALE_ZSHRC
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/drake/dev/.environment/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/drake/dev/.environment/etc/profile.d/conda.sh" ]; then
        . "/home/drake/dev/.environment/etc/profile.d/conda.sh"
    else
        export PATH="/home/drake/dev/.environment/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

fpath+=~/.zfunc
autoload -Uz compinit && compinit

# pnpm
export PNPM_HOME="/home/drake/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PNPM_HOME="/Users/drake/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# asdf
. "$HOME/.asdf/asdf.sh"

fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit

# bun completions
[ -s "/home/drake/.bun/_bun" ] && source "/home/drake/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
