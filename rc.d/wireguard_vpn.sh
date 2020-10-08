# shellcheck shell=bash

# it is in principle possible to change this path
wg0_conf=/etc/wireguard/wg0.conf
confdir="$(dirname "$wg0_conf")"

if [ -d "$confdir" ] && [ ! -x "$confdir" ]; then
    echo >&2 "You do not have permission to inspect files within $confdir"
    echo >&2 "Consider running:"
    echo >&2 "  sudo chmod +x $confdir"
fi

if command -v nmcli >/dev/null 2>&1 && [ -f "$wg0_conf" ]; then
    # we _want_ substitution at definition time, not at execution time
    # shellcheck disable=SC2139
    alias vpn-start="sudo wg-quick up wg0"
    alias vpn-stop='sudo wg-quick down wg0'
fi
