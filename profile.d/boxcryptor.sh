# shellcheck shell=bash

# This takes a bit of setup, but if everything is in place, automatically
# connects securely to Boxcryptor.
#
# Note: this depends on secret-tool being configured appropriately:
#     sudo apt install libsecret-tools
#     secret-tool store --label='Personal Boxcryptor' boxcryptor personal
# Then, at the prompt, do _not_ enter the sudo password; enter the password
# for the personal boxcryptor.

if  [[ -d "$HOME"/Dropbox/BoxCryptor ]] &&
    [[ -d "$HOME"/Boxcryptor ]] &&
    command -v encfs >/dev/null &&
    command -v secret-tool >/dev/null; then
        secret-tool lookup boxcryptor personal |\
        encfs -S "$HOME"/Dropbox/BoxCryptor "$HOME"/Boxcryptor
fi
