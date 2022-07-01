# shellcheck shell=bash

# This is only necessary on newer OSX, which previously had a system python2
# installation, and recently does not.
#
# For how to setup / fix the issue, see
# https://stackoverflow.com/questions/71591971/how-can-i-fix-the-zsh-command-not-found-python-error-macos-monterey-12-3

if command -v pyenv >/dev/null; then
    eval "$(pyenv init --path)"
fi
