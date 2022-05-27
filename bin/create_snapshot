#!/bin/sh
set -euo pipefail

# Script that creates an encrypted Borg backup and
# uploads the backup in a cloud storage through rclone.
#
# Requirements:
# - Configure a Borg repository before launching this command
# - Configure rclone and create a valid cloud storage (e.g. AWS Glacier)
#
# Environment variables that must be set to run this script:
# - BORG_PASSPHRASE
# - RCLOUD_REMOTE_NAME
# - AWS_ACCESS_KEY_ID      # (if AWS is used)
# - AWS_SECRET_ACCESS_KEY  # (if AWS is used)
# - AWS_BUCKET_NAME        # (if AWS is used)

# Configuration
RCLOUD_CONFIG="/var/backup/config"
BORG_ARCHIVE="/var/backup/snapshots"
BORG_PATH_TO_BACKUP="/mnt/source"
export BORG_KEYS_DIR="/var/backup/keys"

# Creating a snapshot
# Not generic: excluding photography cache folder (*/Cache)
echo
echo "[BORG] Snapshot started..."
borg create \
  --stats \
  --progress \
  --compression zstd,22 \
  --exclude '*/Cache' \
  $BORG_ARCHIVE::$(date +%s) \
  $BORG_PATH_TO_BACKUP

echo "[BORG] Snapshot completed with success!"
echo

# Uploading snapshots to rclone remote provider
echo "[RCLONE] Upload started..."
rclone sync \
  --progress \
  --config $RCLOUD_CONFIG \
  $BORG_ARCHIVE \
  $RCLOUD_REMOTE_NAME:$AWS_BUCKET_NAME
echo "[RCLONE] Upload completed with success!"
echo
