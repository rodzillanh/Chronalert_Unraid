# ChronAlert in Docker — extracts the AppImage at build time (no FUSE needed)
# Needs glibc >= 2.38, so Ubuntu 24.04 (Debian bookworm is too old).
FROM ubuntu:24.04 AS extract
WORKDIR /build
COPY ChronAlert-x86_64.AppImage .
RUN chmod +x ChronAlert-x86_64.AppImage && ./ChronAlert-x86_64.AppImage --appimage-extract >/dev/null

FROM ubuntu:24.04
ARG VERSION=unknown
LABEL org.opencontainers.image.source=https://github.com/rodzillanh/Chronalert_Unraid \
      org.opencontainers.image.version=$VERSION
# tini passes Docker's stop signal on to ChronAlert so it can close terra.db cleanly;
# curl is for the health check.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates tzdata tini curl \
 && rm -rf /var/lib/apt/lists/*
COPY --from=extract /build/squashfs-root/usr/bin/chronalert /opt/chronalert
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENV HOME=/data PUID=99 PGID=100
VOLUME /data
EXPOSE 8420
# Any HTTP response counts as healthy; only a dead or hung server fails.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -sS -o /dev/null --max-time 5 http://127.0.0.1:8420/ || exit 1
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
