# we're always going to source this, not execute it
# shellcheck shell=bash

# this is used for interactive shells; it is good for aliases, pre-exec commands,
# prompt, functions, etc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# cached_eval COMMAND [ARGS...]
#
# Like `eval "$(COMMAND ARGS...)"`, for tools which emit shell setup code,
# but caches the output so we don't fork on every shell startup. The cache
# is keyed on the whole command line, and regenerated when COMMAND's binary,
# or any argument which is an absolute path to a file, is newer than it. To
# force a refresh (e.g. after editing a config the tool finds by itself),
# run `cached_eval_clear`.
# Returns nonzero without doing anything if COMMAND isn't installed.
cached_eval() {
    local cache key="$*" dep stale=
    # `hash` resolves the binary into BASH_CMDS without forking a subshell
    hash "$1" 2>/dev/null || return 1
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/bash-init/${key//[^[:alnum:]._-]/_}.sh"
    [[ -s $cache ]] || stale=1
    for dep in "${BASH_CMDS[$1]}" "${@:2}"; do
        [[ $dep == /* && -f $dep && $dep -nt $cache ]] && stale=1
    done
    if [[ $stale ]]; then
        mkdir -p "${cache%/*}"
        "$@" >"$cache" || { rm -f "$cache"; return 1; }
    fi
    # shellcheck disable=SC1090
    source "$cache"
}

cached_eval_clear() {
    rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/bash-init"
}

# run rc setup scripts
for script in ~/dotfiles/rc.d/*.sh; do
    # shellcheck disable=1090
    source "$script"
done

# sdkman wants to be initialized last so its candidates take precedence on PATH
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    # shellcheck source=/dev/null
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
