#!/bin/sh
set -euo pipefail

# Entrypoint that auto-configures a backup system and runs backup operations using
# `borg`, `rclone` and Cron.
#
# Required environment variables:
# - RCLONE_REMOTE_PATH: name of the rclone remote path to use. Use a valid format (REMOTE_NAME:PATH).
# - CROND_SCHEDULE: crond schedule to use. Use a crond valid format (* * * * *).
# - BORG_FIRST_RUN: set to 1 to perform a full backup on the first run. Set to 0 to perform a backup only with cron.

# Exit point if commands are passed to `docker run`
if [ "$#" -gt 0 ]; then
    exec "$@"
    exit 0
fi

# Configuration
export RCLONE_CONFIG="/config/rclone.conf"
export RCLONE_CACHE_DIR="/cache/rclone"
export BORG_ARCHIVE="/mnt/bucket"
export BORG_CACHE_DIR="/cache/borg"
export BORG_CONFIG_DIR="/config/borg"

# Check if `rclone` remotes are already configured
if [ ! -f "$RCLONE_CONFIG" ]; then
  echo "rclone remotes are not configured. Proceed with the configuration and simply quit rclone when done (q)."
  rclone config --config $RCLONE_CONFIG
  chmod 600 $RCLONE_CONFIG
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
  echo "Borg archive is not initialized. Proceed with the initialization."
  borg init --encryption=repokey $BORG_ARCHIVE
  echo "Borg archive initialized."
else
  echo "Borg archive already initialized. Using the following repository:"
  borg info $BORG_ARCHIVE
fi

# Handle the first run if set
if [ "$BORG_FIRST_RUN" = 1 ]; then
  echo "Performing a full backup on the first run."
  /usr/local/bin/create_snapshot.sh
fi

# Create a crond rule to start the backup at the given time
echo "$CROND_SCHEDULE /usr/local/bin/create_snapshot.sh" > /var/spool/cron/crontabs/root

# Launch backup schedule (crond)
# NOTE: This is a blocking call that will run until the container is stopped.
echo "crond started with the following schedule: $CROND_SCHEDULE"
crond -l 8 -f

# Unmount the folder
fusermount3 -u $BORG_ARCHIVE
