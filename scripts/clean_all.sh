#!/usr/bin/env bash

set -Eeuo pipefail

source .env

function show_help {
    echo """
    Remove containers for services defined in all the compose files

    Usage:

        ./scripts/clean_all.sh [options]

    Options:

        --env-file | -e   remove also the [.env] file (contains all credentials)
        --network  | -n   remove also the network: ${NETWORK_NAME}
        --volume   | -v   remove also the volume: ${DB_VOLUME}
        --all      | -a   remove all of the above

        --help     | -h   show this message
    """
}

# default values
network=no
volume=no
env=no

while [[ $# -gt 0 ]]
do
    case "$1" in
        -h|--help)
            # shows help
            show_help
            exit 0
        ;;

        -e|--env-file)
            # remove credentials
            env=yes
            shift # past argument
        ;;

        -v|--volume)
            # remove volume
            volume=yes
            shift # past argument
        ;;

        -n|--network)
            # remove network
            network=yes
            shift # past argument
        ;;

        -a|--all)
            # remove volume, network and credentials
            volume=yes
            network=yes
            env=yes
            shift # past argument
        ;;

        *)
            shift # past argument
        ;;
    esac
done

# libraries+core apps
for dc_file in $(find docker-compose*.yml */docker-compose*.yml 2> /dev/null)
do
    docker-compose -f $dc_file kill
    docker-compose -f $dc_file down -v
done

if [[ $volume = "yes" ]]; then
    docker volume  rm ${DB_VOLUME}
fi

if [[ $network = "yes" ]]; then
    docker network rm ${NETWORK_NAME}
fi

if [[ $env = "yes" ]]; then
    rm -f .env
fi
