# ---------- Build stage ----------
FROM ubuntu:22.04 AS build

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Prevent systemd from being installed/triggered
RUN apt-get update && \
    apt-mark hold systemd systemd-sysv && \
    apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config git \
      libgtk-3-dev libpoppler-glib-dev libxml2-dev \
      libsndfile1-dev liblua5.3-dev libzip-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Build Xournal++
RUN mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# ---------- Runtime stage ----------
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Prevent systemd again in runtime
RUN apt-get update && \
    apt-mark hold systemd systemd-sysv && \
    apt-get install -y --no-install-recommends \
      libgtk-3-0 libpoppler-glib8 libxml2 \
      libsndfile1 liblua5.3-0 libzip4 \
      xvfb x11vnc fluxbox \
    && rm -rf /var/lib/apt/lists/*

# Copy built binaries
COPY --from=build /usr/local /usr/local

# Expose VNC port (for remote access)
EXPOSE 5900

# Start virtual X server + window manager + VNC server + Xournal++
CMD ["bash", "-c", "Xvfb :0 -screen 0 1024x768x16 & fluxbox & x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900 & xournalpp"]



