#!/bin/sh

./load.sh $@ || exit $?
./update.sh $@ || exit $?
