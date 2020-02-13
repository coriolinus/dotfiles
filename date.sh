# Add pre-exec date function
[[ -f ~/dotfiles/.bash-preexec.sh ]] && source ~/dotfiles/.bash-preexec.sh
preexec() { date; }
