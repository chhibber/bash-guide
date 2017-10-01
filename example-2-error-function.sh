#!/usr/bin/env bash

source bash-guide-functions.sh

echo "Listing a file:"
ls /a/file/that/does/not/exist 2>/dev/null
error $? "Unable to list the file"



