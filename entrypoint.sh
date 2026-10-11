#!/bin/sh
# Runs as root just long enough to fix ownership of /data, then starts
# ChronAlert as PUID:PGID (Unraid's nobody:users, 99:100, by default).
set -e

PUID="${PUID:-99}"
PGID="${PGID:-100}"

if [ -n "$(find /data \( ! -user "$PUID" -o ! -group "$PGID" \) -print -quit)" ]; then
  echo "Setting ownership of /data to $PUID:$PGID"
  chown -R "$PUID:$PGID" /data
fi

exec setpriv --reuid="$PUID" --regid="$PGID" --clear-groups \
  /opt/chronalert/chronalert --host 0.0.0.0 --port 8420 --no-browser "$@"
