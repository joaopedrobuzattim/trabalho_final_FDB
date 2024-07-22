-- COMANDO PARA A CRIACAO DA BASE DE DADOS INTEGRADA

drop database if exists `participacao_olimpica` ;
create database `participacao_olimpica`;
use `participacao_olimpica`;



CREATE TABLE `atletas` (
  `id_atleta` int unsigned PRIMARY KEY  AUTO_INCREMENT,
  `nome_completo` varchar(255) NOT NULL,
  `sexo` char(1) ,
  `idade` tinyint unsigned NOT NULL,
  `altura` varchar(50),
  `unidade_altura` varchar(50),
  `peso` int,
  `data_nascimento` DATETIME,
  `data_morte` DATETIME, 
  `local_nascimento` VARCHAR(255),
  `educação` VARCHAR(255), 
  `medalha_de_ouro` INT NOT NULL,
  `medalha_de_prata` INT NOT NULL,
  `medalha_de_bronze` INT NOT NULL
)

CREATE TABLE `olimpiadas` (
    `id_olimpiada` INT PRIMARY KEY AUTO_INCREMENT,
    `edição` VARCHAR(255) NOT NULL,
    `país` VARCHAR(255) NOT NULL,
    `cidade` VARCHAR(255) NOT NULL,
    `ano` INT NOT NULL,
    `temporada` VARCHAR(255) NOT NULL
);

CREATE TABLE `modalidade` (
  `id_modalidade` int PRIMARY KEY AUTO_INCREMENT,
  `modalidade` varchar(150) NOT NULL
);

CREATE TABLE `esporte` (
  `id_esporte` int PRIMARY KEY AUTO_INCREMENT,
  `esporte` varchar(50) NOT NULL
);

CREATE table `modalidade_esporte` (
	`id_modalidade_esporte` int PRIMARY KEY AUTO_INCREMENT,
	`id_modalidade` int ,
	`id_esporte` int NOT NULL,
	FOREIGN KEY (`id_esporte`) REFERENCES `esporte` (`id_esporte`),
    FOREIGN KEY (`id_modalidade`) REFERENCES `modalidade` (`id_modalidade`)
)


CREATE TABLE `participacoes` (
 `id_participacao` int PRIMARY KEY AUTO_INCREMENT,
  `id_atleta` int unsigned NOT NULL,
  `id_olimpiada` int NOT NULL,
  `id_modalidade_esporte` int NOT NULL, 
  `medalha` varchar(50) DEFAULT NULL,
   FOREIGN KEY (`id_atleta`) REFERENCES `atletas` (`id_atleta`),
   FOREIGN KEY (`id_olimpiada`) REFERENCES `olimpiadas` (`id_olimpiada`),
   FOREIGN KEY (`id_modalidade_esporte`) REFERENCES `modalidade_esporte` (`id_modalidade_esporte`)
);


-- ---------------------------------------------------------------------------------------------------------------------------------------------