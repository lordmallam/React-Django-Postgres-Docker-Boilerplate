#!/usr/bin/env bash

set -Eeuo pipefail

source .env

function show_help {
    echo """
    Start the indicated container with the necessary dependencies

    Usage:

        ./scripts/docker_start.sh [options] <name>

    Options:

        --build | -b   kill and build all containers before start
        --clean | -c   stop and remove all running containers and volumes before start
        --force | -f   ensure that the container will be restarted if needed
        --kill  | -k   kill all running containers before start

        --help  | -h   show this message

        <name>
            Expected values: api, ui.
            Any other value will start all containers.

    """
}

function start_container {
    if [[ $force = "yes" ]]; then
        docker-compose kill $1
    fi
    docker-compose up --no-deps -d $1
    sleep 2
    docker-compose logs --tail 20 $1
}

# default values
app=
build=no
clean=no
force=no
kill=no

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            # shows help
            show_help
            exit 0
        ;;

        -k|--kill)
            # stop all containers
            kill=yes

            shift # past argument
        ;;

        -b|--build)
            # build all containers
            build=yes

            shift # past argument
        ;;

        -c|--clean)
            # clean all containers
            kill=yes
            clean=yes

            shift # past argument
        ;;

        -f|--force)
            # force restart container
            force=yes

            shift # past argument
        ;;

        *)
            # otherwise is the container name
            app="$1"

            shift # past argument
        ;;
    esac
done

case $app in
    api)
        PRE_CONTAINERS=(db)
        SETUP_CONTAINERS=(api)
    ;;

    ui)
        PRE_CONTAINERS=(db)
        SETUP_CONTAINERS=(api ui)
    ;;

    *)
        app=

        PRE_CONTAINERS=(db)
        SETUP_CONTAINERS=(api ui)
    ;;
esac

echo ""
docker-compose ps
echo "----------------------------------------------------------------------"
echo ""

if [[ $kill = "yes" ]]; then
    echo "----------------------------------------------------------------------"
    echo "---- Killing containers                                           ----"
    echo "----------------------------------------------------------------------"

    ./scripts/kill_all.sh
    echo ""
fi

if [[ $clean = "yes" ]]; then
    echo "----------------------------------------------------------------------"
    echo "---- Cleaning containers and volumes                              ----"
    echo "----------------------------------------------------------------------"

    ./scripts/clean_all.sh
    echo ""
fi

if [[ $build = "yes" ]]; then
    echo "----------------------------------------------------------------------"
    echo "---- Building containers                                          ----"
    echo "----------------------------------------------------------------------"

    for container in "${SETUP_CONTAINERS[@]}"; do
      docker-compose build --no-cache --force-rm --pull $container
    done
    echo ""
fi

docker network rm ${NETWORK_NAME} || true
{
    docker network create ${NETWORK_NAME}
} || true
echo "${NETWORK_NAME} network is ready."


# check that the volume exists or create it
docker volume create ${DB_VOLUME} || true
echo "${DB_VOLUME} volume is ready."

echo "----------------------------------------------------------------------"
echo "---- Starting containers                                          ----"
echo "----------------------------------------------------------------------"

for container in "${PRE_CONTAINERS[@]}"; do
    start_container $container
done

for container in "${SETUP_CONTAINERS[@]}"; do
    docker-compose run --rm $container setup
    start_container $container
done

echo ""
docker-compose ps
echo "----------------------------------------------------------------------"
echo ""
docker ps
echo "----------------------------------------------------------------------"
echo ""

docker-compose up $app
