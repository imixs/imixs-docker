#!/bin/bash

echo "*** Restore started...."

if [ $1 == "" ]
  then
    echo "*** Restore failed: date is missing! (e.g. 2018-01_05:03)"
  else
    echo "*** Restore $BACKUP_DB from $1"
    
    echo " WE NEED TO FIX THIS ! - DB_TYPE! "
    pg_restore -c -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -Fc -d $BACKUP_DB_DB  /root/backups/$1_pgdump.sql
    echo "*** Restore  finished"
     
fi

