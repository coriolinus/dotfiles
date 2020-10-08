# shellcheck shell=bash

# Bash completion
if which brew >/dev/null 2>&1; then
    if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
        # shellcheck disable=SC1090
        . "$(brew --prefix)"/etc/bash_completion
    fi
fi
