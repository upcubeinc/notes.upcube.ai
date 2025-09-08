# syntax=docker/dockerfile:1

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0 TZ=Etc/UTC

# Install Xournal++ and noVNC stack
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      xournalpp \
      xvfb x11vnc fluxbox \
      novnc websockify \
 && update-ca-certificates \
 && ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/novnc
EXPOSE 12055

# Start X server, WM, VNC, websockify, then Xournal++
CMD bash -lc '\
  Xvfb :0 -screen 0 1280x800x16 & \
  fluxbox & \
  x11vnc -display :0 -forever -shared -nopw -rfbport 5900 & \
  websockify --web /usr/share/novnc 12055 localhost:5900 & \
  exec xournalpp'


