# shellcheck shell=sh

# Homebrew (macOS or Linux): the PATH part of `eval "$(brew shellenv)"`,
# without forking brew. Exports HOMEBREW_PREFIX for rc.d/completion.sh.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [ -x "$brew_prefix/bin/brew" ]; then
        export HOMEBREW_PREFIX="$brew_prefix"
        path_prepend "$HOMEBREW_PREFIX/sbin"
        path_prepend "$HOMEBREW_PREFIX/bin"
        break
    fi
done
unset brew_prefix
