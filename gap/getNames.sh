#!/bin/bash
# Utility command to get all symbol names from the JSON
if [[ $# -eq 0 ]] ; then
    echo "Requires json filename as argument"
    exit 1
fi
cat $1 | jq '[.[] | .name]' | sed 's/Setter(\(.*\))/Set\1/' | sed 's/Tester(\(.*\))/Has\1/' | sed 's/(.*)//' | sed 's/["|,| ]//g'
