#!/usr/bin/env bash
# Point ~/.profile, ~/.bash_profile and ~/.bashrc at this repo.
#
# Each becomes a small machine-local file which sources the shared version
# from here. Machine-specific setup, including the lines which installers
# like to append to these files, goes in the local files and never touches
# the repo. Safe to re-run.
set -euo pipefail

dotfiles=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [[ $dotfiles != "$HOME/dotfiles" ]]; then
    echo >&2 "error: these scripts assume the repo is at ~/dotfiles, not $dotfiles"
    exit 1
fi

install_stub() {
    local name=$1 shared=$2
    local target="$HOME/$name"
    local source_line=". \"\$HOME/dotfiles/$shared\""

    if [[ -f $target && ! -L $target ]] && grep -qxF "$source_line" "$target"; then
        echo "ok:        ~/$name"
        return
    fi

    if [[ $target -ef $dotfiles/$shared ]]; then
        # an old-style hard or symbolic link to the shared file; nothing to keep
        rm "$target"
    elif [[ -e $target || -L $target ]]; then
        local backup
        backup="$target.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
        mv "$target" "$backup"
        echo "backed up: ~/$name -> $backup"
    fi

    cat >"$target" <<STUB
# Machine-local; not tracked. Shared setup lives in ~/dotfiles/$shared.
$source_line

# Machine-specific additions (and lines appended by installers) go below.
STUB
    echo "installed: ~/$name"
}

install_stub .profile profile.sh
install_stub .bash_profile bash_profile.sh
install_stub .bashrc bashrc.sh
