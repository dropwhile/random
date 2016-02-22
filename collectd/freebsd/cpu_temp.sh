#!/bin/sh

HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-10}"

while true; do
    sysctl dev.cpu|grep -F temperature|sed -E 's/^dev.cpu.([0-9]+).temperature: ([0-9.]+)C/\1 \2/g' | while read core temp; do
        echo "PUTVAL \"$HOSTNAME/cpu-${core}/temperature-celcius\" interval=$INTERVAL N:$temp"
    done
    sleep "$INTERVAL"
done
