# shellcheck shell=sh

# volta: node toolchain manager <https://volta.sh>
if [ -d "$HOME/.volta" ]; then
    export VOLTA_HOME="$HOME/.volta"
    PATH="$VOLTA_HOME/bin:$PATH"
fi
