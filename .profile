# Constants
export EDITOR=nano

# Colors
INVERT=`tput smso`
OFFINVERT=`tput rmso`
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
PURPLE="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
RESET="\[$(tput sgr0)\]"

# Prompt
export PS1="${BLUE}${INVERT}\u@\h${RESET} ${GREEN}\w${RESET}\n\$ "

# run application setup scripts
for script in ~/dotfiles/application/*.sh; do
    source "$script"
done

# Add pre-exec date function
[[ -f ~/dotfiles/.bash-preexec.sh ]] && source ~/dotfiles/.bash-preexec.sh
preexec() { date; }
