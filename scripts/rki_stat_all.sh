#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd $THIS_DIR

in=2020-03-23
out="$(date +%Y-%m-%d)"
while [ "$in" != "$out" ]; do
  in=$(date -I -d "$in + 1 day")
  x=$(date -d "$in" +%Y/%m/%d)
  echo $x
  ./rki_stat.sh -d "$x"	
done


