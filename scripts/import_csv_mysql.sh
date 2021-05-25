#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DATA_DIR=$THIS_DIR/../data/cases

source $THIS_DIR/../conf/db.config

cd $DATA_DIR

# Skript ohne Parameter wirkt auf alle CSV-Dateien(*.csv), sonst nur auf die CSV-Datei die als erster Parameter übergeben wird.
[ -z "$1" ] && files="*.csv" || files=$(basename $1)

find . -name "$files" | sort |while read file;
do
    echo "################## Import $file ####################"
    header="$(head -n 1 $file)"
    echo "++++++++++ Header $header ++++++++++++++++++++++"
	mysql -u "$USER" -p"$PASS" -h "$HOST" --execute="LOAD DATA LOCAL INFILE '$file' INTO TABLE rki.covid19 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES ($header); SHOW WARNINGS"
done

