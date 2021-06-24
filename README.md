# covid19_txt_stat
The aim of this project is to create an evaluation of all Covid19 data published by german Robert Koch Institute (RKI) as text files.

RKI publishes the complete data status on the current publication date on a daily basis. RKI does not publicly provided earlier publications that are outdated.
Therefore, some of the data was not obtained directly from RKI but also from other sources.

Source RKI:

* [RKI Case Report](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html) licensed under [Open Data Datenlizenz Deutschland Version 2.0](https://www.govdata.de/dl-de/by-2-0)

Further sources are:

* https://github.com/CharlesStr/CSV-Dateien-mit-Covid-19-Infektionen-

* https://github.com/ard-data/2020-rki-archive

## Scope of the evaluations
A text file with the following evaluation characteristics is created for each publication date:
 
* For every federal state and all of Germany: 
  * 7-day sample size and 7-day incidence
  * Total cases, new cases, total deaths, new deaths, death rate, total recovery, new recovered, recovery rate
  * For each age group total cases, total deaths, death rate, total recovery, recovery rate
  * Diagram "New cases with reporting date within 7 days per 100 thousand (7-day incidence)"
  * Diagram "New deaths with reporting date within 30 days per 1 million in relation to the publication date"
  * Diagram "Death rate related to the date of publication"
  * Diagram "Deaths by reporting date per 1 million in the current publication"
* For every group of age:
  * Infection fatality rate and actual number of infections \*\*
  * Diagram "Deaths by reporting date of the age group in the current publication"
  * Diagram "Proportion of deaths in the age group of those who died in relation to the date of publication"
  * Diagram "Death rate per reporting week"
  * Diagram "Proportion of newly deceased with a reporting date of more than 30 days"
  
Note on age groups: RKI only provided data with smaller age groups (alterspruppe2) on April 28, 2020 and April 29, 2020 
via the above-mentioned source. With regard to the uniformity of the evaluations, this feature is therefore ignored.  

For smaller age groups, however, the number of cases and the number of deaths up to the 13th calendar week of 2021 
can also be taken indirectly from RKI situation reports 
(see [situation report](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Situationsberichte/Apr_2021/2021-04-06-de.pdf?__blob=publicationFile) and 
[age distribution](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx?__blob=publicationFile)). 

This yields to:

| age group | deaths | cases  | death rate (%) | ifr (%) \*\* | infections \*\* |                                                                                                              
|:----------|--------|--------|:---------------|:-------------|-----------------|
| 80\+  	| 53072  | 265508 | 19,9888516     | 6,284515995  | 844488 			|
| 70 - 79  	| 14997  | 166666 | 8,998236       | 1,417722763  | 1057823 		|
| 60 - 69  	| 6075   | 273264 | 2,2231249      | 0,398469707  | 1524583 		|
| 50 - 59  	| 2085   | 486412 | 0,428649       | 0,110163609  | 1892640 		|
| 40 - 49  	| 441    | 411075 | 0,1072797      | 0,023300792  | 1432616 		|
| 30 - 39  	| 149    | 439015 | 0,0339396      | 0,009634081  | 1546593			|
| 20 - 29  	| 53     | 450001 | 0,0117778      | 0,003928642  | 1349067 		|
| 10 - 19  	| 6\*    | 255943 | 0,00234427\*   | 0,000556297  | 1078560			|
| 0 - 9    	| 12\*   | 146219 | 0,00820687\*   | 0,001088078  | 1102862 		|
| total     | 76890  | 2894103| 2,6567817	   | 0,649999932  | 11829232 		|

\*: Could be lower according to RKI.

For calculations see [here.](./ref/Altersverteilung2.xlsx)

\*\*: Note on infection fatality rate: It is assumed across all age groups that 65% of those infected develop symptoms and 1% of those who are symptomatically infected die of pneumonia. 
Accordingly, the total infection fatality rate (IFR) is 0.65%. It is also assumed that this IFR is constant over time and that every person has the same risk of getting infected. 
The IFR for each age group is then estimated independently of the published case numbers based on the age distribution in Germany and the proportion of deaths in the age group. 
The actual infections can then be calculated for each age group from the number of deaths and the IFR of the age group or, equivalent, from the total infection fatality rate, the total number of deaths and the age distribution.

In comparison the probability of death per age group for year 2017 (Source: [Statista](https://de.statista.com/statistik/daten/studie/3057/umfrage/sterbeziffern-nach-alter-und-geschlecht/)):

| age group | death rate (%) |                                                                                                              
|:----------|:---------------|
| 90\+      | 48,49          |
| 80 - 89   | 36,57          |
| 70 - 79   | 10,92          |
| 60 - 69   | 4,54           |  
| 50 - 59   | 1,77           |
| 40 - 49   | 0,6            |
| 30 - 39   | 0,25           |
| 20 - 29   | 0,13           | 
| 10 - 19   | 0,06  	     | 
| 0 - 9     | 0,7   	     |

## Project structure
The following files are included:

| File                       | Content                                                                                                                    |
|:---------------------------|:---------------------------------------------------------------------------------------------------------------------------|
| stat/\*                   | Text files with the evaluation characteristics for each publication date.                                                  |
| data/\*                   | CSV files with cases. Run ./scripts/get_cases_all.sh to get some that are already in a consistent and processable format.| 
| db/\*                 | SQL files with the data structure for the evaluations. To be setup manually.                          |
| conf/db.config       | Configuration according to your database setup.                                         |
| scripts/cases_unzip.sh     | Bash script to unzip CSV files.                                                                                            |
| scripts/cases_zip.sh       | Bash script to zip CSV files.                                                                                |
| scripts/qs_actions.sh     | Bash script to clean up the CSV files into a consistent format.                                                            |
| scripts/import_csv_mysl.sh | Bash script to import the unzipped and cleaned CSV files to the database.                                                  |
| scripts/get_cases.sh     | Bash script to get the current data from RKI.                                                                              |
| scripts/rki_stat.sh        | Bash script to generate the evaluation for a publication date.                                                   |
| scripts/rki_stat_all.sh     | Bash script to generate the evaluation for all publications.                                                       |
| scripts/daily_job.sh     | Bash script for use in a cron job.                                                                        |

## System requirements
* Bash, version >=   5.0.3
* MySQL, version >= 15.1 Distrib 10.3.27-MariaDB
* Gnuplot, verion >= 5.2 patchlevel 6
* File, version >= 5.35
* Minumim 100 GB storage

## Getting started
* Setup database according to files in db folder and adjust parameter in db.config.
* Get some cases and run ./scripts/get_cases_all.sh
* Run ./scripts/import_csv_mysl.sh to import the cases into database.
* Run ./scripts/rki_stat_all.sh to generate the evaluation.

Do your own research and have fun!
