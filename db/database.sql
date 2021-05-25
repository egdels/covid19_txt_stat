CREATE DATABASE rki;

CREATE USER 'rki'@'localhost' IDENTIFIED BY 'rki';

GRANT ALL PRIVILEGES ON rki. * TO 'rki'@'localhost';

FLUSH PRIVILEGES;