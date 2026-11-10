# shellcheck shell=bash

# Login bash shells read only this file, not ~/.profile or ~/.bashrc, so
# pull in both. Terminals on WSL and macOS start login shells; those on
# Linux desktops usually start non-login shells, which read ~/.bashrc and
# inherit the environment from the session.

# shellcheck source=.profile
[ -f ~/.profile ] && . ~/.profile

if [[ $- == *i* ]] && [ -f ~/.bashrc ]; then
    # shellcheck source=.bashrc
    . ~/.bashrc
fi
