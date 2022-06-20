# shellcheck shell=bash

# SCCACHE works fine on its own just by creating the directory,
# but we can put it on a ramdisk to avoid some pressure on the
# SSD. 

# /etc/fstab:
# # note that we allocate 8.125 gb for the drive, leaving a little spare for the cache
# sccachefs               /tmp/sccache tmpfs defaults,size=8320M,x-gvfs-show 0 0

# ~/.cargo/config:
# [build]
# rustc-wrapper = "/home/coriolinus/.cargo/bin/sccache"

if which sccache >/dev/null 2>&1 && [ -d /tmp/sccache ]; then
    export SCCACHE_DIR=/tmp/scccache
    export SCCACHE_CACHE_SIZE="8G"
fi