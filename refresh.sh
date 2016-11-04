#!/bin/sh

die() {
    ret=$1
    shift
    echo $@ 1>&2
    exit $ret
}

cd `dirname $0` || die $@ cd returned $?
./load.sh -d $@ || die $? load.sh returned $?
./update.sh $@ || die $? update.sh returned $?
