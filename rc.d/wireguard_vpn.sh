# shellcheck shell=bash

# Convenience aliases for a wireguard tunnel at /etc/wireguard/wg0.conf.
#
# /etc/wireguard is normally mode 700, so we can't check for wg0.conf itself
# without root; settle for the directory. wg-quick will complain if the
# config is missing.
if [ -d /etc/wireguard ] && command -v wg-quick >/dev/null 2>&1; then
    alias vpn-start='sudo wg-quick up wg0'
    alias vpn-stop='sudo wg-quick down wg0'
fi
