-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 07 Gru 2020, 10:40
-- Wersja serwera: 10.4.16-MariaDB
-- Wersja PHP: 7.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `jrozliczajaca`
--
CREATE DATABASE IF NOT EXISTS `jrozliczajaca` DEFAULT CHARACTER SET utf8 COLLATE utf8_polish_ci;
USE `jrozliczajaca`;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `banki`
--

DROP TABLE IF EXISTS `banki`;
CREATE TABLE IF NOT EXISTS `banki` (
  `id_banku` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) DEFAULT NULL,
  `adres` varchar(255) DEFAULT NULL,
  `kontakt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_banku`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `banki`
--

INSERT INTO `banki` (`id_banku`, `nazwa`, `adres`, `kontakt`) VALUES
(2, 'N/A', 'N/A', 'N/A');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `operacje`
--

DROP TABLE IF EXISTS `operacje`;
CREATE TABLE IF NOT EXISTS `operacje` (
  `id_operacji` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_operacji`),
  UNIQUE KEY `id_operacji` (`id_operacji`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `operacje`
--

INSERT INTO `operacje` (`id_operacji`, `nazwa`) VALUES
(1, 'Uznanie'),
(2, 'Obciążenie');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rachunki`
--

DROP TABLE IF EXISTS `rachunki`;
CREATE TABLE IF NOT EXISTS `rachunki` (
  `id_rachunku` int(11) NOT NULL AUTO_INCREMENT,
  `id_banku` int(11) DEFAULT NULL,
  `nr_rachunku` varchar(255) DEFAULT NULL,
  `saldo` decimal(9,2) DEFAULT NULL,
  PRIMARY KEY (`id_rachunku`),
  UNIQUE KEY `id_banku` (`id_banku`),
  UNIQUE KEY `nr_rachunku` (`nr_rachunku`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `rachunki`
--

INSERT INTO `rachunki` (`id_rachunku`, `id_banku`, `nr_rachunku`, `saldo`) VALUES
(2, 2, '111111110000000000000000', '0.00');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `statusy`
--

DROP TABLE IF EXISTS `statusy`;
CREATE TABLE IF NOT EXISTS `statusy` (
  `id_statusu` int(11) NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_statusu`),
  UNIQUE KEY `id_statusu` (`id_statusu`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `statusy`
--

INSERT INTO `statusy` (`id_statusu`, `nazwa`) VALUES
(1, 'Zaksięgowano'),
(2, 'Wykonano');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `transakcje`
--

DROP TABLE IF EXISTS `transakcje`;
CREATE TABLE IF NOT EXISTS `transakcje` (
  `id_transakcji` int(11) NOT NULL AUTO_INCREMENT,
  `numer_transakcji` varchar(255) DEFAULT NULL,
  `typ_operacji` int(11) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `bank_nadawcy` varchar(255) DEFAULT NULL,
  `rachunek_nadawcy` varchar(255) NOT NULL,
  `nazwa_nadawcy` varchar(255) DEFAULT NULL,
  `adres_nadawcy` varchar(255) DEFAULT NULL,
  `bank_odbiorcy` varchar(255) DEFAULT NULL,
  `rachunek_odbiorcy` varchar(255) NOT NULL,
  `nazwa_odbiorcy` varchar(255) DEFAULT NULL,
  `adres_odbiorcy` varchar(255) DEFAULT NULL,
  `kwota` decimal(9,2) DEFAULT NULL,
  `tytul` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_transakcji`),
  KEY `typ_operacji` (`typ_operacji`),
  KEY `status` (`status`),
  KEY `rachunek_nadawcy` (`bank_nadawcy`),
  KEY `rachunek_odbiorcy` (`bank_odbiorcy`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `transakcje`
--

INSERT INTO `transakcje` (`id_transakcji`, `numer_transakcji`, `typ_operacji`, `data`, `status`, `bank_nadawcy`, `rachunek_nadawcy`, `nazwa_nadawcy`, `adres_nadawcy`, `bank_odbiorcy`, `rachunek_odbiorcy`, `nazwa_odbiorcy`, `adres_odbiorcy`, `kwota`, `tytul`) VALUES
(13, '0712204552', 1, '2020-12-03', 2, '111111110000000000000000', '10111111110000000098765432', 'Zdzisiek', '26-41 Październik', '111111110000000000000000', '10111111110000000098767777', 'Grzewsiu', '11-445 China', '250.00', 'Przelew1');

--
-- Wyzwalacze `transakcje`
--
DROP TRIGGER IF EXISTS `saldo`;
DELIMITER $$
CREATE TRIGGER `saldo` AFTER INSERT ON `transakcje` FOR EACH ROW BEGIN
	UPDATE rachunki SET rachunki.saldo=rachunki.saldo+new.kwota WHERE rachunki.nr_rachunku=new.bank_odbiorcy;
END
$$
DELIMITER ;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `rachunki`
--
ALTER TABLE `rachunki`
  ADD CONSTRAINT `rachunki_ibfk_1` FOREIGN KEY (`id_banku`) REFERENCES `banki` (`id_banku`);

--
-- Ograniczenia dla tabeli `transakcje`
--
ALTER TABLE `transakcje`
  ADD CONSTRAINT `transakcje_ibfk_1` FOREIGN KEY (`typ_operacji`) REFERENCES `operacje` (`id_operacji`),
  ADD CONSTRAINT `transakcje_ibfk_2` FOREIGN KEY (`status`) REFERENCES `statusy` (`id_statusu`),
  ADD CONSTRAINT `transakcje_ibfk_3` FOREIGN KEY (`bank_nadawcy`) REFERENCES `rachunki` (`nr_rachunku`),
  ADD CONSTRAINT `transakcje_ibfk_4` FOREIGN KEY (`bank_odbiorcy`) REFERENCES `rachunki` (`nr_rachunku`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
