#!/bin/bash
HASH_LOCATION="/opt/integrity_check"

echo "Checking Axiom system files..."
output=$(hashdeep -c sha256 -x -f $HASH_LOCATION/files.txt -k $HASH_LOCATION/hashes.txt)

if [ -z "$output" ]; then
    echo "No problems detected, all files are in factory state."
else
    echo "The files below didn't match those shipped with the firmware:"
    echo $output
    echo -e "\nIf you didn't change anything on purpose, you may want to consult with apertus."
    exit 1
fi
