#!/usr/bin/env bash

set -Eeuo pipefail

function show_help {
    echo """
    Commands
    ----------------------------------------------------------------------------
    bash          : run bash
    eval          : eval shell command

    test          : run ALL tests
    test_lint     : run standardjs and sass lint tests
    test_js       : run js tests with enzyme and jest

    build         : create distributed assets
    start_dev     : start server for development
    """
}

function test_lint {
    npm run test-lint
}

function test_js {
    npm run test-js "${@:1}"
}


case "$1" in
    bash )
        bash
    ;;

    eval )
        eval "${@:2}"
    ;;

    test )
        CI=true npm run test -- --coverage
    ;;

    test_lint )
        test_lint
    ;;

    test_js )
        test_js "${@:2}"
    ;;

    build )
        rm -r -f ./bundles/*
        npm run build
    ;;

    start_dev )
        # a=1
        # while [ $a == 1 ]
        # do
        #     sleep 5
        #     echo "waiting..."
        # done
        npm run start
    ;;

    help )
        show_help
    ;;

    * )
        show_help
    ;;
esac
