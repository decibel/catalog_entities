#!/bin/sh

DATA=data.csv

changes=`psql -X -qtc 'SELECT count(*) FROM current_version_delta' $@`
ret=$?
[ $ret -eq 0 ] || exit $ret

if [ $changes -eq 0 ]; then
    echo No changes
else
    cd `dirname $0`

    versions=`psql -X -qtc "SELECT min(version) || ',' || max(version) FROM current_version_relation" $@`
    ret=$?
    [ $ret -eq 0 ] || exit $ret
    
    version=`echo $versions | cut -d, -f1`
    if [ $version != `echo $versions | cut -d, -f2` ]; then
        echo "version error: $versions"
        exit 1
    fi

    echo "Found $changes changes for version $version; updating"

    # Make sure file doesn't already have changes
    if ! git diff --quiet $DATA; then
        echo "Uncommitted changes in $DATA; please commit first"
        exit 1
    fi

    psql -X -f update.sql $@ || exit 1
    ./dump.sh $@ || exit 1

    # Now there should be changes
    if git diff --quiet $DATA; then
        echo "No changes written to $DATA; something went wrong!"
        exit 1
    fi

    git add $DATA || exit 1
    git commit -m "Update version $version" $DATA
fi
