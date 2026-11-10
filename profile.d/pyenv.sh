# shellcheck shell=sh

# pyenv: python version manager <https://github.com/pyenv/pyenv>
#
# This is what `pyenv init --path` does, without its two subprocesses and
# its `pyenv rehash` (together ~60ms per login). pyenv rehashes the shims
# itself after `pyenv install` and `pip install`; if a new executable is
# ever missing, run `pyenv rehash` by hand.
if [ -x "$HOME/.pyenv/bin/pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    path_prepend "$PYENV_ROOT/bin"
    path_prepend "$PYENV_ROOT/shims"
fi
