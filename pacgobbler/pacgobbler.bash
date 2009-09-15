#!/bin/bash
##
## pacgobbler -  A shell script to coerce pacman into using on the fly 
##               metalinks configs.
##
## Copyright (c) 2009 elij <elij.mx [at] gmail.comm>
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.
## 
## usage: You sure that is a good idea? heh. ok. Hold on to your butt.
##  1. Install aria2
##  2. Put pacgobbler.bash somewhere, and make it executable.
##  3. Edit pacman.conf
##      XferCommand = /path/to/pacgobbler.bash %u
##  4. Try to update a package.
##
## notes: 
##  - The output is verbose. Aria doesn't appear to have a queit mode.
##  - If you want to modify any Aria2 options, use the variable below.
##    Just make sure to escape any single quotes, if needed.
##  - Phrakture can lift a car over his head, when powered by sweet sweet...
##    TACOS!
##

## feed aria2c some options
ARIA_OPTS='-p --lowest-speed-limit=10K --enable-http-keep-alive=true --enable-http-pipelining=true --auto-file-renaming=false --allow-overwrite=true --enable-direct-io=true -U "pacgobbler" -s 1 -C 10 --file-allocation=none --metalink-preferred-protocol=http'


getmirrorlist() {
    REPO=$1
    FNAME=$2

    # massage the mirror list
    LIST=$(cat /etc/pacman.d/mirrorlist|grep -Ei '^server.='|sed -r 's#^server[ ]?=[ ]?##gi;')

    # remove main arch ftp servers
    LIST=$(echo $LIST | sed -r 's#ftp://ftp.archlinux.org[^ ]* ##g;')

    # replace with current repo being fetched from
    # make sure to use " on the sed here instead of ' (or you cant sub in repo)
    LIST=$(echo $LIST | sed -r "s#\\\$repo#${REPO}#g;")
    
    MIRROR=""
    for y in $LIST; do
        MIRROR="${MIRROR} ${y}/${FNAME}"
    done
}

metalink() {
    MIRRORS=$1
    BFNAME=$2

    ## strip -arch.pkg.tar.gz from the end of the bfname
    DFNAME=${BFNAME%-*\.pkg\.tar\.gz}
    ## get pkg details
    CSIZE=$(cat /var/lib/pacman/sync/${REPONAME}/${DFNAME}/desc | grep -A1 -F CSIZE|tail -n 1)
    MD5SUM=$(cat /var/lib/pacman/sync/${REPONAME}/${DFNAME}/desc | grep -A1 -F MD5SUM|tail -n 1)

    METALINK="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    METALINK="${METALINK}\n<metalink version=\"3.0\" generator=\"pacaria\" xmlns=\"http://www.metalinker.org/\">"
    METALINK="${METALINK}\n<files>\n<file name=\"${BFNAME}\">"
    METALINK="${METALINK}\n<size>${CSIZE}</size>"
    METALINK="${METALINK}\n<verification>\n<hash type=\"md5\">${MD5SUM}</hash>\n</verification>"

    RESOURCES="<resources>"
    for z in $MIRRORS; do
        TYPE=$(echo ${z} | sed -r 's#^(.*)://.*$#\1#;')
        MLNK="<url type=\"${TYPE}\">${z}</url>"
        RESOURCES="${RESOURCES}\n${MLNK}"
    done
    RESOURCES="${RESOURCES}\n</resources>"
    METALINK="${METALINK}\n${RESOURCES}\n</file>\n</files>\n</metalink>"
}

URL=$1
BFNAME=$(basename "${URL}")
ARCH=$(echo "${BFNAME}" | sed -r 's#.*-(.*).pkg.tar.gz#\1#;')

## a repo db update. just fetch the file from the default repo url
if $(echo ${BFNAME} | grep -iq 'db.tar.gz'); then
    exec aria2c ${ARIA_OPTS} $URL
    exit 0
fi

## not a repo db update
REPONAME=$(basename $(dirname $(dirname $(dirname "${URL}"))))
getmirrorlist "${REPONAME}" "${BFNAME}"
metalink "${MIRROR}" "${BFNAME}"
exec echo -e "${METALINK}\n" | aria2c ${ARIA_OPTS} -M -

