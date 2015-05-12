#!/usr/local/bin/python
import base64
import pprint
import urllib
import urllib2
import time
import logging
import os
import sys
import argparse
from datetime import datetime
from lxml import etree

COLLECTD_INTERVAL = int(float(os.getenv('COLLECTD_INTERVAL', 10)))

def main(server, host, username, password):
    base_url = 'http://%s:%s@%s/rrd_updates?' % (
        username, password, host)
    params = {
        'start': int(time.time()) - 10,
        'host': "true",
    }

    while True:
        data = urllib.urlencode(params)
        try:
            resp = urllib.urlopen(base_url + data)
            if not resp:
                continue
            root = etree.fromstring(resp.read())
        except Exception:
            logging.exception('borked')
            continue
        params['start'] = int(time.time()) - 10
        keys = [c.text for c in root[0][5]]
        keys.insert(0, 'ts')
        if len(root) < 2 or len(root[1]) < 1:
            time.sleep(1)
            continue
        values = [v.text for v in root[1][-1]]
        results = {}
        now = int(time.time())
        for index, key in enumerate(keys):
            if 'AVERAGE:host:' in key:
                name = key.split(':')[-1]
                results[name] = values[index]
        for k,v in results.iteritems():
            mtype = 'dom-0'
            if k.startswith('cpu'):
                if k[-1] == 'g':
                    continue
                mtype = 'cpu'
                vname = 'vcpu-'+k[-1]
                v = min([float(v) * 100, 100])
            elif k.startswith('pif'):
                ks = k.split('_')
                mtype = 'pif-%s' % ks[1]
                vname = 'if_%s_octets' % ks[2]
                v = int(float(v))
            elif k.startswith('load'):
                mtype = 'load'
                vname = 'load'
		v = '%s:%s:%s' % (v, v, v)
            elif k.startswith('memory'):
                ks = k.split('_')
                mtype = 'memory'
                vname = 'memory-%s' % ks[1]
            elif k.startswith('xapi'):
                ks = k.split('_')
                mtype = 'xapi'
                vname = 'memory-%s' % ks[1]
                if ks[1] == 'memory':
                    vname = 'memory-%s' % ks[2]
            else:
                continue
            sys.stdout.write('PUTVAL "%s/%s/%s" interval=%s N:%s\n' % (
                server, mtype, vname, COLLECTD_INTERVAL, v))
            sys.stdout.flush()
        time.sleep(COLLECTD_INTERVAL)

if __name__ == "__main__":
    logging.basicConfig(
        format='%(levelname)s: %(message)s',
        level=logging.INFO)

    parser = argparse.ArgumentParser(
        description='xenserver stats fetcher')
    parser.add_argument('--name', default='xenserver',
                        help='xenserver metric name (default: xenserver)')
    parser.add_argument('--host', default='127.0.0.1',
                        help='xenserver host (default: 127.0.0.1)')
    parser.add_argument('--debug', default=False, action='store_true',
                        help='debug logging (default: false)')
    parser.add_argument('--user', default='root',
                        help='user name (default: root)')
    parser.add_argument('--password', default='password',
                        help='password (default: password)')

    args = parser.parse_args()

    if args.debug:
        logger = logging.getLogger()
        logger.setLevel(logging.DEBUG)

    main(args.name, args.host, args.user, args.password)
