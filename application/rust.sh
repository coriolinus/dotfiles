if [ -d "$HOME/.cargo/bin" ] && ! [[ $PATH =~ (^|:)"$HOME"/.cargo/bin(:|$) ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

