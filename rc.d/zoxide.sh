# shellcheck shell=bash

# zoxide: a faster successor to z.sh <https://github.com/ajeetdsouza/zoxide>
# Provides `z` (jump to a frecent directory) and `zi` (interactive picker).
#
# Install: `sudo apt install zoxide` or `cargo install zoxide`
# Import an old z.sh database: `zoxide import --from=z ~/.z`
cached_eval zoxide init bash
