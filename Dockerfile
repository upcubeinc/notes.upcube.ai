# ---------- Build stage ----------
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update && \
    apt-mark hold systemd systemd-sysv && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      gettext \
      build-essential cmake pkg-config \
      lsb-release \
      libgtk-3-dev libpoppler-glib-dev libxml2-dev \
      libsndfile1-dev liblua5.3-dev libzip-dev \
      librsvg2-dev \
    && update-ca-certificates \
    && git config --system http.sslCAInfo /etc/ssl/certs/ca-certificates.crt \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Build
RUN mkdir build && cd build && cmake .. && make -j"$(nproc)" && make install


# ---------- Runtime stage ----------
FROM ubuntu:22.04 AS runtime
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update && \
    apt-mark hold systemd systemd-sysv && \
    apt-get install -y --no-install-recommends \
      libgtk-3-0 libpoppler-glib8 libxml2 \
      libsndfile1 liblua5.3-0 libzip4 \
      librsvg2-2 \
      xvfb x11vnc fluxbox \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local /usr/local

EXPOSE 5900
CMD ["bash","-c","Xvfb :0 -screen 0 1024x768x16 & fluxbox & x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900 & xournalpp"]





