# shellcheck shell=sh

# Go language
#
# Modern Go doesn't need GOROOT or GOPATH set; we just need the toolchain
# (if installed from the official tarball) and installed binaries on PATH.
path_prepend /usr/local/go/bin
path_prepend "${GOBIN:-${GOPATH:-$HOME/go}/bin}"
