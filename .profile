# shellcheck shell=bash

# .profile is for things like environment variables, like PATH etc

# silence a bunch of OSX warnings about locale: we don't actually want
# en_DE, and it's not supported anyway. It goes here instead of in
# profile.d to ensure that it's set before the warnings are generated.
export LC_ALL=en_US.UTF-8

# path_prepend DIR: put DIR at the front of PATH if it exists and isn't there yet
path_prepend() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

# path_append DIR: put DIR at the end of PATH if it exists and isn't there yet
path_append() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$PATH:$1" ;;
    esac
}

# run profile setup scripts
for script in ~/dotfiles/profile.d/*.sh; do
    # shellcheck disable=SC1090
    source "$script"
done
unset script

# personal bin dirs take precedence over everything else
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
export PATH

# when running in WSL or osx, we want to also execute .bashrc here; otherwise
# it doesn't handle .bashrc appropriately
if [ -f /proc/version ] && grep -iq Microsoft /proc/version || [[ "$OSTYPE" =~ darwin ]]; then
    # shellcheck source=.bashrc
    source ~/dotfiles/.bashrc
fi
