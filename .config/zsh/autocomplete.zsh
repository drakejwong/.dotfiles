# Figure out the short hostname
if [[ "$OSTYPE" = darwin* ]]; then          
	# OS X's $HOST changes with dhcp, etc., so use ComputerName if possible.
	SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
else
	SHORT_HOST=${HOST/.*/}
fi

# the auto complete dump is a cache file where ZSH stores its auto complete data, for faster load times
local ZSH_COMPDUMP="$HOME/.cache/zsh/acdump-${SHORT_HOST}-${ZSH_VERSION}"  #where to store autocomplete data

autoload -U compinit                                    # Autoload auto completion
compinit -i -d "${ZSH_COMPDUMP}"                        # Init auto completion; tell where to store autocomplete dump
zstyle ':completion:*' menu select                      # Have the menu highlight as we cycle through options
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     # Case-insensitive (uppercase from lowercase) completion
setopt COMPLETE_IN_WORD                                 # Allow completion from within a word/phrase
setopt ALWAYS_TO_END                                    # When completing from the middle of a word, move cursor to end of word
setopt MENU_COMPLETE                                    # When using auto-complete, put the first option on the line immediately
setopt COMPLETE_ALIASES                                 # Turn on completion for aliases as well
setopt LIST_ROWS_FIRST                                  # Cycle through menus horizontally instead of vertically
