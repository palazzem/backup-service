#!/bin/sh
set -euo pipefail

# Script that creates an encrypted Borg backup in a rclone remote mount. Remember
# that rclone mount caches all writes, so another script must mount the remote
# beforehand. This script must never unmount rclone remotes.
#
# Requirements:
# - `entrypoint.sh` must keep the rclone remote mounted.
# - rclone and borg must be already configured.

# Configuration
export RCLONE_CONFIG="/config/rclone.conf"
export RCLONE_CACHE_DIR="/cache/rclone"
export BORG_ARCHIVE="/mnt/bucket"
export BORG_CACHE_DIR="/cache/borg"
export BORG_CONFIG_DIR="/config/borg"
export BORG_DATA="/data"
export BORG_EXCLUDE_FILE="/config/exclude"

# Check if Borg archive is already initialized
if [ ! -f "$BORG_ARCHIVE/config" ]; then
    echo "Borg archive is not initialized. Ensure entrypoint.sh is running."
    exit 1
fi

# Detect if an exclude file is present
EXCLUDE_OPTION=""
if [ -f "$BORG_EXCLUDE_FILE" ]; then
  EXCLUDE_OPTION="--exclude-from $BORG_EXCLUDE_FILE"
fi

# Create the snapshot
borg create \
  --stats \
  --progress \
  --compression zstd,22 \
  $EXCLUDE_OPTION \
  $BORG_ARCHIVE::$(date +%s) \
  $BORG_DATA
