#!/bin/bash

# Search for android devices
PATTERN="android[\S]+"

# Search for iPhone devices
PATTERN="iPhone[\S]+"

# Search for PC devices
PATTERN="(PC|DESKTOP)[\S]+"

function gethelp {
  printf "\nGet Auth script by @faustinoaq\n\n"
  printf "Search for auth data in binary files created by lastline.sh\n"
  printf "Required bin dir with *.bin files\n"
  printf "$ ./getauth.sh\n\n"
}

function count {
  c=$(ls bin | grep --count .bin)
  p=$((($2*100)/c))
  printf "Stat=$2/$c, $p%%, File=$1.dat                   \r"
}

function main {
  ls -R | grep -q .bin
  if [[ $? == 0 ]]
  then
    BIN=$(ls bin/*.bin)
    mkdir -p dat
  else
    gethelp
    exit 1
  fi
  printf "Searching auth data...\n"
  n=0
  for i in $BIN
  do
    j=$(basename $i .bin)   
    hexdump -c $i | sed -r 's/\S+//1' | sed ':a;N;$!ba;s/\n//g' |\
    sed 's/ //g' | grep -o -E "$PATTERN" | sort -u | tee > dat/$j.dat
    n=$((n+1))
    count $j $n
  done
  i=$(wc -l dat/*.dat | grep --count -E "^\s+[0123]")
  e=$(wc -l dat/*.dat | grep --count -E "^\s+[01]")
  v=$(wc -l dat/*.dat | grep --count -E "^\s+[23]")
  printf "\nFound=$i, Empty=$e, Valid=$v\nAll done!\n"
  exit 0
}

main
