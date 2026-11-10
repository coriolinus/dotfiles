# dotfiles

For the purpose of standardizing my shells across a variety of machines, it turns out to be easiest to just keep my dotfiles in git.

## Usage

```sh
cd ~
git clone git@github.com:coriolinus/dotfiles.git
~/dotfiles/install.sh
```

`install.sh` replaces `~/.profile`, `~/.bash_profile` and `~/.bashrc` with
small machine-local files which source `profile.sh`, `bash_profile.sh` and
`bashrc.sh` from this repo, backing up anything that was there. Put
machine-specific setup in those local files; installers which append to
them will no longer modify the repo.

## Layout

- `profile.sh` + `profile.d/*.sh`: environment (PATH etc.). Must be POSIX
  sh, because graphical sessions may read `~/.profile` with `/bin/sh`.
  `path_prepend`/`path_append` are available to `profile.d` scripts.
- `bashrc.sh` + `rc.d/*.sh`: interactive bash setup (aliases, prompt,
  completion). `cached_eval CMD...` is available to `rc.d` scripts
  for tools which print shell init code; run `cached_eval_clear` to
  refresh the cache.
- `bash_profile.sh`: login bash shells read only `~/.bash_profile`, so it
  loads both of the above.

### Keeping startup fast

Sourcing many small files is cheap (~0.1ms each). What's expensive is
forking processes (`$(...)`, `which`, `tput`, `foo init`) and looking up
commands which aren't installed, especially on WSL where every Windows
directory on PATH is slow to search. So in startup scripts:

- test for a directory or file rather than `command -v` where possible,
  and never use `which`;
- prefer static exports, or `cached_eval`, over `eval "$(tool init)"`.

To profile startup:

```sh
PS4='+${EPOCHREALTIME} ${BASH_SOURCE}:${LINENO} ' bash -xlic exit 2>&1 | less
```

### WSL: Windows PATH

Searching the Windows directories that WSL appends to PATH costs ~8ms per
lookup of a command which isn't installed. Disable that in `/etc/wsl.conf`:

```ini
[interop]
appendWindowsPath=false
```

then run `wsl --shutdown` from Windows. `profile.d/wsl.sh` adds back the
Windows directories we actually use.

### Automatically Connect Boxcryptor

On unixy systems, we can automatically connect to Boxcryptor. 

- Ensure that Dropbox is syncing or linked to `~/Dropbox`
- Ensure that there is an empty directory at `~/Boxcryptor`
- Install necessary tooling:

    ```sh
    sudo apt install encfs libsecret-tools
    ```

- Add the boxcryptor password to the keyring:

    ```sh
    secret-tool store --label='Personal Boxcryptor' boxcryptor personal
    ```

    This will present a password prompt; enter the boxcryptor password, _not_ the system password.

Boxcryptor will then automatically mount when the profile is sourced.

### Clipboard access on WSL

Ubuntu has a nice `clip` command which doesn't work by default on WSL.
There's a shim to make it work in this repo:

```sh
mkdir -p ~/bin
ln -s ~/dotfiles/bin/clip ~/bin/clip
```