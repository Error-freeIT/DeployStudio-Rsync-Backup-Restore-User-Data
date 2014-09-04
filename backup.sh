#!/bin/sh

# Version 1.0 (04/09/2014)

# Name of backup drive. Disk name cannot contain spaces.
BACKUP_DISK="Backups"

# Get serial number.
SERIAL_NUMBER=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep 'Serial Number (system)' | /usr/bin/awk '{print $NF}'`

# A unique ID.
ID="$SERIAL_NUMBER"

# Todays date in Swedish date format.
DATE=`date "+%Y-%m-%d"` 

# Location of home directories.
USERS_DIR="/Volumes/Macintosh HD/Users/"

# Backup destination.
BACKUP_DIR="/Volumes/${BACKUP_DISK}/${ID}/${DATE}/"

# Create backup directory.
mkdir -p "$BACKUP_DIR"

# Use rsync to create a backup of all user home directories.
# -a: archive mode; same as -rlptgoD (no -H)
# -E: copy extended attributes, resource forks
# -H: preserve hard links
# -h: output numbers in a human-readable format (MB, GB, etc.)
# -t: preserve times
# -v: increase verbosity
# --stats: give some file-transfer stats
/usr/bin/rsync -aEHhtv --stats --include-from="/tmp/DSNetworkRepository/Files/backup_filter.txt" "$USERS_DIR" "$BACKUP_DIR"

# Check that the last command was successful.
if [ $? -eq 0 ]
then
	exit 0
else
	echo "Backup failed!"
	exit 1
fi
