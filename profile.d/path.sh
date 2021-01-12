# shellcheck shell=bash

# miscellaneous other paths which should be in PATH

if [ -e "$HOME"/dotfiles/ensurepath.sh ]; then
    # shellcheck source=../ensurepath.sh
    source "$HOME"/dotfiles/ensurepath.sh

    ensurepath "$HOME"/.local/bin
fi
