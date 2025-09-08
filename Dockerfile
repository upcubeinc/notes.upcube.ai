FROM ubuntu:22.04

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake pkg-config git \
    libgtk-3-dev libpoppler-glib-dev libxml2-dev \
    libsndfile1-dev liblua5.3-dev libzip-dev \
    xvfb x11vnc fluxbox \
    && rm -rf /var/lib/apt/lists/*

# Copy source code
WORKDIR /app
COPY . /app

# Build Xournal++
RUN mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# Expose VNC port so you can connect in browser
EXPOSE 5900

# Start a virtual X server and Xournal++
CMD ["bash", "-c", "Xvfb :0 -screen 0 1024x768x16 & fluxbox & x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900 & xournalpp"]
