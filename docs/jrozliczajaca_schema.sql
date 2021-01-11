CREATE TABLE `Banki` (
  `id_banku` int PRIMARY KEY AUTO_INCREMENT,
  `nazwa` varchar(255),
  `adres` varchar(255),
  `kontakt` varchar(255)
);

CREATE TABLE `Rachunki` (
  `id_rachunku` int PRIMARY KEY AUTO_INCREMENT,
  `id_banku` int UNIQUE,
  `nr_rachunku` varchar(255) UNIQUE,
  `saldo` decimal(9,2)
);

CREATE TABLE `Statusy` (
  `id_statusu` int UNIQUE PRIMARY KEY AUTO_INCREMENT,
  `nazwa` varchar(255)
);

CREATE TABLE `Operacje` (
  `id_operacji` int UNIQUE PRIMARY KEY AUTO_INCREMENT,
  `nazwa` varchar(255)
);

CREATE TABLE `Transakcje` (
  `id_transakcji` int PRIMARY KEY AUTO_INCREMENT,
  `numer_transakcji` bigint,
  `typ_operacji` int,
  `data` date,
  `status` int,
  `rachunek_nadawcy` varchar(255),
  `nazwa_nadawcy` varchar(255),
  `adres_nadawcy` varchar(255),
  `rachunek_odbiorcy` varchar(255),
  `nazwa_odbiorcy` varchar(255),
  `adres_odbiorcy` varchar(255),
  `kwota` decimal(9,2),
  `tytul` varchar(255)
);

ALTER TABLE `Rachunki` ADD FOREIGN KEY (`id_banku`) REFERENCES `Banki` (`id_banku`);

ALTER TABLE `Transakcje` ADD FOREIGN KEY (`typ_operacji`) REFERENCES `Operacje` (`id_operacji`);

ALTER TABLE `Transakcje` ADD FOREIGN KEY (`status`) REFERENCES `Statusy` (`id_statusu`);

ALTER TABLE `Transakcje` ADD FOREIGN KEY (`rachunek_nadawcy`) REFERENCES `Rachunki` (`nr_rachunku`);

ALTER TABLE `Transakcje` ADD FOREIGN KEY (`rachunek_odbiorcy`) REFERENCES `Rachunki` (`nr_rachunku`);
