FROM postgres:11.2

LABEL authors="Ralph Soika <ralph.soika@imixs.com>, Simone Fardella <fardella.simone@gmail.com>"

# install packages: psql and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
  cron ssh netcat \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*
 
# add scripts....
COPY docker-entrypoint-initdb.d/ docker-entrypoint-initdb.d/


# add the backup scripts into root/home
ADD scripts/backup.sh /root/backup.sh
RUN chmod +x /root/backup.sh
