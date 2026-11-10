# shellcheck shell=sh

# bun: javascript runtime <https://bun.sh>
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    path_prepend "$BUN_INSTALL/bin"
fi
