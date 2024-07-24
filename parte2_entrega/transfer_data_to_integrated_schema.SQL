-- COMANDOS PARA INSERIR OS DADOS DA BASE CHINESA NA BAESE DE DADOS INTEGRADA


-- Inserindo Altetas

INSERT INTO participacao_olimpica.atletas (
  nome_completo,
  sexo,
  idade,
  altura,
  unidade_altura,
  peso,
  medalha_de_ouro,
  medalha_de_prata,
  medalha_de_bronze
)
SELECT
  c.nome AS nome_completo,
  c.sexo,
  c.idade,
  CAST(c.altura AS CHAR) AS altura,
  'cm' AS unidade_altura,
  c.peso,
  (SELECT COUNT(*) FROM CHINA_olympic_participation.participacoes as m WHERE m.id_atleta = c.id_atleta AND m.medalha = 'Gold') AS medalha_de_ouro,
  (SELECT COUNT(*) FROM CHINA_olympic_participation.participacoes as m WHERE m.id_atleta = c.id_atleta AND m.medalha = 'Silver') AS medalha_de_prata,
  (SELECT COUNT(*) FROM CHINA_olympic_participation.participacoes as m WHERE m.id_atleta = c.id_atleta AND m.medalha = 'Bronze') AS medalha_de_bronze
FROM
  CHINA_olympic_participation.china_atletas c;

 
 -- Inerindo Olimpiadas
 
 
INSERT INTO participacao_olimpica.olimpiadas (
  edicao,
  pais,
  cidade,
  ano,
  temporada
)
SELECT
  ( SELECT edition FROM olympic_participation.Olympics as op WHERE op.year = o.ano and op.season = o.temporada ) as edicao,
  ( SELECT country FROM olympic_participation.Olympics as op WHERE op.year = o.ano and op.season = o.temporada ) AS pais,
  o.cidade,
  o.ano,
  o.temporada 
FROM
  CHINA_olympic_participation.olimpiadas o;
 

 -- Inserindo Esporte
 
 INSERT INTO participacao_olimpica.esporte (
 	esporte 
 )
 SELECT DISTINCT 
 	esporte 
 FROM CHINA_olympic_participation.eventos ;
 
  -- Inserindo Modalidade

 INSERT INTO participacao_olimpica.modalidade (
 	modalidade 
 )
 SELECT DISTINCT 
 	evento as modalidade 
 FROM CHINA_olympic_participation.eventos;


  -- Inserindo Modalidade_Esporte

 INSERT INTO participacao_olimpica.modalidade_esporte (
 	id_modalidade,
 	id_esporte 
 )
 SELECT DISTINCT 
 	(SELECT id_modalidade from participacao_olimpica.modalidade p1  where p1.modalidade  = e.evento) as id_modalidade,
 	(SELECT id_esporte from participacao_olimpica.esporte p2  where p2.esporte  = e.esporte) as id_esporte
 FROM CHINA_olympic_participation.eventos e;

-- Inserindo Participacoes 

-- Os ids do atletas mantiveram-se os mesmos
-- Os ids das olimpiadas mantiveram-se os mesmos
-- Os ids de modalidade_esporte mantiveram-se na mesma ordem dos registros da tabela de eventos da antiga base

INSERT INTO participacao_olimpica.participacoes (
	id_atleta,
	id_olimpiada,
	id_modalidade_esporte,
	medalha 
)
SELECT 
	p.id_atleta,
	p.id_olimpiada,
	(  
		select id_modalidade_esporte FROM participacao_olimpica.modalidade_esporte 
		NATURAL JOIN esporte 
		NATURAL JOIN modalidade 
		WHERE
		modalidade.modalidade = (SELECT DISTINCT evento FROM CHINA_olympic_participation.eventos as e WHERE  e.id_evento = p.id_evento)
		AND 
		esporte.esporte = (SELECT DISTINCT esporte FROM CHINA_olympic_participation.eventos as e WHERE  e.id_evento = p.id_evento)
	) as id_modalidade_esporte,
	p.medalha 
FROM CHINA_olympic_participation.participacoes p;


-- ---------------------------------------------------------------------------------------------------------------------------------------------


-- COMANDOS PARA INSERIR OS DADOS DA BASE AMERICANA NA BAESE DE DADOS INTEGRADA


-- Inserindo Atletas


 ALTER TABLE participacao_olimpica.atletas AUTO_INCREMENT = 2363;
 

INSERT INTO participacao_olimpica.atletas (
  nome_completo,
  idade,
  altura,
  unidade_altura,
  medalha_de_ouro,
  medalha_de_prata,
  medalha_de_bronze,
  data_nascimento,
  data_morte,
  local_nascimento
)
SELECT
  CONCAT(a.first_name, ' ', a.last_name) AS nome_completo,
  a.age as idade,
  a.height as altura,
  'inches' AS unidade_altura,
  a.gold_medals AS medalha_de_ouro,
  a.silver_medals AS medalha_de_prata,
  a.bronze_medals AS medalha_de_bronze,
  a.birthday as data_nascimento,
  a.deceased_date as data_morte,
  a.hometown as local_nascimento
FROM
  olympic_participation.Athlete a;
 

-- Inserindo Olimpiadas
 
 
 ALTER TABLE participacao_olimpica.olimpiadas AUTO_INCREMENT = 21;
 
 INSERT INTO participacao_olimpica.olimpiadas (
  edicao,
  pais,
  cidade,
  ano,
  temporada
)
SELECT
 edition, 
 country ,
 city ,
 `year` ,
 season 
FROM
olympic_participation.Olympics o 
WHERE  (o.`year`, o.season ) not in (
	SELECT o1.ano, o1.temporada
	FROM participacao_olimpica.olimpiadas AS o1
)



-- Inserindo Esportes

 ALTER TABLE participacao_olimpica.esporte AUTO_INCREMENT = 47;

 INSERT INTO participacao_olimpica.esporte (
  esporte 
)
SELECT
	s.name as esporte
FROM
olympic_participation.Sport s 
WHERE  (s.name) not in (
	SELECT o1.esporte
	FROM participacao_olimpica.esporte AS o1
)

  -- Inserindo Modalidade_Esporte

 ALTER TABLE participacao_olimpica.modalidade_esporte AUTO_INCREMENT = 399;

 INSERT INTO participacao_olimpica.modalidade_esporte (
 	id_esporte
 )
 SELECT 
 	(SELECT id_esporte from participacao_olimpica.esporte p  where p.esporte  = o.name) as id_esporte
 FROM olympic_participation.Sport o; 

-- Inserindo Participacoes 

-- Os ids podem ser acessados adicionando um endereco base no calculo


 ALTER TABLE participacao_olimpica.participacoes AUTO_INCREMENT = 4910;

INSERT INTO participacao_olimpica.participacoes (
	id_atleta,
	id_olimpiada,
	id_modalidade_esporte 
)
SELECT 
	(p.athlete_id  + 2362) as id_atleta,
	( SELECT o2.id_olimpiada FROM participacao_olimpica.olimpiadas as o2
	WHERE (o2.temporada, o2.ano) = ( 
	SELECT season, `year` from olympic_participation.Participation
	join olympic_participation.Olympics on olympic_participation.Participation.olympics_id = olympic_participation.Olympics.id
	where olympic_participation.Participation.id = p.id  )
	) as id_olimpiada,
	(  
		select id_modalidade_esporte FROM participacao_olimpica.modalidade_esporte 
		NATURAL JOIN esporte
		NATURAL left JOIN modalidade 
		WHERE
		esporte.esporte = (
		SELECT s.name FROM  olympic_participation.Participation as p2
		JOIN olympic_participation.Athlete as a on p2.athlete_id = a.id
		JOIN olympic_participation.Sport as s on a.sport_id = s.id
		where p2.id = p.id 
		)
		and modalidade is NULL
	) as id_modalidade_esporte
FROM olympic_participation.Participation p;

-- ---------------------------------------------------------------------------------------------------------------------------------------------