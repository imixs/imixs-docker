#!/bin/bash

# ***********************************************************
# * This script can be used to generate a public key and 
# * share the key with a remove backup space
# ***********************************************************

echo "*** Share public key...."

# test if we yet have a public key...
if [ ! -f /root/.ssh/id_rsa ]; then
    echo "generating new rsa key file..."
    ssh-keygen -q -N ""
    # create  RFC4716 Format
    ssh-keygen -e -f /root/.ssh/id_rsa.pub | grep -v "Comment:" > /root/.ssh/id_rsa_rfc.pub
fi

# try to generate remote .ssh directory
echo mkdir .ssh | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST

# get autorized keys...
echo get backup_authorized_keys | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:.ssh/authorized_keys

# append rfc public key
cat /root/.ssh/id_rsa_rfc.pub >> backup_authorized_keys

# copy 
scp backup_authorized_keys $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:.ssh/authorized_keys


echo "public key deployed successfully. "