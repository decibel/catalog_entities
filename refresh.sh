#!/bin/sh

die() {
    ret=$1
    shift
    echo $@ 1>&2
    exit $ret
}

./load.sh -d $@ || die $? load.sh returned $?
./update.sh $@ || die $? update.sh returned $?
