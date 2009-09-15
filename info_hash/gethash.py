#!/usr/bin/env python
# Simple stupid script to get the info_hash of a torrent file
import sys
import hashlib
from bencode import bencode
from bencode import bdecode

file = open(sys.argv[1], 'rb')
print hashlib.sha1(bencode(bdecode(file.read())['info'])).hexdigest()

