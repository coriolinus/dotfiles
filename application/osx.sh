if ! [[ $PATH =~ (^|:)/usr/local/bin(:|$) ]]; then
    export PATH="$PATH:/usr/local/bin"
fi
