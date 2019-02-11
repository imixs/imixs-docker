#!/bin/bash

conf=/etc/exim4/update-exim4.conf.conf

echo "# exim config" > $conf
echo "dc_eximconfig_configtype='satellite'" >> $conf
echo "dc_other_hostnames='$HOSTNAME'" >> $conf
echo "dc_local_interfaces='$EXIM_LOCALINTERFACE'" >> $conf
echo "dc_readhost='$EXIM_DOMAIN'" >> $conf
echo "dc_relay_domains=''" >> $conf
echo "dc_minimaldns='false'" >> $conf
echo "dc_relay_nets='$EXIM_ALLOWED_SENDERS'" >> $conf
echo "dc_smarthost='$EXIM_SMARTHOST'" >> $conf
echo "dc_use_split_config='false'" >> $conf
echo "dc_hide_mailname='true'" >> $conf
echo "dc_mailname_in_oh='true'" >> $conf
echo "dc_localdelivery='mail_spool'" >> $conf
echo "CFILEMODE='644'" >> $conf

# Test if EXIM_MESSAGE_SIZE_LIMIT if set?..
if [[ -v EXIM_MESSAGE_SIZE_LIMIT ]]
  then
  	echo "...setting MESSAGE_SIZE_LIMIT to $EXIM_MESSAGE_SIZE_LIMIT ..."
	echo "MESSAGE_SIZE_LIMIT=$EXIM_MESSAGE_SIZE_LIMIT" >> $conf
fi



# Update passwd.client
passwd=/etc/exim4/passwd.client

echo $EXIM_PASSWORD >> $passwd

update-exim4.conf

# Sort of hack to send logs to stdout
xtail /var/log/exim4 &
XTAIL_PID=$!

# Start exim
/usr/sbin/exim4 ${*:--bdf -q30m} &
EXIM_PID=$!

# Add a signal trap to clean up the child processs
clean_up() {
    echo "killing exim ($EXIM_PID)"
    kill $EXIM_PID
}
trap clean_up SIGHUP SIGINT SIGTERM

# Wait for the exim process to exit
wait $EXIM_PID
EXIT_STATUS=$?

# Kill the xtail process
echo "killing xtail ($XTAIL_PID)"
kill $XTAIL_PID

exit $EXIT_STATUS