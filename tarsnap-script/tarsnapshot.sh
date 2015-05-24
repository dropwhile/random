#!/bin/sh

# Tarsnap backup script
# Original Written by Tim Bishop, 2009.
#  http://www.bishnet.net/tim/tarsnap/run.sh
# Modified by Eli Janssne, 2015.

HOSTNAME="$(hostname -s)"
EXTRA_FLAGS=

# Directories to backup
TARSNAPFILES="/usr/local/etc/tarsnapfiles"

# Number of daily backups to keep
DAILY=7

# Number of weekly backups to keep
WEEKLY=4
# Which day to do weekly backups on
# 1-7, Monday = 1
WEEKLY_DAY=1

# Number of monthly backups to keep
MONTHLY=3
# Which day to do monthly backups on
# 01-31 (leading 0 is important)
MONTHLY_DAY=01

# Path to tarsnap
TARSNAP="/usr/local/bin/tarsnap"

# end of config

## check for root
if [ "$(id -u)" -ne 0 ]; then
    printf "%s\n" "Please run as root"
    exit
fi

if [ `whoami` != root ]; then
    printf "%s" "Must be run as root. aborting."
    exit 1
fi

# day of week: 1-7, monday = 1
DOW=$(date +%u)
# day of month: 01-31
DOM=$(date +%d)
# month of year: 01-12
MOY=$(date +%m)
# year
YEAR=$(date +%Y)
# time
TIME=$(date +%H%M%S)

# Backup name
if [ X"${DOM}" = X"${MONTHLY_DAY}" ]; then
	# monthly backup
	BACKUP="${HOSTNAME}-${YEAR}${MOY}${DOM}-${TIME}-monthly"
elif [ X"$DOW" = X"$WEEKLY_DAY" ]; then
	# weekly backup
	BACKUP="${HOSTNAME}-${YEAR}${MOY}${DOM}-${TIME}-weekly"
else
	# daily backup
	BACKUP="${HOSTNAME}-${YEAR}${MOY}${DOM}-${TIME}-daily"
fi

printf "%s\n" "==> creating $BACKUP"
$TARSNAP $EXTRA_FLAGS -cvf $BACKUP -T $TARSNAPFILES

EX=$?
if [ $EX -ne 0 ]; then
    printf "%s\n" "==> Error creating backup"
    exit $EX
fi

# Backups done, time for cleaning up old archives

# using tail to find archives to delete, but its
# +n syntax is out by one from what we want to do
# (also +0 == +1, so we're safe :-)
DAILY=$(expr $DAILY + 1)
WEEKLY=$(expr $WEEKLY + 1)
MONTHLY=$(expr $MONTHLY + 1)

# Do deletes
TMPFILE=$(mktemp /tmp/tarsnapshot.XXXXXX.tmp)
$TARSNAP --list-archives | grep -E "^${HOSTNAME}-" > $TMPFILE

DELARCHIVES=""
for i in $(grep -E "^${HOSTNAME}-[[:digit:]]{8}-[[:digit:]]{6}-daily$" $TMPFILE | sort -rn | tail -n +${DAILY}); do
    printf "%s\n" "==> delete $i"
    DELARCHIVES="$DELARCHIVES -f $i"
done
for i in $(grep -E "^${HOSTNAME}-[[:digit:]]{8}-[[:digit:]]{6}-weekly$" $TMPFILE | sort -rn | tail -n +${WEEKLY}); do
    printf "%s\n" "==> delete $i"
    DELARCHIVES="$DELARCHIVES -f $i"
done
for i in $(grep -E "^${HOSTNAME}-[[:digit:]]{8}-[[:digit:]]{6}-monthly$" $TMPFILE | sort -rn | tail -n +${MONTHLY}); do
    printf "%s\n" "==> delete $i"
    DELARCHIVES="$DELARCHIVES -f $i"
done

if [ X"$DELARCHIVES" != X ]; then
	printf "%s\n" "==> delete $DELARCHIVES"
	$TARSNAP -d $DELARCHIVES
fi

rm -f $TMPFILE
