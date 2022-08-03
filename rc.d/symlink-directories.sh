# shellcheck shell=bash

# We want to edit the readline configuration so that symlinks to directories
# still end up with a trailing slash on tab completion.
bind 'set mark-symlinked-directories on'
