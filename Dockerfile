# ---------- Build stage ----------
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Base SSL + keep systemd from fiddling
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates gnupg \
 && update-ca-certificates \
 && apt-mark hold systemd systemd-sysv || true

# Build dependencies (adds gettext + librsvg2-dev + others you used)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential cmake pkg-config git lsb-release gettext \
    libgtk-3-dev libpoppler-glib-dev libxml2-dev \
    libsndfile1-dev liblua5.3-dev libzip-dev librsvg2-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Make sure git uses proper CA bundle (paranoia, but harmless)
RUN git config --global http.sslCAInfo /etc/ssl/certs/ca-certificates.crt

# Build
RUN mkdir -p build \
 && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j"$(nproc)" \
 && make install DESTDIR=/tmp/install

# ---------- Runtime stage ----------
FROM ubuntu:22.04 AS runtime
ENV DEBIAN_FRONTEND=noninteractive

# Runtime libs + hold systemd too
RUN apt-get update \
 && apt-mark hold systemd systemd-sysv || true \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    libgtk-3-0 libpoppler-glib8 libxml2 \
    libsndfile1 liblua5.3-0 libzip4 librsvg2-2 \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# If you actually need a headless GUI + VNC, uncomment:
# RUN apt-get update && apt-get install -y --no-install-recommends xvfb x11vnc fluxbox && rm -rf /var/lib/apt/lists/*

# Bring in the installed files from the build
COPY --from=build /tmp/install/ /

# Set the default entrypoint/binary (adjust if your binary name differs)
# ENTRYPOINT ["/usr/local/bin/xournalpp"]






