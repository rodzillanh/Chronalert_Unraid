# ChronAlert for Unraid

Runs the ChronAlert AppImage headless in a Docker container on Unraid.
The web dashboard is served on port **8420**.

Image: `ghcr.io/rodzillanh/chronalert` (private)

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Extracts the AppImage at build time (no FUSE needed) on Ubuntu 24.04 (needs glibc 2.38+) |
| `my-chronalert.xml` | Unraid Docker template |
| `chronalert-icon.png` | Icon for the Unraid Docker tab |

The AppImage itself is not stored in this repo.

## Build and push

Put `ChronAlert-x86_64.AppImage` next to the `Dockerfile`, then:

```bash
VERSION=0.7.2
docker build -t ghcr.io/rodzillanh/chronalert:$VERSION -t ghcr.io/rodzillanh/chronalert:latest .
docker push ghcr.io/rodzillanh/chronalert:$VERSION
docker push ghcr.io/rodzillanh/chronalert:latest
```

## Install on Unraid

1. Copy `chronalert-icon.png` to `/boot/config/plugins/dockerMan/images/`.
2. Copy `my-chronalert.xml` to `/boot/config/plugins/dockerMan/templates-user/`.
3. Docker → Add Container → Template: **chronalert** → Apply.

Data (settings, `terra.db`, QSO log) lives in `/mnt/user/appdata/chronalert`.
