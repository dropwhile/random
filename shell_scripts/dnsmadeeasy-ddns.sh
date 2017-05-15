#!/bin/sh

DME_USER="xxx"
DME_PASS="yyy"
DME_ID="0000000"

TMP_FILE="/tmp/ddns.ip"
BASE_URL="https://cp.dnsmadeeasy.com/servlet/updateip"


get_pub_ip() {
    IP=$(curl -s 'http://myip.dnsomatic.com')
    printf "%s" "$IP"
}

get_cached_ip() {
    if [ ! -e "$TMP_FILE" ]; then
        return 1
    fi
    IP=$(< "$TMP_FILE")
    printf "%s" "$IP"
}

update_ddns() {
    local IP_ADDRESS="$1"
    result=$(curl -s "$BASE_URL?username=$DME_USER&password=$DME_PASS&id=$DME_ID&ip=$IP_ADDRESS")
    if [ "$result" == "success" ]; then
        return 0
    fi
    return 1
}

safe_create_file() {
    if [ ! -e "$TMP_FILE" ]; then
        touch "$TMP_FILE"
        if [ ! -e "$TMP_FILE" ]; then
            printf "Could not create %s" "$TMP_FILE"
            exit 1
        fi
        [ -e "$TMP_FILE" ] && [ -f "$TMP_FILE" ] && chmod 600 "$TMP_FILE"
    fi
}


# if [ "$(id -u)" -ne 0 ] || [ "$(whoami)" != "root" ]; then
#     printf "Must be run as root. aborting.\n"
#     exit 1
# fi

umask 177
OLDIP="$(get_cached_ip)"
CURIP="$(get_pub_ip)"

if [ "$OLDIP" != "$CURIP" ]; then
    safe_create_file
    printf "%s" "$CURIP" > "$TMP_FILE"
    if ! update_ddns "$CURIP"; then
        printf "Failed to update"
        exit 1
    fi
fi
