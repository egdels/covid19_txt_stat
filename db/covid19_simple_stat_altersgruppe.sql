-- Exportiere Struktur von Tabelle rki.covid19_simple_stat_altersgruppe
CREATE TABLE IF NOT EXISTS `covid19_simple_stat_altersgruppe` (
  `datenstand` varchar(10) NOT NULL COMMENT 'Vgl. Covid19.datenstand',
  `altersgruppe` varchar(50) NOT NULL DEFAULT '',
  `faelle_gesamt` int(11) DEFAULT NULL,
  `faelle_neu` int(11) DEFAULT NULL,
  `tote_gesamt` int(11) DEFAULT NULL,
  `tote_neu` int(11) DEFAULT NULL,
  `genesen_gesamt` int(11) DEFAULT NULL,
  `genesen_neu` int(11) DEFAULT NULL,
  `rate_gesamt` decimal(6,5) DEFAULT NULL COMMENT 'faelle_gesamt / tote_gesamt',
  `rate_neu` decimal(6,5) DEFAULT NULL COMMENT 'faell_neu /tote_neu',
  `faelle_fehler` int(11) DEFAULT NULL,
  `tote_fehler` int(11) DEFAULT NULL,
  `genesen_fehler` int(11) DEFAULT NULL,
  PRIMARY KEY (`datenstand`,`altersgruppe`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
