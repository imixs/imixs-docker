#!/bin/bash

echo "*** FTP-GET backup files...."

if [ $1 == "" ]
  then
    echo "*** FTP-GET failed: source file is missing! (e.g. /imixs-cloud/SERVICE-ID/2018-01-07_15:49_pgdump.sql)"
  else
    echo "*** FTP-GET file= $1"
    ncftpget -u "$BACKUP_FTP_USER" -p "$BACKUP_FTP_PASSWORD" $BACKUP_FTP_HOST /root/backups/ $1 
    echo "*** FTP-GET finished"
fi

