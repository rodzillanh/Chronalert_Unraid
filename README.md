# ChronAlert for Unraid

Runs the ChronAlert AppImage headless in a Docker container on Unraid.
The web dashboard is served on port **8420**.

- **Image:** `ghcr.io/rodzillanh/chronalert` (private)
- **Build folder on Unraid:** `/mnt/user/appdata/chronalert-build/` (`\\tower\appdata\chronalert-build\`)
- **Data folder on Unraid:** `/mnt/user/appdata/chronalert/` (settings, `terra.db`, QSO log)

## Files in this repo

| File | Purpose |
|------|---------|
| `Dockerfile` | Extracts the AppImage at build time (no FUSE needed). Uses Ubuntu 24.04 because ChronAlert needs glibc 2.38+. |
| `my-chronalert.xml` | Unraid Docker template |
| `chronalert-icon.png` | Icon for the Unraid Docker tab |
| `.github/workflows/build.yml` | Builds and pushes the image automatically when a new ChronAlert release comes out |

The AppImage itself is **not** stored in this repo (it's over GitHub's 100 MB file limit). The workflow downloads it from chronalert.com; for a manual build, keep it in the build folder on Unraid, next to the `Dockerfile`.

## Upgrading to a new ChronAlert release

Once a day, GitHub Actions reads the version on https://chronalert.com/download. If that version hasn't been pushed yet, it downloads the AppImage, builds the image and pushes it as `:<version>` and `:latest`. To check right away, go to the repo's **Actions** tab → **Build and push ChronAlert image** → **Run workflow** (tick *force* to rebuild a version that already exists).

After a new version is pushed, update the container: in the Unraid **Docker** tab, click **Check for Updates** at the bottom, then click **apply update** on chronalert.

Settings, the database and the QSO log in `/mnt/user/appdata/chronalert` are kept across upgrades.

### Building manually on Unraid

If the workflow can't run (for example, chronalert.com changes its download page), build on Unraid instead:

1. **Copy in the new AppImage.** Put it in `\\tower\appdata\chronalert-build\`, replacing the old one. The file name must be exactly `ChronAlert-x86_64.AppImage`, so rename the download if needed.

2. **Build and push.** In the Unraid terminal, set `VERSION` to the new version number:

   ```bash
   cd /mnt/user/appdata/chronalert-build
   VERSION=0.7.3
   docker build --build-arg VERSION=$VERSION -t ghcr.io/rodzillanh/chronalert:$VERSION -t ghcr.io/rodzillanh/chronalert:latest .
   docker push ghcr.io/rodzillanh/chronalert:$VERSION
   docker push ghcr.io/rodzillanh/chronalert:latest
   ```

3. **Update the container** as above.

## Rolling back

Every version you push stays on GitHub. To go back:

1. In the Docker tab, click the chronalert icon and choose **Edit**.
2. Change **Repository** from `ghcr.io/rodzillanh/chronalert:latest` to the older tag, for example `ghcr.io/rodzillanh/chronalert:0.7.2`.
3. Click **Apply**.

Change it back to `:latest` when you're ready to move forward again.

## Troubleshooting

**`unauthorized` when pushing or pulling.** The GitHub login on Unraid has expired. Create a new token at GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) with the `write:packages` scope, then log in again (the prompt hides what you paste):

```bash
read -s -p "Token: " T && echo "$T" | docker login ghcr.io -u rodzillanh --password-stdin; unset T
```

**The workflow fails with `denied` or `permission_denied` on push.** The image was first pushed from Unraid, so the repo's workflow may not have write access to it. On GitHub, open your profile → **Packages** → **chronalert** → **Package settings** → **Manage Actions access** → **Add repository** → `Chronalert_Unraid`, set the role to **Write**, and run the workflow again.

**Pasted commands start with `^[[200~` and fail.** Press Ctrl+C, run this, then paste again:

```bash
bind 'set enable-bracketed-paste off'
```

**Icon shows a question mark.** Make sure the icon exists at `/boot/config/plugins/dockerMan/images/chronalert-icon.png`, then run:

```bash
cp /boot/config/plugins/dockerMan/images/chronalert-icon.png /var/lib/docker/unraid/images/chronalert-icon.png
```

and refresh the Docker tab.

## Fresh install on Unraid

1. Copy `chronalert-icon.png` to `/boot/config/plugins/dockerMan/images/`.
2. Copy `my-chronalert.xml` to `/boot/config/plugins/dockerMan/templates-user/`.
3. Log in to ghcr.io (see Troubleshooting) so Unraid can pull the private image.
4. Go to Docker → **Add Container** → Template: **chronalert** → **Apply**.
5. Turn on **Autostart** for chronalert in the Docker tab.
