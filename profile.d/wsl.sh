# shellcheck shell=sh

# WSL: add back the few Windows directories we actually use.
#
# This assumes `appendWindowsPath=false` in /etc/wsl.conf (see README):
# with all of Windows' PATH appended, every lookup of a command which isn't
# installed has to search ~10 slow /mnt/c directories, costing ~8ms each.
# Appended, so Linux binaries always take precedence.
if [ -n "$WSL_DISTRO_NAME" ]; then
    path_append /mnt/c/WINDOWS/system32                        # clip.exe, cmd.exe, wsl.exe
    path_append /mnt/c/WINDOWS                                 # explorer.exe
    path_append /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0 # powershell.exe, for bin/clip

    # VS Code's `code`. Globbing for the Windows user dir costs ~20ms on
    # /mnt/c, so remember the result; `cached_eval_clear` resets it.
    wsl_cache="${XDG_CACHE_HOME:-$HOME/.cache}/bash-init/wsl-vscode-dir"
    if [ -r "$wsl_cache" ]; then
        IFS= read -r wsl_dir <"$wsl_cache"
    else
        for wsl_dir in /mnt/c/Users/*/AppData/Local/Programs/"Microsoft VS Code"/bin; do
            [ -d "$wsl_dir" ] && break
            wsl_dir=
        done
        mkdir -p "${wsl_cache%/*}" && printf '%s\n' "$wsl_dir" >"$wsl_cache"
    fi
    path_append "$wsl_dir"
    unset wsl_cache wsl_dir
fi
