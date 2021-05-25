-- Exportiere Struktur von Prozedur rki.CreateAllSimpleRKIAltersgruppe
DELIMITER //
CREATE PROCEDURE `CreateAllSimpleRKIAltersgruppe`()
BEGIN
  Declare p1 int;
  Declare d varchar(10);
  Declare l int;
  
  set p1=0;

  select count(distinct(datenstand)) into @l from covid19;
  
  label1: LOOP
    SET p1 = p1 + 1;
    select DATE_FORMAT(ADDDATE("2020-03-20", p1), "%Y/%m/%d") into @d; -- fruehere Daten haben NeuerFall oder NeuerTodesFall gleich Null
    call createSimpleRKIStatAltersgruppe(@d);
    IF p1 < @l THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;

END//
DELIMITER ;
