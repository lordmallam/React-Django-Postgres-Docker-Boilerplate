#!/usr/bin/env bash
#
set -Eeuo pipefail

function build_container {
    echo_message "Building $1 container"

    $DC_TEST build $BUILD_OPTIONS \
        --build-arg GIT_REVISION=$APP_REVISION \
        --build-arg VERSION=$APP_VERSION \
        "$1"-test
}

function echo_message {
    LINE=`printf -v row "%${COLUMNS:-$(tput cols)}s"; echo ${row// /=}`

    if [ -z "$1" ]; then
        echo "$LINE"
    else
        msg=" $1 "
        echo "${LINE:${#msg}}$msg"
    fi
}

# TEST environment
DC_TEST="docker-compose -f docker-compose-test.yml"
BUILD_OPTIONS="${BUILD_OPTIONS:-}"
APP_VERSION=$(date "+%Y%m%d%H%M%S")
APP_REVISION=`git rev-parse --abbrev-ref HEAD`

./scripts/kill_all.sh

echo_message "Preparing $1 container"
build_container $1
echo_message "$1 ready!"

if [[ $1 == "backend" ]]; then
    $DC_TEST run --rm "$1"-test test
fi

if [[ $1 == "frontend" ]]; then
    $DC_TEST run --rm "$1"-test
fi

echo_message "$1 tests passed!"

./scripts/kill_all.sh
