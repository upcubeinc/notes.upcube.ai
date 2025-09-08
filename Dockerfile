FROM ubuntu:22.04

# Avoid tzdata interactive prompt
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    build-essential cmake pkg-config git \
    libgtk-3-dev libpoppler-glib-dev libxml2-dev \
    libsndfile1-dev liblua5.3-dev libzip-dev \
    xvfb x11vnc fluxbox tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app
RUN mkdir build && cd build && cmake .. && make -j$(nproc) && make install

EXPOSE 5900 8080
CMD ["bash", "-c", "Xvfb :0 -screen 0 1024x768x16 & fluxbox & x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900"]

