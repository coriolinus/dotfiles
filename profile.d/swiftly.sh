# shellcheck shell=sh

# swiftly: swift toolchain manager <https://www.swift.org/install/>
#
# Equivalent to sourcing ~/.local/share/swiftly/env.sh, which the installer
# wants to add, but that file uses bashisms and hardcodes the home directory.
if [ -d "$HOME/.local/share/swiftly" ]; then
    export SWIFTLY_HOME_DIR="$HOME/.local/share/swiftly"
    export SWIFTLY_BIN_DIR="$SWIFTLY_HOME_DIR/bin"
    export SWIFTLY_TOOLCHAINS_DIR="$SWIFTLY_HOME_DIR/toolchains"
    PATH="$SWIFTLY_BIN_DIR:$PATH"
fi
