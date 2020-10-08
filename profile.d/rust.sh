# shellcheck shell=bash

if [ -e "$HOME"/dotfiles/ensurepath.sh ]; then
    # shellcheck source=../ensurepath.sh
    source "$HOME"/dotfiles/ensurepath.sh
    ensurepath "$HOME"/.cargo/bin
fi
