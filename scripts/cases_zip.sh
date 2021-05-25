#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DATA_DIR=$THIS_DIR/../data/cases

cd $DATA_DIR

[ -z "$1" ] && files="*.csv" || files=$(basename $1)

find "$DATA_DIR" -name "$files" -exec zip -j {}.zip {} \; -exec rm {} \;
