#!/bin/sh
# NVRAM backup script for Tomato Firmware Routers
#
# Back up list of nvram variables to a directory in
# ${FOLDER}/backup
# 
# Copyright (c) 2013 Wanderley B. Teixeira Filho
#
# THIS SOFTWARE IS OFFERED "AS IS", AND THE AUTHOR GRANTS NO WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, BY STATUTE,
# COMMUNICATION OR OTHERWISE. THE AUTHOR SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# SPECIFIC PURPOSE OR NONINFRINGEMENT CONCERNING THIS SOFTWARE.
#
##
DATE=`date +%m%d%Y`
# Location of the scripts remotely
FOLDER=/<REPLACE WITH FOLDER>/
DEST_FOLDER=${FOLDER}nvram_restore_${DATE}.sh

nvram export --tab output | sed 's~\\\\~\\~g' > /tmp/temp_nvram

echo "#!/bin/sh" > ${DEST_FOLDER}
echo "#" >> ${DEST_FOLDER}

awk '
BEGIN { FS="\t" }
# Only true when in the first file
FNR == NR {
# Build associative array on the first column of the file
# Skip all proceeding blocks and process next line
	x[$1]; next
	}
# Check in the value in column one of the second files is in the array
($1 in x) {
	print "nvram set "$1"='"'"'"$2"'"'"'"
	}
' /tmp/nvrambackup/nvram_to_keep /tmp/temp_nvram | \
	sed 's/\\n/\n/g' > $DEST_FOLDER

echo "nvram commit" >> ${DEST_FOLDER}
chmod +x ${DEST_FOLDER}
rm /tmp/temp_nvram

logger NVRAM settings backed up successfully

# todo
# get rid of the old backups, with the old backup dirs being thirty days old
# find ${BACKUP_FILE}/*restore* -prune -mtime +30 | xargs rm -rf
