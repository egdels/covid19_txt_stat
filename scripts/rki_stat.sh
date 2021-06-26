#!/bin/bash

# Usage:
# -d '2020/04/29' -o html
# -d '2020/04/28' -o txt	

# Defaults
output="txt"
datenstand=$(date +%Y/%m/%d)

while getopts o:d: flag
do
    case "${flag}" in
        o) output=${OPTARG};;
        d) datenstand=${OPTARG};;
    esac
done

[ $output != "html" ] && [ $output != "txt" ] && echo "-o darf nur die Werte txt oder html haben" && exit 1

date "+%Y/%m/%d" -d $datenstand > /dev/null  2>&1
is_valid=$?
[ "$is_valid" != "0" ] && echo "-d muss im Format %Y/%m/%d sein" && exit 1

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STAT_DIR=$THIS_DIR/../stat/
FILE=rki_stat_$(echo $datenstand | sed 's#/#_#g').$output

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

altersverteilung1[1]=0.047731784
altersverteilung1[2]=0.090297146
altersverteilung1[3]=0.22754236
altersverteilung1[4]=0.344731589
altersverteilung1[5]=0.218307164
altersverteilung1[6]=0.071389956
altersverteilung1[7]=0 # unbekannt

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

altersverteilung2[1]=0.047731784
altersverteilung2[2]=0.045500169
altersverteilung2[3]=0.044796977
altersverteilung2[4]=0.046380525
altersverteilung2[5]=0.054963493
altersverteilung2[6]=0.059081681
altersverteilung2[7]=0.067116661
altersverteilung2[8]=0.063626649
altersverteilung2[9]=0.060548207
altersverteilung2[10]=0.060559896
altersverteilung2[11]=0.078013608
altersverteilung2[12]=0.08198323
altersverteilung2[13]=0.069967348
altersverteilung2[14]=0.058915305
altersverteilung2[15]=0.047718941
altersverteilung2[16]=0.04170557
altersverteilung2[17]=0.071389956
altersverteilung2[18]=0 # unbekannt

declare -n altersgruppe=altersgruppe1
altersgruppe_in_db="altersgruppe"
declare -n altersverteilung=altersverteilung1
if [ "$datenstand" = "2020/04/28" ]; then
  declare -n altersgruppe=altersgruppe2
  altersgruppe_in_db="altersgruppe2"
  declare -n altersverteilung=altersverteilung2
fi
if [ "$datenstand" = "2020/04/29" ]; then
  declare -n altersgruppe=altersgruppe2
  altersgruppe_in_db="altersgruppe2"
  declare -n altersverteilung=altersverteilung2
fi

query="call CreateSimpleRKIStatBundesland('$datenstand');"
mysql -u "$USER" -p"$PASS" -h "$HOST" rki -e "$query"

query="call CreateSimpleRKIStatAltersgruppe('$datenstand');"
mysql -u "$USER" -p"$PASS" -h "$HOST" rki -e "$query"

function main {

for n in {0..16}
do
printHeader "Kennzahlen ${bundesland[$n]} (Einwohner ${einwohner[$n]})"                 

# Einfache Statistik
query="select fallzahl as '7-Tage-Fallzahl', incidence as '7-Tage-Inzidenz' from covid19_simple_stat_bundesland where datenstand ='$datenstand' and idbundesland = $n"
query_to_file "$query"

query="select faelle_gesamt as 'Faelle insgesamt', faelle_neu as 'Neue Faelle', tote_gesamt as 'Gestorbene insgesamt', tote_neu as 'Neue Gestorbene', tote_gesamt / faelle_gesamt as 'Rate gestorben',  genesen_gesamt 'Genesene insgesamt', genesen_neu as 'Neue Genesene', genesen_gesamt / faelle_gesamt as 'Rate genesen' from covid19_simple_stat_bundesland where datenstand ='$datenstand' and idbundesland = $n"
query_to_file "$query"

# Altergruppen
if [ "$n" -eq "0" ];
then
query="select m1.$altersgruppe_in_db as Altersgruppe, m1.summe as 'Faelle gesamt', m2.summe as 'Gestorbene gesamt', m2.summe / m1.summe as 'Rate gestorben' , m3.summe as 'Genesene gesamt', m3.summe / m1.summe as 'Rate genesen', (m2.summe / m4.tote_gesamt) * (0.65 / m5.anteil) as 'IFR* (%)', round (100 * m4.tote_gesamt * m5.anteil / 0.65, 0) as 'Infektionen*' from (
		select $altersgruppe_in_db, sum(anzahlfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerFall = 1 or NeuerFall = 0) group by $altersgruppe_in_db
	) as m1 join (
		select $altersgruppe_in_db, sum(anzahltodesfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerTodesFall = 1 or NeuerTodesFall = 0) group by $altersgruppe_in_db
	) as m2 join (
		select $altersgruppe_in_db, sum(anzahlgenesen) as summe from covid19 where datenstand = '$datenstand' and (IF($n=0,true, false) or IDBundesland = $n) and (NeuGenesen = 1 or NeuGenesen = 0) group by $altersgruppe_in_db
	) as m3 join (
		select sum(anzahltodesfall) as tote_gesamt from covid19 where datenstand = '$datenstand' and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerTodesFall = 1 or NeuerTodesFall = 0)
	) as m4 join (
		select gruppe, anteil as anteil from altersverteilung group by gruppe
	) as m5
	on m1.$altersgruppe_in_db = m2.$altersgruppe_in_db and m2.$altersgruppe_in_db = m3.$altersgruppe_in_db and m1.$altersgruppe_in_db = m5.gruppe where m1.$altersgruppe_in_db !='unbekannt'"
query_to_file "$query"

text_to_file "*: Es wird angenommen, dass über alle Altersgruppen 65 % der Infizierten Symptome entwickeln und 1 % von den symptomatisch Infizierten 
über alle Altersgruppen versterben. Demnach also die Infektionssterblichkeit (IFR) insgesamt bei 0,65 % liegt. Es wird ferner angegenommen, dass diese 
IFR über die Zeit konstant ist und jede Person das gleiche Risiko hat sich zu infizieren. Die IFR für die Altersgruppen werden dann auf Basis der Altersverteilung 
in Deutschland und dem Anteil der Verstorbenen in der Altersgruppe unabhängig von den gemeldeten Fallzahlen zum Publikationsdatum geschätzt. Die tatsächlichen 
Infektionen lassen sich dann für jede Altersgruppe aus der Anzahl der Verstorbenen und dem IFR der Altersgruppe oder gleichbedeutend über den gesamten IFR, die 
Gesamtanzahl der Verstorbenen und die Altersverteilung berechnen." 
else
query="select m1.$altersgruppe_in_db as Altersgruppe, m1.summe as 'Faelle gesamt', m2.summe as 'Gestorbene gesamt', m2.summe / m1.summe as 'Rate gestorben' , m3.summe as 'Genesene gesamt', m3.summe / m1.summe as 'Rate genesen' from (
		select $altersgruppe_in_db, sum(anzahlfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerFall = 1 or NeuerFall = 0) group by $altersgruppe_in_db
	) as m1 join (
		select $altersgruppe_in_db, sum(anzahltodesfall) as summe from covid19 where datenstand = '$datenstand'  and (IF($n=0,true, false) or IDBundesland = $n) and (NeuerTodesFall = 1 or NeuerTodesFall = 0) group by $altersgruppe_in_db
	) as m2 join (
		select $altersgruppe_in_db, sum(anzahlgenesen) as summe from covid19 where datenstand = '$datenstand' and (IF($n=0,true, false) or IDBundesland = $n) and (NeuGenesen = 1 or NeuGenesen = 0) group by $altersgruppe_in_db
	) as m3 on m1.$altersgruppe_in_db = m2.$altersgruppe_in_db and m2.$altersgruppe_in_db = m3.$altersgruppe_in_db"
query_to_file "$query"
fi

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
printHeader "Kennzahl ${altersgruppe[$m]}"
# Gestorbene nach Meldedatum in der aktuellen Publikation je 1 Mio. Einwohner
query="select meldedatum, sum(AnzahlTodesfall) from covid19 where $altersgruppe_in_db = '${altersgruppe[$m]}' and datenstand = '$datenstand' and (NeuerTodesfall = 1 or NeuerTodesFall = 0) group by meldedatum"
title="Gestorbene nach Meldedatum der Altersgruppe (${altersgruppe[$m]}) in der aktuellen Publikation"
xLabel="Meldedatum"
xLabel="Gestorbene"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel"

# Anteil Gestorbener an den Faellen bezogen auf das Publikationsdatum
query="select m1.datenstand, m2.tote / m1.tote_gesamt from (
	select datenstand, sum(tote_gesamt) as tote_gesamt from covid19_simple_stat_altersgruppe where datenstand <= '$datenstand' group by datenstand
) as m1 inner join (
	select datenstand, tote_gesamt as tote from covid19_simple_stat_altersgruppe where altersgruppe = '${altersgruppe[$m]}' and datenstand <= '$datenstand' group by datenstand
) as m2 on m1.datenstand = m2.datenstand"
title="Anteil Gestorbener in der Altersgruppe (${altersgruppe[$m]}) an den Gestorbenen bezogen auf das Publikationsdatum"
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
title="Sterberate je Meldewoche (${altersgruppe[$m]})"
xLabel="Meldewoche"
yLabel="Sterberate"
plot_query_to_file2 "$query" "$title" "$xLabel" "$yLabel"

query="SELECT date_format(STR_TO_DATE(concat(pwoche,' Sunday'), '%X%V %W'), '%Y/%m/%d'), tote_30 / tote_gesamt FROM (SELECT yearweek(str_to_date(datenstand, '%Y/%m/%d')) as pwoche, sum(tote_neu_30) as tote_30, sum(tote_neu) as tote_gesamt FROM covid19_simple_stat_altersgruppe WHERE datenstand <= '$datenstand' and altersgruppe = '${altersgruppe[$m]}' group by yearweek(str_to_date(datenstand, '%Y/%m/%d'))) m1"
title="Anteil der neu Verstorbenen (${altersgruppe[$m]})mit Meldedatum mehr als 30 Tage"
xLabel="Publikationsdatum"
yLabel="Neuverstorben mit Meldatum vor mehr als 30 Tagen"
plot_query_to_file "$query" "$title" "$xLabel" "$yLabel" 


done

}

function query_to_file {
	if [ "$output" == "html" ]; then
		query_to_file_html "$1" 
	else
		query_to_file_txt "$1"
	fi
}

function query_to_file_txt {
	mysql -u "$USER" -p"$PASS" -h "$HOST" rki --table -e "$1" >> $FILE
}

function query_to_file_html {
	echo "<div>" >> $FILE
	mysql -u "$USER" -p"$PASS" -h "$HOST" rki -H -e "$1" >> $FILE
	echo "</div>" >> $FILE
}

function text_to_file {
	echo "$1" >> $FILE
}

function plot_query_to_file_txt {
	outputFile="$STAT_DIR"plot_output.txt
	inputFile="$STAT_DIR"plot_input.csv
	
	#set terminal dumb size 200, 60;
	
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

function plot_query_to_file_html {

	outputFile="$STAT_DIR"plot_output.svg
	inputFile="$STAT_DIR"plot_input.csv
	
	#set terminal dumb size 200, 60;
	
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
	set term svg size 900,400
	set autoscale;
	plot '$inputFile' using 1:2 with lines title '';
	EOF
	
	b64=$(base64 $outputFile)
	echo "<div style='clear:both'><img src='data:image/svg+xml;base64,$b64'></div>" >> $FILE
	#cat $outputFile >> $FILE
	
	rm $outputFile
	rm $inputFile
}

function plot_query_to_file2_txt {
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

function plot_query_to_file2_html {
	outputFile="$STAT_DIR"plot_output.svg
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
	set term svg size 900,400;
	set autoscale;
	plot '$inputFile' using 1:2 title '';
	EOF
	
	b64=$(base64 $outputFile)
	echo "<div style='clear:both'><img src='data:image/svg+xml;base64,$b64'></div>" >> $FILE
	#cat $outputFile >> $FILE
	
	rm $outputFile
	rm $inputFile
}

function plot_query_to_file {
	if [ "$output" == "html" ]; then
		plot_query_to_file_html "$1" "$2" "$3" "$4"
	else
		plot_query_to_file_txt "$1" "$2" "$3" "$4"
	fi
}

function plot_query_to_file2 {
	if [ "$output" == "html" ]; then
		plot_query_to_file2_html "$1" "$2" "$3" "$4"
	else
		plot_query_to_file2_txt "$1" "$2" "$3" "$4"
	fi
}

function printOpening {
	if [ "$output" == "html" ]; then
		echo "<html><head><title>Datum der Auswertung: $datenstand</title><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'></head><body><div id='content' style='max-width: 1200px; margin: auto'>" > $FILE
		text_to_file "<h1>Datum der Auswertung: $datenstand</h1>"
	else
		echo "Datum der Auswertung: $datenstand" > $FILE
		echo -e '\n' >> $FILE 
	fi
}

function printClosing {
	if [ "$output" == "html" ]; then
		echo "</div></body></html>" >> $FILE
	fi
}

function printHeader {
	if [ "$output" == "html" ]; then
		text_to_file "<h2>$1</h2>"
	else
		text_to_file "###################################################################### $1 ######################################################################"
	fi  
}

printOpening
main
printClosing