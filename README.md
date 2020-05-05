# dotfiles

For the purpose of standardizing my shells across a variety of machines, it turns out to be easiest to just keep my dotfiles in git.

## Usage

```sh
cd ~
git clone git@github.com:coriolinus/dotfiles.git
ln -f ~/dotfiles/.profile .profile
ln -f ~/dotfiles/.bash_profile .bash_profile
ln -f ~/dotfiles/.bashrc .bashrc
```

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