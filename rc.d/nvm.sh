# shellcheck shell=bash

# Node version manager
# Install with instructions at <https://github.com/nvm-sh/nvm#installing-and-updating>

NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    export NVM_DIR
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
