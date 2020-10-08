# shellcheck shell=bash

# Add pre-exec date function
# shellcheck source=.bash-preexec.sh
[[ -f ~/dotfiles/.bash-preexec.sh ]] && source ~/dotfiles/.bash-preexec.sh
preexec() { date; }
