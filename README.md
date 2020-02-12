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
