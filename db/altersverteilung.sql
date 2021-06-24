-- Exportiere Struktur von Tabelle rki.altersverteilung
CREATE TABLE IF NOT EXISTS `altersverteilung` (
  `gruppe` varchar(50) DEFAULT NULL,
  `anteil` decimal(7,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exportiere Daten aus Tabelle rki.altersverteilung: ~22 rows (ungefähr)
INSERT INTO `altersverteilung` (`gruppe`, `anteil`) VALUES
	('A05-A09', 0.045500),
	('A10-A14', 0.044797),
	('A15-A19', 0.046381),
	('A20-A24', 0.054963),
	('A25-A29', 0.059082),
	('A30-A34', 0.067117),
	('A35-A39', 0.063627),
	('A40-A44', 0.060548),
	('A45-A49', 0.060560),
	('A50-A54', 0.078014),
	('A55-A59', 0.081983),
	('A60-A64', 0.069967),
	('A65-A69', 0.058915),
	('A70-A74', 0.047719),
	('A75-A79', 0.041706),
	('A00-A04', 0.047732),
	('A05-A14', 0.090297),
	('A15-A34', 0.227542),
	('A35-A59', 0.344732),
	('A60-A79', 0.218307),
	('A80+', 0.071390),
	('unbekannt', 0.000000);
