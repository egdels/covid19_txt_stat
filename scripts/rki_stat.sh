#!/bin/bash

[ -z "$1" ] && datenstand=$(date +%Y/%m/%d) || datenstand=$1

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STAT_DIR=$THIS_DIR/../stat/
FILE=rki_stat_$(echo $datenstand | sed 's#/#_#g').txt

source $THIS_DIR/../conf/db.config

cd $STAT_DIR

while IFS=$'\t' read idbundesland namebundesland enw ;do
	bundesland[$idbundesland]=$namebundesland
	einwohner[$idbundesland]=$enw
done  < <(mysql -u "$USER" -p"$PASS" -h "$HOST" rki -N -e "SELECT idbundesland, namebundesland, einwohner as enw from bundesland;")

  
altersgruppe[1]="A00-A04"
altersgruppe[2]="A05-A14"
altersgruppe[3]="A15-A34"
altersgruppe[4]="A35-A59"
altersgruppe[5]="A60-A79"
altersgruppe[6]="A80+"
altersgruppe[7]="unbekannt"

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
query="select m1.altersgruppe as Altersgruppe, m1.summe as 'Faelle gesamt', m2.summe as 'Gestorbene gesamt', m2.summe / m1.summe as 'Rate gestorben' , m3.summe as 'Genesene gesamt', m3.summe / m1.summe as 'Rate genesen' from (
		select Altersgruppe, sum(anzahlfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerFall = 1 or NeuerFall = 0) group by Altersgruppe
	) as m1 join (
		select Altersgruppe, sum(anzahltodesfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerTodesFall = 1 or NeuerTodesFall = 0) group by Altersgruppe
	) as m2 join (
		select Altersgruppe, sum(anzahlgenesen) as summe from covid19 where datenstand = '$datenstand' and (IF($n=0,true, false) or IDBundesland = $n) and (NeuGenesen = 1 or NeuGenesen = 0) group by Altersgruppe
	) as m3
	on m1.altersgruppe = m2.altersgruppe and m2.altersgruppe = m3.altersgruppe;"
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
for m in {1..7}
do
	echo "+++++++++++++++++++++++++++++++++++++++++Kennzahl ${altersgruppe[$m]} ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $FILE

# Gestorbene nach Meldedatum in der aktuellen Publikation je 1 Mio. Einwohner
query="select meldedatum, sum(AnzahlTodesfall) from covid19 where altersgruppe = '${altersgruppe[$m]}' and datenstand = '$datenstand' and (NeuerTodesfall = 1 or NeuerTodesFall = 0) group by meldedatum"
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
	set terminal dumb size 120, 30;
	set autoscale;
	plot '$inputFile' using 1:2 with lines title '';
	EOF
	
	cat $outputFile >> $FILE
	
	rm $outputFile
	rm $inputFile
}

main