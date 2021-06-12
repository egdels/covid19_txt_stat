-- Exportiere Struktur von Prozedur rki.CreateSimpleRKIStatAltersgruppe
DELIMITER //
CREATE PROCEDURE `CreateSimpleRKIStatAltersgruppe`(
	IN `d` VARCHAR(10)
)
BEGIN

 -- ggfs alte statistic loeschen
delete from covid19_simple_stat_altersgruppe where datenstand = d;

INSERT INTO covid19_simple_stat_altersgruppe ( datenstand, altersgruppe, faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, tote_neu_30, tote_neu_40, tote_neu_50, tote_neu_60, tote_neu_70,genesen_gesamt, genesen_neu, rate_gesamt, rate_neu, faelle_fehler, tote_fehler, genesen_fehler)
SELECT m1.datenstand, m1.altersgruppe, m1.faelle_gesamt, IFNULL(faelle_neu, 0), tote_gesamt, IFNULL(tote_neu, 0), IFNULL(tote_neu_30, 0), IFNULL(tote_neu_40, 0), IFNULL(tote_neu_50, 0), IFNULL(tote_neu_60, 0), IFNULL(tote_neu_70, 0), genesen_gesamt, IFNULL(genesen_neu, 0), tote_gesamt / faelle_gesamt AS rate_gesamt, tote_neu / faelle_neu AS rate_neu, IFNULL(faelle_gesamt, 0) - (IFNULL(faelle_gestern, 0) + IFNULL(faelle_neu, 0)) AS fehler_faelle, IFNULL(tote_gesamt, 0) - (IFNULL(tote_gestern, 0)+IFNULL(tote_neu, 0)) AS fehler_tote, IFNULL(genesen_gesamt, 0) - (IFNULL(genesen_gestern, 0)+IFNULL(genesen_neu, 0)) AS fehler_genesen FROM 
(SELECT datenstand, altersgruppe, SUM(anzahlfall) AS faelle_gesamt FROM covid19 WHERE datenstand = d AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY ALTERSGRUPPE) m1
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahlfall) AS faelle_neu FROM covid19 WHERE datenstand = d AND (NeuerFall = 1 OR NeuerFall = -1) GROUP BY Altersgruppe) m2 ON m1.altersgruppe = m2.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_gesamt FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY Altersgruppe) m3 ON m1.altersgruppe = m3.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) GROUP BY Altersgruppe) m4 ON m1.altersgruppe = m4.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu_30 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -30), '%Y/%m/%d') GROUP BY Altersgruppe) m10 ON m1.altersgruppe = m10.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu_40 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -40), '%Y/%m/%d') GROUP BY Altersgruppe) m11 ON m1.altersgruppe = m11.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu_50 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -50), '%Y/%m/%d') GROUP BY Altersgruppe) m12 ON m1.altersgruppe = m12.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu_60 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -60), '%Y/%m/%d') GROUP BY Altersgruppe) m13 ON m1.altersgruppe = m13.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu_70 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -70), '%Y/%m/%d') GROUP BY Altersgruppe) m14 ON m1.altersgruppe = m14.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahlgenesen) AS genesen_gesamt FROM covid19 WHERE datenstand = d AND (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY Altersgruppe) m5 ON m1.altersgruppe = m5.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahlgenesen) AS genesen_neu FROM covid19 WHERE datenstand = d AND (NeuGenesen = 1 OR NeuGenesen = -1) GROUP BY Altersgruppe) m6 ON m1.altersgruppe = m6.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahlfall) AS faelle_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY altersgruppe ) m7 ON m1.altersgruppe = m7.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') and (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY altersgruppe ) m8 ON m1.altersgruppe = m8.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahlgenesen) AS genesen_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') and (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY altersgruppe ) m9 ON m1.altersgruppe = m9.altersgruppe;


INSERT INTO covid19_simple_stat_altersgruppe ( datenstand, altersgruppe, faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, tote_neu_30, tote_neu_40, tote_neu_50, tote_neu_60, tote_neu_70,genesen_gesamt, genesen_neu, rate_gesamt, rate_neu, faelle_fehler, tote_fehler, genesen_fehler)
SELECT m1.datenstand, m1.altersgruppe2, m1.faelle_gesamt, IFNULL(faelle_neu, 0), tote_gesamt, IFNULL(tote_neu, 0), IFNULL(tote_neu_30, 0), IFNULL(tote_neu_40, 0), IFNULL(tote_neu_50, 0), IFNULL(tote_neu_60, 0), IFNULL(tote_neu_70, 0), genesen_gesamt, IFNULL(genesen_neu, 0), tote_gesamt / faelle_gesamt AS rate_gesamt, tote_neu / faelle_neu AS rate_neu, IFNULL(faelle_gesamt, 0) - (IFNULL(faelle_gestern, 0) + IFNULL(faelle_neu, 0)) AS fehler_faelle, IFNULL(tote_gesamt, 0) - (IFNULL(tote_gestern, 0)+IFNULL(tote_neu, 0)) AS fehler_tote, IFNULL(genesen_gesamt, 0) - (IFNULL(genesen_gestern, 0)+IFNULL(genesen_neu, 0)) AS fehler_genesen FROM 
(SELECT datenstand, altersgruppe2, SUM(anzahlfall) AS faelle_gesamt FROM covid19 WHERE datenstand = d AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY altersgruppe2) m1
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahlfall) AS faelle_neu FROM covid19 WHERE datenstand = d AND (NeuerFall = 1 OR NeuerFall = -1) GROUP BY altersgruppe2) m2 ON m1.altersgruppe2 = m2.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_gesamt FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY altersgruppe2) m3 ON m1.altersgruppe2 = m3.altersgruppe2
LEFT JOIN 
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) GROUP BY altersgruppe2) m4 ON m1.altersgruppe2 = m4.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu_30 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -30), '%Y/%m/%d') GROUP BY altersgruppe2) m10 ON m1.altersgruppe2 = m10.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu_40 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -40), '%Y/%m/%d') GROUP BY altersgruppe2) m11 ON m1.altersgruppe2 = m11.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu_50 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -50), '%Y/%m/%d') GROUP BY altersgruppe2) m12 ON m1.altersgruppe2 = m12.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu_60 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -60), '%Y/%m/%d') GROUP BY altersgruppe2) m13 ON m1.altersgruppe2 = m13.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_neu_70 FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) and meldedatum < date_format(ADDDATE(d, -70), '%Y/%m/%d') GROUP BY altersgruppe2) m14 ON m1.altersgruppe2 = m14.altersgruppe2
LEFT JOIN
(SELECT datenstand, altersgruppe2, SUM(anzahlgenesen) AS genesen_gesamt FROM covid19 WHERE datenstand = d AND (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY altersgruppe2) m5 ON m1.altersgruppe2 = m5.altersgruppe2
LEFT JOIN 
(SELECT datenstand, altersgruppe2, SUM(anzahlgenesen) AS genesen_neu FROM covid19 WHERE datenstand = d AND (NeuGenesen = 1 OR NeuGenesen = -1) GROUP BY altersgruppe2) m6 ON m1.altersgruppe2 = m6.altersgruppe2
LEFT JOIN 
(SELECT datenstand, altersgruppe2, SUM(anzahlfall) AS faelle_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY altersgruppe2 ) m7 ON m1.altersgruppe2 = m7.altersgruppe2
LEFT JOIN 
(SELECT datenstand, altersgruppe2, SUM(anzahltodesfall) AS tote_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') and (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY altersgruppe2 ) m8 ON m1.altersgruppe2 = m8.altersgruppe2
LEFT JOIN 
(SELECT datenstand, altersgruppe2, SUM(anzahlgenesen) AS genesen_gestern FROM covid19 WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') and (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY altersgruppe2 ) m9 ON m1.altersgruppe2 = m9.altersgruppe2 WHERE m1.altersgruppe2 != "A00-A04" AND m1.altersgruppe2 != "A80+" AND m1.altersgruppe2 != "unbekannt" AND m1.altersgruppe2 != "Nicht übermittelt";


END//
DELIMITER ;