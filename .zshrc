export PROMPT=" %F{blue}%~%f ---> %F{red}thyruh%f: "

# Aliases
alias cls='clear && cd'
alias ..='cd ..'
alias ...='cd ../..'
alias 2.='cd ../../..'
alias 3.='cd ../../../..'
alias sn='sudo shutdown now'
alias sr='sudo reboot'
alias :q='vim .'
alias nautilus='nautilus . &'
alias dwbackup='mv ~/Downloads/* ~/dnBackup/ && echo "Done"'

# Add paths to $PATH
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/thyruh/.local/bin:~/ded/ded:/home/thyruh/.local/opt/go/bin"
export PATH=$PATH:/snap/bin

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/.local/opt/go/bin

setopt ignoreeof

set -o vi  # Vim mode
setxkbmap -layout "us,ru" -option "grp:alt_shift_toggle,caps:escape"

[ -f "/home/thyruh/.ghcup/env" ] && . "/home/thyruh/.ghcup/env" # ghcup-env
clear
