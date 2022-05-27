#!/bin/sh
set -euo pipefail

# Script that initializes a Borg archive and starts the configuration process.
# Environment variables that must be set to run this script:
# - BORG_PASSPHRASE

# Configuration
RCLOUD_CONFIG="/var/backup/config"
BORG_ARCHIVE="/var/backup/snapshots"
BORG_PATH_TO_BACKUP="/mnt/source"
export BORG_KEYS_DIR="/var/backup/keys"

# Configure Borg
mkdir -p $BORG_ARCHIVE
borg init --encryption=keyfile $BORG_ARCHIVE

# Configure rclone
rclone config --config $RCLOUD_CONFIG

echo
echo "Configuration completed!"
echo "Run your first snapshot with the following command:"
echo "    $ docker run --rm -ti --env-file env.list --volume <PATH_TO_BACKUP>:/mnt/source --volume <BORG_ARCHIVE_PATH>:/var/backup photography-backup:latest create_snapshot"
echo
