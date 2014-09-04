#!/bin/sh

# Version 1.0 (04/09/2014)

# Prevent Mac from going to sleep during restore.
/usr/bin/pmset sleep 0

# Name of backup disk.
BACKUP_DISK="Backups"

# Get backup disk identifier
BACKUP_DISK_ID="`/usr/sbin/diskutil list | /usr/bin/grep \"${BACKUP_DISK}\" | /usr/bin/awk '{print $NF}'`"

# Mount backup disk
/usr/sbin/diskutil mount "/dev/${BACKUP_DISK_ID}"

# Give the external disk 5 seconds to mount
sleep 5

# Get computer name.
COMPUTER_NAME="`/usr/sbin/scutil --get ComputerName`"

# Get serial number.
SERIAL_NUMBER=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep 'Serial Number (system)' | /usr/bin/awk '{print $NF}'`

# A unique ID.
ID="$SERIAL_NUMBER"

# Todays date in Swedish date format.
DATE=`date "+%Y-%m-%d"` 

# Completion timestamp
UNIX_TIMESTAMP=`date "+%s"`

# Location of home directories.
USERS_DIR="/Volumes/Macintosh HD/Users/"

# Backup source.
BACKUP_DIR="/Volumes/${BACKUP_DISK}/${ID}/${DATE}/"

# Restored backups directory.
RESTORED_DIR="/Volumes/${BACKUP_DISK}/Restored/${COMPUTER_NAME}/${ID}/"

# Use rsync to restore a backup of all user home directories.
# -a: archive mode; same as -rlptgoD (no -H)
# -E: copy extended attributes, resource forks
# -H: preserve hard links
# -h: output numbers in a human-readable format (MB, GB, etc.)
# -t: preserve times
# --stats: give some file-transfer stats
# --progress: show progress during transfer
/usr/bin/sudo /usr/bin/rsync -aEHht --stats --progress --include-from="/Library/Scripts/restore_filter.txt" "$BACKUP_DIR" "$USERS_DIR"

# Check that the last command was successful.
if [ $? -eq 0 ]
then	
	# For archiving purposes move the backup folder into Restored.
	mkdir -p "$RESTORED_DIR"
	/usr/bin/sudo mv "$BACKUP_DIR" "${RESTORED_DIR}/${DATE} (${UNIX_TIMESTAMP})"
	
	# Remove the local restore filter file.
	rm "/Library/Scripts/restore_filter.txt"
	
	exit 0
else
	echo "Restore failed!"
	exit 1
fi
