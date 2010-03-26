#!/usr/bin/env python
from tumblr import Api
import sys

BLOG='xxxxx.tumblr.com'
USER='xxxxx'
PASSWORD='yyyyy'

if len(sys.argv) != 3:
    print "Usage: tumbl <photo> <caption>"
    sys.exit(-1)

photo = sys.argv[1]
ptext = sys.argv[2]

api = Api(BLOG,USER,PASSWORD)
post = api.write_photo(data=photo, caption=ptext)
print "Published: http://%s/post/%s" % (BLOG, post)
