# Go language
if which go >/dev/null 2>&1; then
    export GOPATH=$HOME/go
    export GOROOT=/usr/local/opt/go/libexec/
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN
    export PATH=$PATH:$GOROOT/bin
fi
