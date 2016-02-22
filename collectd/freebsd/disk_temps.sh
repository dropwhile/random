#!/bin/sh

HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-10}"
## note: this binary needs to be suid to avoid
## junking up things with crazy sudo mess.
DISK_TEMPS="/usr/local/share/collectd/disk_temps"

while true; do
    $DISK_TEMPS | \
    while read disk temp; do
            echo "PUTVAL \"$HOSTNAME/disk-${disk}/smart_temperature-celcius\" interval=$INTERVAL N:$temp"
        done
    /bin/sleep "$INTERVAL"
done
