alias ls="ls -h --color='auto'"
alias l='ls -lA'

# Search running processes. Usage: psg <process_name>
alias psg="ps aux $( [[ -n "$(uname -a | grep CYGWIN )" ]] && echo '-W') | grep -i $1"

# cp with progress bar 
alias cpv="rsync -poghb --backup-dir=/tmp/rsync -e /dev/null --progress --"

# list last 10 dirs
alias d='dirs -v | head -10'
