#!/usr/bin/env bash
#
set -Eeuo pipefail

containers=( django frontend )

for container in "${containers[@]}"
do
    ./scripts/test_container.sh $container
done