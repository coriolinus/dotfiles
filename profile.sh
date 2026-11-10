# shellcheck shell=sh

# .profile is for environment variables, like PATH. Login shells read it,
# and so do graphical sessions on many Linux desktops, via /bin/sh: so it
# and everything in profile.d must be POSIX sh.

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
for script in "$HOME"/dotfiles/profile.d/*.sh; do
    # shellcheck disable=SC1090
    . "$script"
done
unset script

# personal bin dirs take precedence over everything else
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
export PATH
