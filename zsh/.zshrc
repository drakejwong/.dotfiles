# Keep machine-specific executables available without loading completion code
# before the first prompt.
[[ -r "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"

# Shims select the configured tool version without running mise's shell hook at
# startup. This repository does not currently define mise-managed environment
# variables that require the hook.
path=("$HOME/.local/share/mise/shims" $path)

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_zsh_plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
fpath=("$_zsh_cache_dir/completions" "$_zsh_plugin_dir/zsh-completions/src" "$HOME/.zfunc" $fpath)
autoload -Uz edit-command-line
zle -N edit-command-line

# Completion and display plugins are loaded after the first prompt, when ZLE is
# idle. This keeps startup fast without removing interactive features.
_zsh_deferred_setup() {
  autoload -Uz compinit
  compinit -C -d "$_zsh_cache_dir/zcompdump"

  [[ -r "$_zsh_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$_zsh_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$_zsh_plugin_dir/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] &&
    source "$_zsh_plugin_dir/zsh-history-substring-search/zsh-history-substring-search.zsh"

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  [[ -r "$_zsh_cache_dir/fzf-init.zsh" ]] && source "$_zsh_cache_dir/fzf-init.zsh"
  [[ -r "$HOME/.fzf-git.sh" ]] && source "$HOME/.fzf-git.sh"
  [[ -r "$_zsh_cache_dir/zoxide-init.zsh" ]] && source "$_zsh_cache_dir/zoxide-init.zsh"
  [[ -r "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

  # Syntax highlighting must be loaded after all other widgets.
  [[ -r "$_zsh_plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$_zsh_plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
}

if [[ -r "$_zsh_plugin_dir/zsh-defer/zsh-defer.plugin.zsh" ]]; then
  source "$_zsh_plugin_dir/zsh-defer/zsh-defer.plugin.zsh"
  zsh-defer _zsh_deferred_setup
else
  _zsh_deferred_setup
fi

setopt extended_history hist_expire_dups_first hist_ignore_dups
setopt hist_ignore_space inc_append_history hist_verify autocd

zmodload zsh/complist
bindkey -e
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
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

export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --exclude .git'
_fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1" }
show_file_or_dir_preview='if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

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

if [[ ! -r "$_zsh_cache_dir/starship-init.zsh" ]] && (( $+commands[starship] )); then
  mkdir -p "$_zsh_cache_dir"
  starship init zsh >| "$_zsh_cache_dir/starship-init.zsh"
fi
[[ -r "$_zsh_cache_dir/starship-init.zsh" ]] && source "$_zsh_cache_dir/starship-init.zsh"
