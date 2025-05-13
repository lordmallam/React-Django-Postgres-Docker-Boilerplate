#!/usr/bin/env bash

set -Eeuo pipefail

function show_help {
    echo """
    Commands
    ----------------------------------------------------------------------------
    bash          : run bash
    eval          : eval shell command
    manage        : invoke django manage.py commands

    pip_freeze    : freeze pip dependencies and write to requirements.txt

    backup_db     : creates db dump (${BACKUPS_FOLDER}/${DB_NAME}-backup-{timestamp}.sql)
    restore_dump  : restore db dump (${BACKUPS_FOLDER}/${DB_NAME}-backup.sql)

    test          : run tests
    test_lint     : run flake8 tests
    test_coverage : run tests with coverage output
    test_py       : alias of test_coverage

    start_dev     : start Django server for development

    make_migration: make migration files
    """
}

function pip_freeze {
    local VENV=/tmp/env
    rm -rf ${VENV}
    mkdir -p ${VENV}
    python3 -m venv ${VENV}

    ${VENV}/bin/pip install -q \
        -r conf/pip/primary_requirements.txt \
        --upgrade

    cat conf/pip/requirements_header.txt | tee conf/pip/requirements.txt
    ${VENV}/bin/pip freeze --local | grep -v appdir | tee -a conf/pip/requirements.txt
}

function backup_db {
    pg_isready

    if psql -c "" $DB_NAME; then
        echo "$DB_NAME database exists!"

        mkdir -p $BACKUPS_FOLDER
        local BACKUP_FILE=$BACKUPS_FOLDER/$DB_NAME-backup-$(date "+%Y%m%d%H%M%S").sql

        pg_dump $DB_NAME > $BACKUP_FILE
        chown -f trisiki:trisiki $BACKUP_FILE
        echo "$DB_NAME database backup created in [$BACKUP_FILE]."
    fi
}

function restore_db {
    pg_isready

    # backup current data
    backup_db

    # delete DB is exists
    if psql -c "" $DB_NAME; then
        dropdb -e $DB_NAME
        echo "$DB_NAME database deleted."
    fi

    createdb -e $DB_NAME -e ENCODING=UTF8
    echo "$DB_NAME database created."

    # load dump
    psql -e $DB_NAME < ${BACKUPS_FOLDER}/${DB_NAME}-backup.sql
    echo "$DB_NAME database dump restored."

    # migrate data model if needed
    ./manage.py migrate --noinput
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
    coverage erase || true
    rm -R /code/.coverage* 2>/dev/null || true

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

    cat /code/conf/extras/good_job.txt
}

function make_migration {
    ./manage.py makemigrations
}

case "$1" in
    bash )
        bash
    ;;

    eval )
        eval "${@:2}"
    ;;

    pip_freeze )
        pip_freeze
    ;;

    setup )
        setup
    ;;

    backup_db )
        backup_db
    ;;

    restore_dump )
        restore_db
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

    make_migration )
        make_migration
    ;;

    help )
        show_help
    ;;

    * )
        show_help
    ;;
esac
