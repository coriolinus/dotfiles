# shellcheck shell=bash

# .profile is for things like environment variables, like PATH etc

# silence a bunch of OSX warnings about locale: we don't actually want
# en_DE, and it's not supported anyway. It goes here instead of in
# profile.d to ensure that it's set before the warnings are generated.
export LC_ALL=en_US.UTF-8

if [ -e "$HOME"/dotfiles/ensurepath.sh ]; then
    # shellcheck source=ensurepath.sh
    source "$HOME"/dotfiles/ensurepath.sh
    ensurepath "$HOME"/bin
    ensurepath "$HOME"/.local/bin
fi

# run profile setup scripts
for script in ~/dotfiles/profile.d/*.sh; do
    # shellcheck disable=SC1090
    source "$script"
done

# when running in WSL or osx, we want to also execute .bashrc here; otherwise
# it doesn't handle .bashrc appropriately
if [ -f /proc/version ] && grep -iq Microsoft /proc/version || [[ "$OSTYPE" =~ darwin ]]; then
    # shellcheck source=.bashrc
    source ~/dotfiles/.bashrc
fi
