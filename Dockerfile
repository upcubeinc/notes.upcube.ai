# syntax=docker/dockerfile:1

#########################
#       Build stage     #
#########################
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# CA certs (for git/FetchContent) + guard against systemd upgrades in containers
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates gnupg \
 && update-ca-certificates \
 && apt-mark hold systemd systemd-sysv || true

# Toolchain & headers (audio disabled, so no portaudiocpp needed)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config git lsb-release gettext \
      libgtk-3-dev libpoppler-glib-dev libxml2-dev \
      libsndfile1-dev liblua5.3-dev libzip-dev librsvg2-dev \
 && rm -rf /var/lib/apt/lists/*

# Ensure git uses the system CA bundle to avoid "CAfile: none"
ENV GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
RUN git config --global http.sslCAInfo /etc/ssl/certs/ca-certificates.crt

WORKDIR /app
COPY . /app

# Configure & build (disable audio to avoid portaudiocpp requirement)
RUN mkdir -p build \
 && cd build \
 && cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_AUDIO=OFF \
 && make -j"$(nproc)" \
 && make install DESTDIR=/tmp/install


#########################
#     Runtime stage     #
#########################
FROM ubuntu:22.04 AS runtime
ENV DEBIAN_FRONTEND=noninteractive

# Runtime libs + CA certs; avoid systemd upgrades
RUN apt-get update \
 && apt-mark hold systemd systemd-sysv || true \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      libgtk-3-0 libpoppler-glib8 libxml2 \
      libsndfile1 liblua5.3-0 libzip4 librsvg2-2 \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Bring in built artifacts
COPY --from=build /tmp/install/ /

# Default command (override as needed)
CMD ["xournalpp"]








