#!/bin/bash

[ -z "$1" ] && datenstand=$(date +%Y/%m/%d) || datenstand=$1

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STAT_DIR=$THIS_DIR/../stat/
FILE=rki_stat_$(echo $datenstand | sed 's#/#_#g').txt

echo $FILE

source $THIS_DIR/../conf/db.config

cd $STAT_DIR

while IFS=$'\t' read idbundesland namebundesland enw ;do
	bundesland[$idbundesland]=$namebundesland
	einwohner[$idbundesland]=$enw
done  < <(mysql -u "$USER" -p"$PASS" -h "$HOST" rki -N -e "SELECT idbundesland, namebundesland, einwohner as enw from bundesland;")

  
altersgruppe1[1]="A00-A04"
altersgruppe1[2]="A05-A14"
altersgruppe1[3]="A15-A34"
altersgruppe1[4]="A35-A59"
altersgruppe1[5]="A60-A79"
altersgruppe1[6]="A80+"
altersgruppe1[7]="unbekannt"

altersgruppe2[1]="A00-A04"
altersgruppe2[2]="A05-A09"
altersgruppe2[3]="A10-A14"
altersgruppe2[4]="A15-A19"
altersgruppe2[5]="A20-A24"
altersgruppe2[6]="A25-A29"
altersgruppe2[7]="A30-A34"
altersgruppe2[8]="A35-A39"
altersgruppe2[9]="A40-A44"
altersgruppe2[10]="A45-A49"
altersgruppe2[11]="A50-A54"
altersgruppe2[12]="A55-A59"
altersgruppe2[13]="A60-A64"
altersgruppe2[14]="A65-A69"
altersgruppe2[15]="A70-A74"
altersgruppe2[16]="A75-A79"
altersgruppe2[17]="A80+"
altersgruppe2[18]="unbekannt"

declare -n altersgruppe=altersgruppe1
altersgruppe_in_db="altersgruppe"
if [ "$datenstand" = "2020/04/28" ]; then
  declare -n altersgruppe=altersgruppe2
  altersgruppe_in_db="altersgruppe2"
fi
if [ "$datenstand" = "2020/04/29" ]; then
  declare -n altersgruppe=altersgruppe2
  altersgruppe_in_db="altersgruppe2"
fi

query="call CreateSimpleRKIStatBundesland('$datenstand');"
mysql -u "$USER" -p"$PASS" -h "$HOST" rki -e "$query"

query="call CreateSimpleRKIStatAltersgruppe('$datenstand');"
mysql -u "$USER" -p"$PASS" -h "$HOST" rki -e "$query"

function main {
echo "Datum der Auswertung: $datenstand" > $FILE

echo -e '\n' >> $FILE 

for n in {0..16}
do
text_to_file "------------------------------------------------Kennzahlen ${bundesland[$n]} (Einwohner ${einwohner[$n]}) --------------------------------------------"                 

# Einfache Statistik
query="select fallzahl as '7-Tage-Fallzahl', incidence as '7-Tage-Inzidenz' from covid19_simple_stat_bundesland where datenstand ='$datenstand' and idbundesland = $n"
query_to_file "$query"

query="select faelle_gesamt as 'Faelle insgesamt', faelle_neu as 'Neue Faelle', tote_gesamt as 'Gestorbene insgesamt', tote_neu as 'Neue Gestorbene', tote_gesamt / faelle_gesamt as 'Rate gestorben',  genesen_gesamt 'Genesene insgesamt', genesen_neu as 'Neue Genesene', genesen_gesamt / faelle_gesamt as 'Rate genesen' from covid19_simple_stat_bundesland where datenstand ='$datenstand' and idbundesland = $n"
query_to_file "$query"

# Altergruppen
query="select m1.$altersgruppe_in_db as Altersgruppe, m1.summe as 'Faelle gesamt', m2.summe as 'Gestorbene gesamt', m2.summe / m1.summe as 'Rate gestorben' , m3.summe as 'Genesene gesamt', m3.summe / m1.summe as 'Rate genesen' from (
		select $altersgruppe_in_db, sum(anzahlfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerFall = 1 or NeuerFall = 0) group by $altersgruppe_in_db
	) as m1 join (
		select $altersgruppe_in_db, sum(anzahltodesfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerTodesFall = 1 or NeuerTodesFall = 0) group by $altersgruppe_in_db
	) as m2 join (
		select $altersgruppe_in_db, sum(anzahlgenesen) as summe from covid19 where datenstand = '$datenstand' and (IF($n=0,true, false) or IDBundesland = $n) and (NeuGenesen = 1 or NeuGenesen = 0) group by $altersgruppe_in_db
	) as m3
	on m1.$altersgruppe_in_db = m2.$altersgruppe_in_db and m2.$altersgruppe_in_db = m3.$altersgruppe_in_db;"
query_to_file "$query"

# Neue Faelle mit Meldedatum innerhalb von 7 Tagen je 100 Tsd. Einwohner (7-Tage-Inzidenz)
query="select datenstand, incidence from covid19_simple_stat_bundesland where idbundesland = $n and incidence is not null and datenstand <= '$datenstand'"
title="Neue Faelle mit Meldedatum innerhalb von 7 Tagen je 100 Tsd. (7-Tage-Inzidenz)"
xLabel="Publikationsdatum"
yLabel="7-Tage-Inzidenz"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel" 

# Neue Gestorbene mit Meldedatum innerhalb von 30 Tagen je 1 Mio. Einwohner bezogen auf das Publikationsdatum
query="select datenstand, tote_incidence from covid19_simple_stat_bundesland where idbundesland = $n and tote_incidence is not null and datenstand <= '$datenstand'"
title="Neue Gestorbene mit Meldedatum innerhalb von 30 Tagen je 1 Mio. bezogen auf das Publikationsdatum"
xLabel="Publikationsdatum"
yLabel="Tote"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

# Anteil Gestorbener an den Faellen bezogen auf das Publikationsdatum
query="select datenstand, rate_gesamt from covid19_simple_stat_bundesland where idbundesland = $n and rate_gesamt is not null and datenstand <= '$datenstand'"
title="Anteil Gestorbener an den Faellen bezogen auf das Publikationsdatum"
xLabel="Publikationsdatum"
yLabel="Anteil Gestorbener"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

# Gestorbene nach Meldedatum in der aktuellen Publikation je 1 Mio. Einwohner
query="select meldedatum, sum(AnzahlTodesfall) / (${einwohner[$n]} / 1000000) from covid19 where (IF($n=0,true, false) or IDBundesland = $n) and datenstand = '$datenstand' and (NeuerTodesfall = 1 or NeuerTodesFall = 0) group by meldedatum"
title="Gestorbene nach Meldedatum je 1 Mio. in der aktuellen Publikation"
xLabel="Meldedatum"
yLabel="Gestorbene"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

done

#for m in {1..3}
#for m in {1..7}
#for m in "${altersgruppe[@]}"
for m in "${!altersgruppe[@]}"
do
	echo "+++++++++++++++++++++++++++++++++++++++++Kennzahl ${altersgruppe[$m]} ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $FILE
# Gestorbene nach Meldedatum in der aktuellen Publikation je 1 Mio. Einwohner
query="select meldedatum, sum(AnzahlTodesfall) from covid19 where $altersgruppe_in_db = '${altersgruppe[$m]}' and datenstand = '$datenstand' and (NeuerTodesfall = 1 or NeuerTodesFall = 0) group by meldedatum"
title="Gestorbene nach Meldedatum der Altersgruppe in der aktuellen Publikation"
xLabel="Meldedatum"
xLabel="Gestorbene"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

# Anteil Gestorbener an den Faellen bezogen auf das Publikationsdatum
query="select m1.datenstand, m2.tote / m1.tote_gesamt from (
	select datenstand, sum(tote_gesamt) as tote_gesamt from covid19_simple_stat_altersgruppe where datenstand <= '$datenstand' group by datenstand
) as m1 inner join (
	select datenstand, tote_gesamt as tote from covid19_simple_stat_altersgruppe where altersgruppe = '${altersgruppe[$m]}' and datenstand <= '$datenstand' group by datenstand
) as m2 on m1.datenstand = m2.datenstand"
title="Anteil Gestorbener in der Altersgruppe an den Gestorbenen bezogen auf das Publikationsdatum"
xLabel="Publikationsdatum"
yLabel="Anteil Gestorbener"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

# Sterberate je Meldewoche 
query="SELECT STR_TO_DATE(concat(m1.kw,' Sunday'), '%X%V %W'), IFNULL(m2.tote_gesamt, 0) / m1.faelle_gesamt FROM 
(
(SELECT $altersgruppe_in_db, yearweek(str_to_date(meldedatum, '%Y/%m/%d')) AS kw, Sum(AnzahlFall) as faelle_gesamt FROM covid19 where datenstand = '$datenstand' AND (NeuerFall = 1 OR NeuerFall = 0) AND $altersgruppe_in_db = '${altersgruppe[$m]}' GROUP BY yearweek(str_to_date(meldedatum, '%Y/%m/%d'))) m1
LEFT JOIN
(SELECT $altersgruppe_in_db, yearweek(str_to_date(meldedatum, '%Y/%m/%d')) AS kw, Sum(AnzahlTodesFall) as tote_gesamt FROM  covid19 where datenstand = '$datenstand' AND (NeuerTodesFall = 1 OR NeuerTodesFall = 0) AND $altersgruppe_in_db = '${altersgruppe[$m]}' GROUP BY yearweek(str_to_date(meldedatum, '%Y/%m/%d'))) m2 ON  m1.kw = m2.kw
);"
title="Sterberate je Meldewoche"
xLabel="Meldewoche"
yLabel="Sterberate"
plot_query_to_file2 "$query" "$title" "$xLabel" "$yLabel"

done

}

function query_to_file {
	mysql -u "$USER" -p"$PASS" -h "$HOST" rki --table -e "$1" >> $FILE
}

function text_to_file {
	echo "$1" >> $FILE
}

function plot_query_to_file {

	outputFile="$STAT_DIR"plot_output.txt
	inputFile="$STAT_DIR"plot_input.csv
	
	query=$1
	title=$2
	xLabel=$3
	yLabel=$4

	mysql -u "$USER" -p"$PASS" -h "$HOST" rki --raw -N -L -e "$query" > $inputFile

	gnuplot <<- EOF
	reset
	set title '$title'
	set xlabel '$xLabel'
	set ylabel '$yLabel'
	set xdata time
	set timefmt '%Y/%m/%d'
	set format x '%Y/%m/%d'
	set output '$outputFile' 
	set terminal dumb size 200, 60;
	set autoscale;
	plot '$inputFile' using 1:2 with lines title '';
	EOF
	
	cat $outputFile >> $FILE
	
	rm $outputFile
	rm $inputFile
}

function plot_query_to_file2 {

	outputFile="$STAT_DIR"plot_output.txt
	inputFile="$STAT_DIR"plot_input.csv
	
	query=$1
	title=$2
	xLabel=$3
	yLabel=$4

	mysql -u "$USER" -p"$PASS" -h "$HOST" rki --raw -N -L -e "$query" > $inputFile

	gnuplot <<- EOF
	reset
	set title '$title'

	set xlabel '$xLabel'
	set ylabel '$yLabel'
	set xdata time
	set timefmt '%Y-%m-%d'
	set format x '%Y-%m-%d'
	set output '$outputFile' 
	set terminal dumb size 200, 60;
	set autoscale;
	plot '$inputFile' using 1:2 title '';
	EOF
	
	cat $outputFile >> $FILE
	
	rm $outputFile
	rm $inputFile
}

main