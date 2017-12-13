#!/bin/bash

# Clean files script by @faustinoaq
# Clean temp files created by lastline.sh and getauth.sh
# $ ./clean.sh

function main {
  read -p "Are you sure of delete all files? (y/n): " R
  if [[ $R == 'y' ]]
  then
    rm -rf bin dat *.ok *.fail *.header *.ips *.tmp *.error paused.conf
    printf "All temp files deleted!\n"
    exit 0
  fi
  printf "Nothing deleted!\n"
  exit 1
}

main
