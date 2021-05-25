-- Exportiere Struktur von Prozedur rki.CreateFehlerRKIStat
DELIMITER //
CREATE PROCEDURE `CreateFehlerRKIStat`(
	IN `d` VARCHAR(10)
)
BEGIN
	-- heute
	declare f_gesamt_h int; 
	declare f_neu_h int; 
   declare t_gesamt_h int; 
   declare t_neu_h int;
   declare g_gesamt_h int; 
   declare g_neu_h int;
    
	-- gestern
   declare f_gesamt_g int; 
   declare t_gesamt_g int;
   declare g_gesamt_g int;
	
	DECLARE n INT;

	SET n = -1;
    
   label1: LOOP
		SET n = n + 1;
	-- heute
	select faelle_gesamt into @f_gesamt_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
   select faelle_neu into @f_neu_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
   select tote_gesamt into @t_gesamt_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
   select tote_neu into @t_neu_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
   select genesen_gesamt into @g_gesamt_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
   select genesen_neu into @g_neu_h from covid19_simple_stat_bundesland where datenstand = d AND idbundesland = n;
    
    -- gestern
   select faelle_gesamt into @f_gesamt_g from covid19_simple_stat_bundesland where datenstand = date_format(adddate(d, -1), '%Y/%m/%d') AND idbundesland = n;
   select tote_gesamt into @t_gesamt_g from covid19_simple_stat_bundesland where datenstand = date_format(adddate(d, -1), '%Y/%m/%d') AND idbundesland = n;
   select genesen_gesamt into @g_gesamt_g from covid19_simple_stat_bundesland where datenstand = date_format(adddate(d, -1), '%Y/%m/%d') AND idbundesland = n;
    
	update covid19_simple_stat_bundesland set faelle_fehler = @f_gesamt_h - (@f_gesamt_g + @f_neu_h) where datenstand = d AND idbundesland = n;
   update covid19_simple_stat_bundesland set tote_fehler = @t_gesamt_h - (@t_gesamt_g + @t_neu_h) where datenstand = d AND idbundesland = n;
   update covid19_simple_stat_bundesland set genesen_fehler = @g_gesamt_h - (@g_gesamt_g + @g_neu_h) where datenstand = d AND idbundesland = n;
		
		
      IF n < 16 THEN
			ITERATE label1;
		END IF;
		LEAVE label1;
	END LOOP label1; 
    
    
    
    
END//
DELIMITER ;