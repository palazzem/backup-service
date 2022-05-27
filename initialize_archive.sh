#!/bin/sh
set -euo pipefail

# Script that initializes a Borg archive and starts the configuration process.
# Environment variables that must be set to run this script:
# - BORG_PASSPHRASE

# Configuration
RCLOUD_CONFIG="/var/backup/config"
BORG_ARCHIVE="/var/backup/snapshots"
BORG_PATH_TO_BACKUP="/mnt/source"

# Configure Borg
mkdir -p $BORG_ARCHIVE
borg init --encryption=repokey $BORG_ARCHIVE

# Configure rclone
rclone config --config $RCLOUD_CONFIG

echo
echo "Configuration completed!"
echo "Run your first snapshot with the following command:"
echo "    $ docker run --rm -ti --volume $PWD/to_backup:/mnt/source:z --volume $PWD/testing:/var/backup:z --env-file env.list photography-backup:latest create_snapshot"
echo
