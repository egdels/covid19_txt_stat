-- Exportiere Struktur von Prozedur rki.CreateSimpleRKIStatBundesland
DELIMITER //
CREATE PROCEDURE `CreateSimpleRKIStatBundesland`(
	IN `d` VARCHAR(10)
)
BEGIN
	declare f_gesamt int;
	declare f_neu int;
	declare t_gesamt int;
	declare t_neu int;
	declare g_gesamt int;
	declare g_neu int;
	declare fallzahl int;
	declare totezahl int;
	declare eiwn int;
    declare n INT;
   
	-- ggfs alte statistic loeschen
	delete from covid19_simple_stat_bundesland where datenstand = d;
	
	-- einzelne bundeslaender --
	INSERT INTO covid19_simple_stat_bundesland ( datenstand, idbundesland, faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, genesen_gesamt, genesen_neu, rate_gesamt, rate_neu, faelle_fehler, tote_fehler, genesen_fehler)
	SELECT m1.datenstand, m1.idbundesland, m1.faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, genesen_gesamt, genesen_neu, tote_gesamt / faelle_gesamt AS rate, tote_neu / faelle_neu AS rate_neu, faelle_gesamt - (faelle_gestern + faelle_neu) AS fehler_faelle, tote_gesamt - (tote_gestern+tote_neu) AS fehler_tote, genesen_gesamt - (genesen_gestern+genesen_neu) AS fehler_genesen FROM 
	(SELECT datenstand, idbundesland, SUM(anzahlfall) AS faelle_gesamt FROM covid19 WHERE datenstand = d AND (NeuerFall = 0 OR NeuerFall =1) GROUP BY idbundesland) m1
	LEFT JOIN
	(SELECT datenstand, idbundesland, SUM(anzahlfall) AS faelle_neu FROM covid19 WHERE datenstand = d AND (NeuerFall = 1 OR NeuerFall = -1) GROUP BY idbundesland) m2 ON m1.idbundesland = m2.idbundesland
	LEFT JOIN
	(SELECT datenstand, idbundesland, SUM(anzahltodesfall) AS tote_gesamt FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 0 OR NEuerTodesFall =1) GROUP BY idbundesland) m3 ON m1.idbundesland = m3.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, SUM(anzahltodesfall) AS tote_neu FROM covid19 WHERE datenstand = d AND (NeuerTodesFall = 1 OR NEuerTodesFall = -1) GROUP BY idbundesland) m4 ON m1.idbundesland = m4.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, SUM(anzahlgenesen) AS genesen_gesamt FROM covid19 WHERE datenstand = d AND (NeuGenesen = 0 OR NeuGenesen = 1) GROUP BY idbundesland) m5 ON m1.idbundesland = m5.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, SUM(anzahlgenesen) AS genesen_neu FROM covid19 WHERE datenstand = d AND (NeuGenesen = 1 OR NeuGenesen = -1) GROUP BY idbundesland) m6 ON m1.idbundesland = m6.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, faelle_gesamt AS faelle_gestern FROM covid19_simple_stat_bundesland WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY idbundesland ) m7 ON m1.idbundesland = m7.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, tote_gesamt AS tote_gestern FROM covid19_simple_stat_bundesland WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY idbundesland ) m8 ON m1.idbundesland = m8.idbundesland
	LEFT JOIN 
	(SELECT datenstand, idbundesland, genesen_gesamt AS genesen_gestern FROM covid19_simple_stat_bundesland WHERE datenstand = date_format(ADDDATE(d, -1), '%Y/%m/%d') GROUP BY idbundesland ) m9 ON m1.idbundesland = m9.idbundesland;

	-- bund --
	INSERT INTO covid19_simple_stat_bundesland ( datenstand, idbundesland, faelle_gesamt, faelle_neu, tote_gesamt, tote_neu, genesen_gesamt, genesen_neu, rate_gesamt, rate_neu, faelle_fehler, tote_fehler, genesen_fehler)
	SELECT datenstand, 0, sum(faelle_gesamt), sum(faelle_neu), sum(tote_gesamt), sum(tote_neu), sum(genesen_gesamt), sum(genesen_neu), sum(tote_gesamt) / sum(faelle_gesamt) AS rate, sum(tote_neu) / sum(faelle_neu) AS rate_neu, SUM(faelle_fehler), SUM(tote_fehler), SUM(genesen_fehler) FROM covid19_simple_stat_bundesland WHERE datenstand = d AND idbundesland > 0;

	-- inzidenzen --	
	set n=0;
    
	-- Einwohner --
	select einwohner into @eiwn from bundesland where idbundesland = n;
     
	-- Inzidenz --
	select sum(faelle) into @fallzahl from (select meldedatum, sum(AnzahlFall) as faelle from covid19 where  datenstand = d and (NeuerFall=1 or NeuerFall= 0) group by meldedatum having meldedatum >= DATE_FORMAT(ADDDATE(d, -7), '%Y/%m/%d')) m;
    
    -- Tote Inzidenz --
	select sum(faelle) into @totezahl from (select meldedatum, sum(AnzahlTodesFall) as faelle from covid19 where  datenstand = d and (NeuerTodesFall=1 or NeuerTodesFall= 0) group by meldedatum having meldedatum >= DATE_FORMAT(ADDDATE(d, -30), '%Y/%m/%d')) m;
    
	update covid19_simple_stat_bundesland SET fallzahl = @fallzahl, incidence =  @fallzahl / (@eiwn / 100000), totezahl = @totezahl, tote_incidence =  @totezahl / (@eiwn / 1000000) WHERE datenstand = d AND idbundesland = 0;

	label1: LOOP
		SET n = n + 1;
		
		-- Einwohner
        select einwohner into @eiwn from bundesland where idbundesland = n;
    
		-- Inzidenz
		select sum(faelle) into @fallzahl from (select meldedatum, sum(AnzahlFall) as faelle from covid19 where  datenstand = d and idbundesland = n and (NeuerFall=1 or NeuerFall= 0) group by meldedatum having meldedatum >= DATE_FORMAT(ADDDATE(d, -7), '%Y/%m/%d')) m;
    
		-- Tote Inzidenz
		select sum(faelle) into @totezahl from (select meldedatum, sum(AnzahlTodesFall) as faelle from covid19 where  datenstand = d and idbundesland = n and (NeuerTodesFall=1 or NeuerTodesFall= 0) group by meldedatum having meldedatum >= DATE_FORMAT(ADDDATE(d, -30), '%Y/%m/%d')) m;
    
    	update covid19_simple_stat_bundesland SET fallzahl = @fallzahl, incidence =  @fallzahl / (@eiwn / 100000), totezahl = @totezahl, tote_incidence =  @totezahl / (@eiwn / 1000000) WHERE datenstand = d AND idbundesland = n;

        IF n < 16 THEN
			ITERATE label1;
		END IF;
		LEAVE label1;
	END LOOP label1;
   
END//
DELIMITER ;