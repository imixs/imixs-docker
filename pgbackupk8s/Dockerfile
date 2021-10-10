FROM postgres:13.3

LABEL authors="Ralph Soika <ralph.soika@imixs.com>"

# install packages: psql and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
   ssh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*
 


# add the backup scripts into root/home
ADD backup.sh /root/backup.sh
ADD restore.sh /root/restore.sh
RUN chmod +x /root/*.sh
