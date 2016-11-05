#!/bin/sh

version=`psql -X -qtc "SELECT current_setting('server_version_num')"` || exit $?

if [ "$1" == "-d" ]; then
    shift
    if [ $version -ge 90200 ]; then
        dropdb --if-exists $@ || exit $?
    else
        psql -c 'SELECT 1' $@ >/dev/null 2>&1 && (dropdb $@ || exit $?)
    fi
fi

createdb $@ || exit $?

cd `dirname $0` || exit $?

psql -X -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS cat_tools;' $@ || exit $?
psql -X -v ON_ERROR_STOP=1 -f catalog.sql $@ || exit $?

if [ $version -ge 90400 ]; then
    psql -X -v ON_ERROR_STOP=1 -f views/expanded.sql $@ || exit $?
else
    echo "$0: expanded views are not supported on versions older than 9.4"
fi
