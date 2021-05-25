#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd $THIS_DIR

./get_cases.sh
./qs-actions.sh "$(date +%Y-%m-%d).csv"
./import_csv_mysql.sh "$(date +%Y-%m-%d).csv"
./cases_zip.sh "$(date +%Y-%m-%d).csv" 
./rki_stat.sh "$(date +%Y/%m/%d)"
