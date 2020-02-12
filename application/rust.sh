if [ -e "$HOME"/dotfiles/ensurepath.sh ]; then
    source "$HOME"/dotfiles/ensurepath.sh
    ensurepath "$HOME"/.cargo/bin
fi