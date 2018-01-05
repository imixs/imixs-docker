#!/bin/bash

echo "========================================================================="
echo "Restore PSQL databases....."
echo "========================================================================="

if [ $1 == "" ]
  then
    echo "Date is missing! (e.g. 2018-01_05:03)"
  else
    psql -f /root/backups/$1_pgdump.sql -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER
fi

