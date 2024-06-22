-- REDUNDÂNCIA 

-- Todos os registros da tabela de modalidades estão contidos na tabela de participacoes, conforme é mostrado nas 
-- consultas a seguir

SELECT count(*)  from CHINA_olympic_participation.modalidades
WHERE (id_evento, id_olimpiada) in (SELECT id_evento, id_olimpiada from CHINA_olympic_participation.participacoes p)

SELECT count(*)  from CHINA_olympic_participation.modalidades;


-- REDUNDÂNCIA 

-- O atributo de "modalidade" da tabela de china_atleta é desnecessário, uma vez que ele já esta contido na tabela eventos, 
-- pelo atributo esporte, que pode ser acessado pela juncao com a tabela de participacoes 

SELECT modalidade from CHINA_olympic_participation.china_atletas ca
where ca.id_atleta = 2;

SELECT e.esporte from CHINA_olympic_participation.china_atletas ca
LEFT JOIN CHINA_olympic_participation.participacoes pa on pa.id_atleta = ca.id_atleta 
LEFT JOIN CHINA_olympic_participation.eventos e on e.id_evento = pa.id_evento 
where ca.id_atleta = 2;


-- Alem disso, o atributo modalidade é irrelevante, pois, conforme mostra a consulta abaixo, um atletaa pode possuir modalidade
-- diferente do esporte que ele participou em jogos. 
SELECT * from CHINA_olympic_participation.china_atletas ca
LEFT JOIN CHINA_olympic_participation.participacoes pa on pa.id_atleta = ca.id_atleta 
LEFT JOIN CHINA_olympic_participation.eventos e on e.id_evento = pa.id_evento 
where (ca.modalidade != e.esporte);




drop database if exists `participation_` ;
create database `participation_`;
use `participation_`;



-- ---------------------------------------------------------------------------

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
  `medalha de ouro` INT NOT NULL,
  `medalha de prata` INT NOT NULL,
  `medalha de bronze` INT NOT NULL
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
  `modalidade` varchar(50) NOT NULL
);

CREATE TABLE `esporte` (
  `id_esporte` int PRIMARY KEY AUTO_INCREMENT,
  `esporte` varchar(50) NOT NULL
);


CREATE TABLE `participacoes` (
 `id_participacao` int PRIMARY KEY AUTO_INCREMENT,
  `id_atleta` int unsigned NOT NULL,
  `id_olimpiada` int NOT NULL,
  `id_esporte` int NOT NULL,
  `id_modalidade` int,
  `medalha` varchar(50) DEFAULT NULL,
   FOREIGN KEY (`id_atleta`) REFERENCES `atletas` (`id_atleta`),
   FOREIGN KEY (`id_olimpiada`) REFERENCES `olimpiadas` (`id_olimpiada`),
   FOREIGN KEY (`id_esporte`) REFERENCES `esporte` (`id_esporte`),
    FOREIGN KEY (`id_modalidade`) REFERENCES `modalidade` (`id_modalidade`)
);
