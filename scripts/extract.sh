#!/bin/sh
set -euo pipefail

# Mounts the rclone remote so that it can be used by `borg` to extract a snapshot.
#
# Requirements:
# - rclone and borg must be already configured.
#
# Required environment variables:
# - RCLONE_REMOTE_PATH: name of the rclone remote path to use. Use a valid format (REMOTE_NAME:PATH).

# Configuration
export RCLONE_CONFIG="/config/rclone.conf"
export RCLONE_CACHE_DIR="/cache/rclone"
export BORG_ARCHIVE="/mnt/bucket"
export BORG_CACHE_DIR="/cache/borg"
export BORG_CONFIG_DIR="/config/borg"
export BORG_EXTRACT_DIR="/mnt/extract"

# Check if `rclone` remotes are already configured
if [ ! -f "$RCLONE_CONFIG" ]; then
  echo "rclone remotes are not configured. You must configure them before using this script."
  exit 1
else
  echo "rclone remotes already configured. Using rclone.conf file."
fi

# Mount rclone remote folder
mkdir -p $BORG_ARCHIVE
rclone mount --config $RCLONE_CONFIG \
  --daemon \
  --gcs-bucket-policy-only \
  --cache-dir $RCLONE_CACHE_DIR \
  --vfs-cache-mode writes \
  $RCLONE_REMOTE_PATH $BORG_ARCHIVE

# Check if Borg archive is already initialized
if [ ! -f "$BORG_ARCHIVE/config" ]; then
    echo "Borg archive is not initialized. You must initialize it before using this script."
    exit 1
fi

# Provide details about the Borg archive
borg info $BORG_ARCHIVE
borg list $BORG_ARCHIVE
echo
echo "To extract a snapshot, run:"
echo "  borg extract --progress $BORG_ARCHIVE::SNAPSHOT_NAME"

# Let users interact with the system
cd $BORG_EXTRACT_DIR
exec "/bin/sh"
