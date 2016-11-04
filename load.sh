#!/bin/sh

if [ "$1" == "-d" ]; then
    shift
    dropdb --if-exists $@ || exit $?
fi

createdb $@ || exit $?
psql -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS cat_tools;' $@ || exit $?
psql -v ON_ERROR_STOP=1 -f catalog.sql $@ || exit $?
