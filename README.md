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
  * Diagram "Deaths by reporting date of the age group in the current publication"
  * Diagram "Proportion of deaths in the age group of those who died in relation to the date of publication"
  
Note on age groups: RKI only provided data with smaller age groups (alterspruppe2) on April 28, 2020 and April 29, 2020 
via the above-mentioned source. With regard to the uniformity of the evaluations, this feature is therefore ignored.  

For smaller age groups, however, the number of cases and the number of deaths up to the 13th calendar week of 2021 
can also be taken indirectly from RKI situation reports 
(see [situation report](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Situationsberichte/Apr_2021/2021-04-06-de.pdf?__blob=publicationFile) and 
[age distribution](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx?__blob=publicationFile)). 

This yields to:

| age group | deaths up to 2021/13 | cases up to 2021/13 | death rate up to 2021/13 |                                                                                                               
|:----------|----------------------|---------------------|:------------------------|
| 90\+    | 17462                 | 70889               | 0,246328768             |
| 80 - 89  | 35610           | 194619               | 0,182972885         |  
| 70 - 79  | 14997                 | 166666            | 0,08998236         |  
| 60 - 69  | 6075                 | 273264          | 0,022231249         |    
| 50 - 59  | 2085           | 486412               | 0,00428649         |   
| 40 - 49  | 441                 | 411075        | 0,001072797         |  
| 30 - 39  | 149           | 439015        | 0,000339396         |  
| 20 - 29  | 53           | 450001         | 0,000117778         |   
| 10 - 19  | 6\*                  | 255943         | 0,0000234427\*         |   
| 0 - 9    | 12\*           | 146219         | 0,0000820687\*       |  

\*: Could be lower according to RKI.

For calculations see [here.](./ref/Altersverteilung2.xlsx)

In comparison the probability of death per age group for year 2017: (Source: [Statista](https://de.statista.com/statistik/daten/studie/3057/umfrage/sterbeziffern-nach-alter-und-geschlecht/):

| age group | death rate 2017 | factor compared to death rate covid19 |                                                                                                              
|:----------|:------------------------|:-----|
| 90\+      | 0,4849                  | 1,96 |
| 80 - 89   | 0,3657                  | 2,0  |
| 70 - 79   | 0,1092                  | 1,21 |
| 60 - 69   | 0,0454         		  | 2,04 |  
| 50 - 59   | 0,0177                  | 4,13 |
| 40 - 49  | 0,006                    | 5,59 |
| 30 - 39  | 0,0025                   | 7,37 |
| 20 - 29  | 0,0013                   | 11,04 | 
| 10 - 19  | 0,0006  | 25,59 | 
| 0 - 9    | 0,007   | 85,29 |

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
