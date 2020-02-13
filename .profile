# .profile is for things like environment variables, like PATH etc

if [ -e "$HOME"/dotfiles/ensurepath.sh ]; then
    source "$HOME"/dotfiles/ensurepath.sh
    ensurepath "$HOME"/bin
    ensurepath "$HOME"/.local/bin
fi

# run profile setup scripts
for script in ~/dotfiles/profile.d/*.sh; do
    source "$script"
done
