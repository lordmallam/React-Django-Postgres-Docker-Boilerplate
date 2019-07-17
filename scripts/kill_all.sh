#!/usr/bin/env bash
#
set -Eeuo pipefail

for dc_file in $(find docker-compose*.yml */docker-compose*.yml 2> /dev/null)
do
    docker-compose -f $dc_file kill
done