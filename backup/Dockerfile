FROM postgres:9.6.1

MAINTAINER Ralph Soika <ralph.soika@imixs.com>

# install packages: psql and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
  cron ncftp \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

# add the backup scripts into root/home
ADD backup.sh /root/backup.sh
RUN chmod +x /root/backup.sh
ADD backup_init.sh /root/backup_init.sh
RUN chmod +x /root/backup_init.sh
ADD restore.sh /root/restore.sh
RUN chmod +x /root/restore.sh

RUN mkdir /root/backups
VOLUME /root/backups

# Add crontab file in the cron directory
#ADD backup-cron /etc/cron.d/backup-cron
#RUN chmod 0644 /etc/cron.d/backup-cron

CMD ["/root/backup_init.sh"]
