#!/bin/bash

# Running this will open two game instances connected to each other in a random room
# This assumes there is a server running on localhost

ROOM=`uuidgen`
love client/ --host=localhost --char=melee --auto-connect --room=$ROOM &>/dev/null &
love client/ --host=localhost --char=ranged --auto-connect --room=$ROOM &
