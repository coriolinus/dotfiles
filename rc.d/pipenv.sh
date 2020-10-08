# shellcheck shell=bash

# pipenv completions
if which pipenv >/dev/null 2>&1; then
    eval "$(pipenv --completion)"
fi
