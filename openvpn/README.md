## build

    go get golang.org/x/crypto/bcrypt
    GOOS=freebsd go build -ldflags="-s -w" auth-bcrypt-file.go

## usage

    auth-user-pass-verify "/sbin/auth-bcrypt-file /etc/openvpn.creds" via-file
