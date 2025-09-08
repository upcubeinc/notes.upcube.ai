#!/bin/bash
set -e

# Start virtual X server
Xvfb :0 -screen 0 1280x800x16 &

# Start lightweight window manager
fluxbox &

# Start VNC server
x11vnc -display :0 -forever -shared -nopw -rfbport 5900 -noxdamage &

# Start noVNC (websockify)
websockify --web /usr/share/novnc 12055 localhost:5900 &

# Launch Xournal++
exec xournalpp
