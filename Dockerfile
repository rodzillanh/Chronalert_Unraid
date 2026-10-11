# ChronAlert in Docker — extracts the AppImage at build time (no FUSE needed)
# Needs glibc >= 2.38, so Ubuntu 24.04 (Debian bookworm is too old).
FROM ubuntu:24.04 AS extract
WORKDIR /build
COPY ChronAlert-x86_64.AppImage .
RUN chmod +x ChronAlert-x86_64.AppImage && ./ChronAlert-x86_64.AppImage --appimage-extract >/dev/null

FROM ubuntu:24.04
LABEL org.opencontainers.image.source=https://github.com/rodzillanh/Chronalert_Unraid
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*
COPY --from=extract /build/squashfs-root/usr/bin/chronalert /opt/chronalert
ENV HOME=/data
VOLUME /data
EXPOSE 8420
ENTRYPOINT ["/opt/chronalert/chronalert", "--host", "0.0.0.0", "--port", "8420", "--no-browser"]
