# run application setup scripts
for script in ~/dotfiles/application/*.sh; do
    source "$script"
done

# Add pre-exec date function
[[ -f ~/dotfiles/.bash-preexec.sh ]] && source ~/dotfiles/.bash-preexec.sh
preexec() { date; }
