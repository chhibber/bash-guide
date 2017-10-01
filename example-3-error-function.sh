#!/usr/bin/env bash

source bash-guide-functions.sh

echo "Getting content from a site:"

_http_return_code=$(curl -s -I http://www.example.org/doesnotexist | head -n 1| cut -d$' ' -f2)
if [[ ${_http_return_code} -ne 200 ]]; then
  error 1 "Unable to download file"
fi

