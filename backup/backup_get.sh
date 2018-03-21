#!/bin/bash

echo "*** get file from backup space...."

if [ $1 == "" ]
  then
    echo "*** GET failed: source file is missing! (e.g. /imixs-cloud/SERVICE-ID/2018-01-07_15:49_dump.tar.gz)"
  else
    echo "*** GET file= $1"
    scp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:$1 /root/backups/
    echo "*** GET finished"
fi

