# shellcheck shell=bash

# enable programmable completion features, unless /etc/profile or
# /etc/bash.bashrc already did
if ! shopt -oq posix && [[ -z ${BASH_COMPLETION_VERSINFO-} ]]; then
    for bash_completion in \
        ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"} \
        ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/etc/bash_completion"} \
        /usr/share/bash-completion/bash_completion \
        /etc/bash_completion
    do
        if [[ -r $bash_completion ]]; then
            # shellcheck disable=SC1090
            . "$bash_completion"
            break
        fi
    done
    unset bash_completion
fi
