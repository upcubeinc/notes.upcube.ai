# syntax=docker/dockerfile:1

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0 TZ=Etc/UTC

# Install Xournal++ and dependencies (including GTK icon themes)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      xournalpp \
      xvfb x11vnc fluxbox \
      novnc websockify \
      x11-utils x11-xserver-utils fonts-dejavu-core \
      adwaita-icon-theme yaru-theme-icon \
 && update-ca-certificates \
 && ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html \
 && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /usr/share/novnc
EXPOSE 12055

CMD ["/start.sh"]



