-- Exportiere Struktur von Tabelle rki.bundesland
CREATE TABLE IF NOT EXISTS `bundesland` (
  `idbundesland` int(11) NOT NULL,
  `namebundesland` varchar(45) DEFAULT NULL,
  `einwohner` int(11) DEFAULT NULL,
  PRIMARY KEY (`idbundesland`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exportiere Daten aus Tabelle rki.bundesland: ~17 rows (ungefähr)
INSERT INTO `bundesland` (`idbundesland`, `namebundesland`, `einwohner`) VALUES
	(0, 'Bund', 83703925),
	(1, 'Schleswig-Holstein', 2903773),
	(2, 'Hamburg', 1899160),
	(3, 'Niedersachsen', 7993608),
	(4, 'Bremen', 567559),
	(5, 'Nordrhein-Westfalen', 17947221),
	(6, 'Hessen', 6288080),
	(7, 'Rheinland-Pfalz', 4093903),
	(8, 'Baden-Württemberg', 11100394),
	(9, 'Bayern', 13124737),
	(10, 'Saarland', 986887),
	(11, 'Berlin', 3669491),
	(12, 'Brandenburg', 2521893),
	(13, 'Mecklenburg-Vorpommern', 1608138),
	(14, 'Sachsen', 4071971),
	(15, 'Sachsen-Anhalt', 2194782),
	(16, 'Thüringen', 2133378);
