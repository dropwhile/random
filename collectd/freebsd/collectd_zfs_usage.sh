#!/bin/sh

HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-10}"
ZFS_NAME="${1:-tank}"

while true; do
    # tank
    FREE=$(zfs list -p "${ZFS_NAME}"|awk '$1=="'"${ZFS_NAME}"'"{print 100*($3/($2+$3))}')
    USED=$(zfs list -p "${ZFS_NAME}"|awk '$1=="'"${ZFS_NAME}"'"{print 100*($2/($2+$3))}')
    echo "PUTVAL \"$HOSTNAME/df-${ZFS_NAME}/percent_bytes-free\" interval=$INTERVAL N:$FREE"
    echo "PUTVAL \"$HOSTNAME/df-${ZFS_NAME}/percent_bytes-used\" interval=$INTERVAL N:$USED"
    sleep "$INTERVAL"
done
