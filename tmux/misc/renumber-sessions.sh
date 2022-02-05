#!/bin/bash
#
# Renumbers tmux sessions.
# from https://github.com/maximbaz/dotfiles/commit/925a5b88a8263805a5a24c6198dad23bfa62f44d

new=0
for old in $(tmux list-sessions -F '#S' | grep '^[0-9]\+$' | sort -n); do
    tmux rename -t $old $new
    new=$((new+1))
done
