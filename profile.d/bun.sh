# shellcheck shell=sh

# bun: javascript runtime <https://bun.sh>
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    PATH="$BUN_INSTALL/bin:$PATH"
fi
