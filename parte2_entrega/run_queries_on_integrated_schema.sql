use `participacao_olimpica`;


-- 1. Consulta para contar o número de atletas de cada sexo (somente para atletas que possuem sexo cadastrado)
SELECT
    sexo, 
    COUNT(*) AS numero_atletas 
FROM 
    atletas
WHERE sexo IS NOT NULL
GROUP BY 
    sexo;

-- 2. Consulta para contar o número de participações por atleta, ordenado do maior para o menor.
SELECT 
    a.nome_completo, 
    COUNT(p.id_participacao) AS numero_participacoes 
FROM 
    atletas a
NATURAL JOIN 
    participacoes as p
GROUP BY 
    a.id_atleta 
ORDER BY 
    numero_participacoes DESC;

   
-- 3. Como na base chinesa, para cada modalidade distinta em que um aleta disputa na mesma olimpiada é contada
-- uma participacao. Vamos remover as participacoes em uma mesma olimpiada e contar somente as participacoes
-- em olimpiadas distintas
SELECT 
    a.nome_completo, 
    COUNT(DISTINCT p.id_olimpiada) AS numero_olimpiadas 
FROM 
    atletas a
NATURAL JOIN 
    participacoes as p
GROUP BY 
    a.nome_completo
ORDER BY 
    numero_olimpiadas DESC;
 
  

-- 5. Consulta para calcular a média de idade dos atletas que disputaram as Olimpíadas de Inverno.
-- (Conta o ano mais de uma vez para atletas que possuem mais de uma participacao na mesma olimpiada)
SELECT 
    AVG(a.idade) AS media_idade_inverno 
FROM 
    atletas a
NATURAL JOIN 
    participacoes as p 
NATURAL JOIN  
    olimpiadas as o 
WHERE 
    o.temporada = 'Winter';
   

-- 6. Consulta para calcular a média de idade dos atletas que disputaram as Olimpíadas de Inverno.
-- (Resolve o probelma anterior utilizando sub query)
SELECT 
    AVG(a.idade) AS media_idade_inverno 
FROM 
    atletas a
WHERE a.id_atleta IN (

SELECT a1.id_atleta FROM atletas a1
NATURAL JOIN participacoes p2
NATURAL JOIN olimpiadas o2
where o2.temporada = 'Winter'

)



-- 7 Consulta para ordenar os estados que ganharam mais medalhas (para os atletas que possuem estado cadastrado)
SELECT 
    RIGHT(a.local_nascimento, 2) AS estado, -- Poderia ser utilizado SUBSTRING_INDEX
    SUM(a.medalha_de_ouro) AS total_ouro,
    SUM(a.medalha_de_prata) AS total_prata,
    SUM(a.medalha_de_bronze) AS total_bronze,
    (SUM(a.medalha_de_ouro) + SUM(a.medalha_de_prata) + SUM(a.medalha_de_bronze)) AS total
FROM 
    atletas a
WHERE a.local_nascimento IS NOT NULL
GROUP BY 
    estado
ORDER BY 
    total DESC;


-- 8 Consulta obter as modalidades que mais tiveram altetas com 28 anos
SELECT 
    m.modalidade,
    COUNT(a.id_atleta) AS quantidade_participantes_de_28_anos
FROM 
    atletas a
NATURAL JOIN 
    participacoes p 
NATURAL JOIN 
    modalidade_esporte me 
NATURAL JOIN 
    modalidade m 
WHERE 
    a.idade = 28
GROUP BY 
    m.id_modalidade 
ORDER BY 
    quantidade_participantes_de_28_anos DESC;
  



