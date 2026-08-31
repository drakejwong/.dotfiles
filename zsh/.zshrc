# Load machine-specific PATH additions before mise so mise-managed tools win.
if [[ -r "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [[ -r "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
elif command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Enable Powerlevel10k instant prompt near the top of the interactive setup.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Znap installs and updates shell plugins directly from their upstream repos.
znap_dir="$HOME/.config/zsh/znap"
if [[ ! -r "$znap_dir/znap.zsh" ]]; then
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$znap_dir"
fi
source "$znap_dir/znap.zsh"
zstyle ':znap:*' repos-dir "$znap_dir"
znap prompt romkatv/powerlevel10k
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

fpath=("$HOME/.zfunc" $fpath)
autoload -Uz compinit edit-command-line
compinit
zle -N edit-command-line

command -v herdr >/dev/null 2>&1 && source <(herdr completion zsh)
command -v jj >/dev/null 2>&1 && source <(jj util completion zsh)

setopt extended_history hist_expire_dups_first hist_ignore_dups
setopt hist_ignore_space inc_append_history hist_verify autocd

zmodload zsh/complist
bindkey -e
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey '^x^x' edit-command-line

special-backward-delete-word() {
  local WORDCHARS='*~&#$%^<>'
  zle backward-delete-word
}
zle -N special-backward-delete-word
bindkey '^[^?' special-backward-delete-word

special-backward-word() {
  local WORDCHARS='*~&#$%^<>'
  zle backward-word
}
zle -N special-backward-word
bindkey '^[b' special-backward-word

special-forward-word() {
  local WORDCHARS='*~&#$%^<>'
  zle forward-word
}
zle -N special-forward-word
bindkey '^[f' special-forward-word

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type=d --hidden --exclude .git'
  _fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
  _fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1" }
  show_file_or_dir_preview='if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  [[ -r "$HOME/.fzf-git.sh" ]] && source "$HOME/.fzf-git.sh"
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

alias l='ls -lAh'
alias e='eza --color=always --long --git --icons=always --no-user --no-permissions'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias srz='source "$HOME/.zshrc"'
alias vi='nvim'
alias py='python'
alias p='pnpm'
alias k='kubectl'
alias rg='rg -M 1000'
alias oc='opencode'
alias gg='lazygit'

# Jujutsu (primary VCS)
alias j='jj'
alias js='jj status'
alias jl='jj log'
alias jd='jj diff'
alias jn='jj new'
alias jc='jj commit'
alias jdesc='jj describe'
alias jsq='jj squash'
alias jsp='jj split'
alias ju='jj undo'
alias jf='jj git fetch'
alias jp='jj git push'

# Git interoperability
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit --verbose'
alias gcm='git commit --amend --no-edit'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
gf() {
  if (( $# == 0 )); then
    git sync
  else
    git fetch origin "${1}:refs/remotes/origin/${1}"
  fi
}
alias gl='git pull'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always"
alias gm='git merge'
alias gma='git merge --abort'
alias gmm='git merge origin/$(basename "$(git symbolic-ref refs/remotes/origin/HEAD)")'
alias gp='git push -u origin HEAD'
alias gr='git reset'
alias grh='git reset --hard'
alias gs='git status'
alias grb='git rebase'
alias grbm='git rebase origin/$(basename "$(git symbolic-ref refs/remotes/origin/HEAD)")'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gss='git stash push -u'
alias gsp='git stash pop'
alias gnew='git checkout -b'
alias ghp='gh pr create --web'

boy() {
  curl -fsSL "https://cheat.sh/$1"
}

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
