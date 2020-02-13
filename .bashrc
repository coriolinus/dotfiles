# this is used for interactive shells; it is good for aliases, pre-exec commands,
# prompt, functions, etc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# run rc setup scripts
for script in ~/dotfiles/rc.d/*.sh; do
    source "$script"
done

# source the date setup script last so we don't get a bunch of spurious dates on startup
source ~/dotfiles/date.sh
