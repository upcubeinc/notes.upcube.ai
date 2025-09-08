# ---------- Runtime stage ----------
FROM ubuntu:22.04 AS runtime

RUN apt-get update \
 && apt-mark hold systemd systemd-sysv || true \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      libgtk-3-0 libpoppler-glib8 libxml2 \
      libsndfile1 liblua5.3-0 libzip4 librsvg2-2 \
      libportaudio2 libportaudiocpp0 \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---------- Build stage ----------
FROM ubuntu:22.04 AS build

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates gnupg \
 && update-ca-certificates \
 && apt-mark hold systemd systemd-sysv || true

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config git lsb-release gettext \
      libgtk-3-dev libpoppler-glib-dev libxml2-dev \
      libsndfile1-dev liblua5.3-dev libzip-dev librsvg2-dev \
      portaudio19-dev libportaudiocpp0 libportaudiocpp0-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# (keeps your CA fix for git, which solved the previous TLS error)
RUN git config --global http.sslCAInfo /etc/ssl/certs/ca-certificates.crt

# Build
RUN mkdir -p build \
 && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j"$(nproc)" \
 && make install DESTDIR=/tmp/install

# ---------- Final image ----------
FROM runtime
COPY --from=build /tmp/install/ /
# CMD ["xournalpp"]  # or your actual binary







