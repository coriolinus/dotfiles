ensurepath () {
    wantpath="$1"
    if [ -d "$wantpath" ] && ! [[ $PATH =~ (^|:)"$wantpath"(:|$) ]]; then
        export PATH="$PATH:$wantpath"
    fi
}