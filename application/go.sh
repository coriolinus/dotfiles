# Go language
if which go; then
    export GOPATH=$HOME/go
    export GOROOT=/usr/local/opt/go/libexec/
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN
    export PATH=$PATH:$GOROOT/bin
fi
