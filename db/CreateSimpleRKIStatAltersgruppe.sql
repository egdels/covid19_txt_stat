-- Exportiere Struktur von Prozedur rki.CreateSimpleRKIStatAltersgruppe
DELIMITER //
CREATE PROCEDURE `CreateSimpleRKIStatAltersgruppe`(
	IN `d` VARCHAR(10)
)
BEGIN

 -- ggfs alte statistic loeschen
delete from covid19_simple_stat_altersgruppe where datenstand = d;

INSERT INTO covid19_simple_stat_altersgruppe ( datenstand, altersgruppe, faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, genesen_gesamt, genesen_neu, rate_gesamt, rate_neu, faelle_fehler, tote_fehler, genesen_fehler)
SELECT m1.datenstand, m1.altersgruppe, m1.faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, genesen_gesamt, genesen_neu, tote_gesamt / faelle_gesamt AS rate_gesamt, tote_neu / faelle_neu AS rate_neu, faelle_gesamt - (faelle_gestern + faelle_neu) AS fehler_faelle, tote_gesamt - (tote_gestern+tote_neu) AS fehler_tote, genesen_gesamt - (genesen_gestern+genesen_neu) AS fehler_genesen FROM 
(SELECT datenstand, altersgruppe, SUM(anzahlfall) AS faelle_gesamt FROM covid19 WHERE datenstand = d AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY ALTERSGRUPPE) m1
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahlfall) AS faelle_neu FROM covid19 WHERE datenstand = d AND (NeuerFall = 1 OR NeuerFall = -1) GROUP BY Altersgruppe) m2 ON m1.altersgruppe = m2.altersgruppe
LEFT JOIN
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_gesamt FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY Altersgruppe) m3 ON m1.altersgruppe = m3.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahltodesfall) AS tote_neu FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) GROUP BY Altersgruppe) m4 ON m1.altersgruppe = m4.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahlgenesen) AS genesen_gesamt FROM covid19 WHERE datenstand = d AND (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY Altersgruppe) m5 ON m1.altersgruppe = m5.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, SUM(anzahlgenesen) AS genesen_neu FROM covid19 WHERE datenstand = d AND (NeuGenesen = 1 OR NeuGenesen = -1) GROUP BY Altersgruppe) m6 ON m1.altersgruppe = m6.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, faelle_gesamt AS faelle_gestern FROM covid19_simple_stat_altersgruppe WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY altersgruppe ) m7 ON m1.altersgruppe = m7.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, tote_gesamt AS tote_gestern FROM covid19_simple_stat_altersgruppe WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY altersgruppe ) m8 ON m1.altersgruppe = m8.altersgruppe
LEFT JOIN 
(SELECT datenstand, altersgruppe, genesen_gesamt AS genesen_gestern FROM covid19_simple_stat_altersgruppe WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY altersgruppe ) m9 ON m1.altersgruppe = m9.altersgruppe;

END//
DELIMITER ;