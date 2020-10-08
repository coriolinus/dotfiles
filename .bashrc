# we're always going to source this, not execute it
# shellcheck shell=bash

# this is used for interactive shells; it is good for aliases, pre-exec commands,
# prompt, functions, etc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# run rc setup scripts
for script in ~/dotfiles/rc.d/*.sh; do
    # shellcheck disable=1090
    source "$script"
done

# source the date setup script last so we don't get a bunch of spurious dates on startup
# shellcheck source=date.sh
source ~/dotfiles/date.sh
