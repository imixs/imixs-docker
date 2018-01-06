#!/bin/bash

echo "*** Restore PSQL started...."

if [ $1 == "" ]
  then
    echo "*** Restore PSQL failed: date is missing! (e.g. 2018-01_05:03)"
  else
    echo "*** Restore PSQL database=$BACKUP_POSTGRES_DB from $1"
    pg_restore -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER -Fc -d $BACKUP_POSTGRES_DB  /root/backups/$1_pgdump.sql
    echo "*** Restore PSQL finished"
     
fi

