#!/bin/bash

# Supply the password to Restic
export RESTIC_PASSWORD= ${RESTIC_PASSWORD}

# Define the repository location
export RESTIC_REPOSITORY="rclone:gdrive:your_backup_repo"

# Run the backup, excluding music and sockets
restic backup ${PROJECT_DIR}/navidrome \
  --exclude="${PROJECT_DIR}/navidrome/music" \
  --exclude="${PROJECT_DIR}/navidrome/beszel/socket"

# Keep the last 14 daily backups and 4 weekly backups, delete the rest
restic forget --keep-daily 14 --keep-weekly 4 --prune
