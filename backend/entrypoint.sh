#!/usr/bin/env bash

set -Eeuo pipefail

function show_help {
    echo """
    Commands
    ----------------------------------------------------------------------------
    bash          : run bash
    eval          : eval shell command
    manage        : invoke django manage.py commands
    test          : run tests
    test_lint     : run flake8 tests
    test_coverage : run tests with coverage output
    test_py       : alias of test_coverage
    start_dev     : start Django server for development
    """
}


function setup {
    # check if required environment variables were set
    pg_isready

    if psql -c "" $DB_NAME; then
        echo "$DB_NAME database exists!"
    else
        createdb -e $DB_NAME -e ENCODING=UTF8
        echo "$DB_NAME database created!"
    fi

    # migrate data model if needed
    ./manage.py migrate --noinput

    # arguments: -u=admin -p=secretsecret -e=admin@aether.org -t=01234656789abcdefghij
    ./manage.py setup_admin -u=$ADMIN_USERNAME -p=$ADMIN_PASSWORD -t=$ADMIN_TOKEN -e=$ADMIN_EMAIL

    STATIC_ROOT=${STATIC_ROOT:-/var/www/static}
    # create static assets
    ./manage.py collectstatic --noinput --clear --verbosity 0
    chmod -R 755 ${STATIC_ROOT}
}

function test_lint {
    flake8
}

function test_coverage {
    rm -R /app/.coverage* 2>/dev/null || true

    coverage run \
        --concurrency=multiprocessing \
        --parallel-mode \
        manage.py test \
        --parallel ${TEST_PARALLEL:-} \
        --noinput \
        "${@:1}"
    coverage combine --append
    coverage report
    coverage erase

    echo "Good Job ************ Good Job"
}

case "$1" in
    bash )
        bash
    ;;

    eval )
        eval "${@:2}"
    ;;

    setup )
        setup
    ;;

    manage )
        ./manage.py "${@:2}"
    ;;

    test )
        test_lint
        test_coverage "${@:2}"
    ;;

    test_lint )
        test_lint
    ;;

    test_py | test_coverage )
        test_coverage "${@:2}"
    ;;

    start_dev )
        # ensure that DEBUG mode is enabled
        export DEBUG=true
        setup
        ./manage.py runserver 0.0.0.0:$WEB_SERVER_PORT
    ;;

    help )
        show_help
    ;;

    * )
        show_help
    ;;
esac
