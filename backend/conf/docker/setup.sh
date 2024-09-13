#!/usr/bin/env bash

set -Eeuo pipefail


################################################################################
# define variables
################################################################################

POSTGRES_PACKAGE=postgresql-client-16


################################################################################
# install packages
################################################################################

# install missing packages of slim distribution and required ones
PACKAGE_LIST=/tmp/apt-packages.txt
if [ -f "$PACKAGE_LIST" ]; then
    apt-get update -qq > /dev/null
    apt-get -qq \
        --yes \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        install `cat $PACKAGE_LIST` > /dev/null
fi

# add postgres apt repo to get more recent postgres versions
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/postgresql.gpg
apt-get update -qq > /dev/null
apt-get -qq \
    --yes \
    --allow-downgrades \
    --allow-remove-essential \
    --allow-change-held-packages \
    install $POSTGRES_PACKAGE > /dev/null


################################################################################
# Create user and folders
################################################################################

useradd -ms /bin/false trisiki

mkdir -p /var/run/trisiki/log/
touch /var/run/trisiki/uwsgi.pid

chown -Rf trisiki: /var/run/trisiki/*
chmod -R 755 /var/run/trisiki/*


################################################################################
# last steps and cleaning
################################################################################

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
apt-get clean
apt-get autoremove