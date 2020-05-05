#!/usr/bin/env bash

nas="//WDMyCloudEX4100/Public"

if ! [[ -d /mnt/z ]]; then
    sudo mkdir -p /mnt/z
fi

if ! command -v smbclient > /dev/null; then
    sudo apt install cifs-utils smbclient
fi

if ! grep -q "$nas" /etc/fstab; then
    echo "# /mnt/z is the nas drive and connects via samba" | sudo tee -a /etc/fstab
    echo "$nas /mnt/z cifs guest,uid=1000,iocharset=utf8 0 0" | sudo tee -a /etc/fstab
fi
