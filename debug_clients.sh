#!/bin/bash

# Running this will open $1 (default: 2) game instances connected to each other in a random room
# This assumes there is a server running on localhost

COUNT=${1:-2}
ROOM=`uuidgen`
((COUNT--))

for i in `seq 1 $COUNT`; do
    love client/ --host=localhost --char=melee --auto-connect --room=$ROOM --auto-ready=0.5 "${@:2}" &>/dev/null &
done
love client/ --host=localhost --char=ranged --auto-connect --room=$ROOM --auto-ready=0.5 "${@:2}" &
