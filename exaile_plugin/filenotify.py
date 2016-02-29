"""
This plugin will drop a file in the .exaile dir with information
about the current playing song.
"""

import gtk
import xl.plugins as plugins
import os
import os.path
import textwrap

PLUGIN_NAME = "Now Playing Information File Plugin"
PLUGIN_AUTHORS = ['elij <github.com/cactus>',]
PLUGIN_VERSION = '0.1'
PLUGIN_DESCRIPTION = textwrap.dedent("""
    This plugin will drop a file in the .exaile dir
    (called nowplaying.txt) with information about the
    current playing song.""").strip()
PLUGIN_ENABLED = False

b = gtk.Button()
PLUGIN_ICON = b.render_icon(gtk.STOCK_MEDIA_PLAY, gtk.ICON_SIZE_MENU)
b.destroy()

CONNS = plugins.SignalContainer()
PLAYx_ID = []

def initialize():
    """Called when the plugin is enabled"""
    global PLAYx_ID
    PLAYx_ID.append(APP.player.connect('play-track', play_track))
    PLAYx_ID.append(APP.player.connect('stop-track', stop_track))
    return True

def destroy():
    """Called when the plugin is disabled"""
    global PLAYx_ID
    for x in PLAYx_ID:
        APP.disconnect(x)
    PLAYx_ID = []

def stop_track(exaile, track):
    """Called when playback on a track starts ("stop-track" event)"""
    home = os.path.expanduser('~')
    pfile = os.path.join(home, '.exaile', 'now_playing.txt')
    if os.path.isfile(pfile):
        os.remove(pfile)

def play_track(exaile, track):
    """Called when playback on a track starts ("play-track" event)"""
    home = os.path.expanduser('~')
    pfile = os.path.join(home, '.exaile', 'now_playing.txt')
    FILE = open(pfile, 'w')
    FILE.write("title:  %s\n" % getattr(track,'title'))
    FILE.write("artist: %s\n" % track.artist)
    FILE.write("album:  %s\n" % track.album)
    FILE.close()

