#!/bin/bash
EVERYDNS_VER="0.1"
EVERYDNS_DOMAIN=
EVERYDNS_USER=
EVERYDNS_PASS=
OPENDNS_USER=
OPENDNS_PASS=

IP=$(wget -q http://www.whatismyip.com/automation/n09230945.asp -O -)

if [ -r "/tmp/oldip.txt" ]; then
  OLDIP=`cat /tmp/oldip.txt`
  if [ "$OLDIP" = "$IP" ]; then exit 0; fi
fi

echo $IP > /tmp/oldip.txt

## update everydns dynamic ip
wget -q -O - \
  --http-user="${EVERYDNS_USER}" \
  --http-password="${EVERYDNS_PASS}" \
  "http://dyn.everydns.net/index.php?ver=${EVERYDNS_VER}&ip=${IP}&domain=${EVERYDNS_DOMAIN}"

## update opendns, if in use
if [ -n "$OPENDNS_USER" ] && [ -n "$OPENDNS_PASS" ]; then
    wget -q -O - \
      --http-user="${OPENDNS_USER}" \
      --http-password="${OPENDNS_PASS}" \
      "https://updates.opendns.com/nic/update?ip=${IP}"
fi

