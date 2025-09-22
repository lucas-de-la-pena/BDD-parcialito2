/* 1. Encontrar el nombre, ataque y defensa de todos los pokémon cuyo poder de todos
sus movimientos de categoría 'Physical' sea mayor a 85. */
SELECT 
    pokename AS NOMBRE, 
    attack AS ATAQUE, 
    defense AS DEFENSA 
FROM 
    pokemon
WHERE 
    idpoke IN (
        SELECT 
            A.idpoke
        FROM 
            pokemon P, 
            (
                SELECT 
                    P.idpoke, 
                    COUNT(*) AS CANTIDAD
                FROM 
                    pokemon P
                    INNER JOIN pokemoves PM ON P.idpoke = PM.idpoke
                    INNER JOIN moves M ON PM.idmove = M.idmove 
                    INNER JOIN categories C ON M.idcat = C.idcat
                WHERE 
                    C.category = 'Physical'
                    AND M.power > 85
                GROUP BY 
                    P.idpoke
            ) A --Consulto la cantidad de los que cumplen condicion de poder
            JOIN 
            (
                SELECT 
                    P.idpoke, 
                    COUNT(*) AS CANTIDAD
                FROM 
                    pokemon P
                    INNER JOIN pokemoves PM ON P.idpoke = PM.idpoke
                    INNER JOIN moves M ON PM.idmove = M.idmove 
                    INNER JOIN categories C ON M.idcat = C.idcat
                WHERE 
                    C.category = 'Physical'
                GROUP BY 
                    P.idpoke
            ) B --Consulto sin verificar condicion de poder
            ON A.idpoke = B.idpoke
        WHERE 
            A.CANTIDAD = B.CANTIDAD --Me aseguro que TODOS sus poderes cumplan la condicion
    )
ORDER BY 
    pokename;
	

-- RESULTADO --

    -- nombre    | ataque | defensa 
-- --------------+--------+---------
 -- Diglett      |     55 |      25
 -- Dugtrio      |    100 |      50
 -- Graveler     |     95 |     115
 -- Machamp      |    130 |      80
 -- Muk          |    105 |      75
 -- Nidoking     |    102 |      77
 -- Nidoqueen    |     92 |      87
 -- Sandshrew    |     75 |      85
 -- Sandslash    |    100 |     110
-- (9 rows)


-- 2. Encontrar todos los Pokemon tienen movimientos de tipo 'Normal' y 'Flying',
-- pero que no tienen ninguna del tipo 'Fire'.

--Relaciono cada pokemon con su movimiento y el tipo de mov
 WITH PokemonesMovTipo AS ( SELECT P.idpoke, M.movename, T.typename
							FROM pokemon P 
							JOIN poketype PK ON P.idpoke = PK.idpoke
							JOIN type T ON PK.idtype = T.idtype
							JOIN pokemoves PM ON P.idpoke = PM.idpoke
							JOIN moves M ON PM.idmove = M.idmove
							WHERE T.idtype = M.idtype
							) 
	
SELECT *
FROM pokemon
WHERE idpoke IN ( SELECT idpoke
				  FROM PokemonesMovTipo
				  WHERE typename = 'Normal') --Que tienen tipo normal
	AND idpoke IN (	SELECT idpoke
					FROM PokemonesMovTipo
					WHERE typename = 'Flying') --Que tienen tipo flying
	AND idpoke NOT IN (	SELECT idpoke
					    FROM PokemonesMovTipo
					    WHERE typename = 'Fire'); --Pero que no tienen tipo Fire
				   
/*  
 idpoke |   pokename   | hp | attack | defense | spattack | spdefense | speed | dualtype 
--------+--------------+----+--------+---------+----------+-----------+-------+----------
     16 | Pidgey       | 40 |     45 |      40 |       35 |        35 |    56 | t
     17 | Pidgeotto    | 63 |     60 |      55 |       50 |        50 |    71 | t
     18 | Pidgeot      | 83 |     80 |      75 |       70 |        70 |   101 | t
(3 rows)
 */



-- 3. Encontrar los 5 tipos de Pokemon con el mayor promedio de “ataque especial”
-- (spattack). Devolver el nombre del tipo y su promedio. En caso de empates,
-- resolverlo utilizando el nombre del tipo.
SELECT T.typename as TIPO, ROUND(AVG(P.spattack),1) as "Promedio de SPATTACK" 
FROM pokemon P
	JOIN poketype PT ON P.idpoke = PT.idpoke
	JOIN type T ON T.idtype = PT.idtype
GROUP BY T.idtype
ORDER BY AVG(P.spattack) DESC LIMIT 5;

/*
     tipo     | Promedio de SPATTACK 
--------------+----------------------
 Dragon       |                125.0
 Dark         |                125.0
 Ghost        |                115.0
 Steel        |                103.3
 Electric     |                 96.0
(5 rows) */

-- 4. Obtener el ID, nombre y la velocidad del Pokemon, para aquellos que tengan una
-- suma de “poder” (power) de todos sus movimientos mayor a 250 y un promedio de
-- “precisión” (accuracy) de al menos 95.

SELECT idpoke as ID, pokename as NOMBRE, speed as VELOCIDAD 
FROM pokemon 
WHERE idpoke IN (	SELECT P.idpoke
					FROM pokemon P
						JOIN pokemoves PT ON P.idpoke = PT.idpoke
						JOIN moves M ON M.idmove = PT.idmove
					GROUP BY P.idpoke
						HAVING SUM(M.power) > 250 AND AVG(M.accuracy) > 95);
						
/*  
 id  |    nombre    | velocidad 
-----+--------------+-----------
   6 | Charizard    |       100
   8 | Wartortle    |        58
   9 | Blastoise    |        78
  17 | Pidgeotto    |        71
  18 | Pidgeot      |       101
  25 | Pikachu      |        90
 145 | Zapdos       |       100
 146 | Moltres      |        90
(8 rows) */


-- 5. Se necesita saber qué Pokemon/s tiene/n la estadística de 'defensa' (defense) más
-- baja, sólo considerando los Pokémon de tipo 'Ground'. Devolver el nombre del
-- Pokémon y su defensa.
WITH PokemonesGround AS (SELECT * 
						FROM pokemon P
							JOIN poketype PT ON P.idpoke = PT.idpoke
							JOIN type T ON PT.idtype = T.idtype
						WHERE T.typename = 'Ground')
					
SELECT * 
FROM PokemonesGround
WHERE defense = (	SELECT MIN(defense)
					FROM PokemonesGround);

/* 
 idpoke |   pokename   | hp | attack | defense | spattack | spdefense | speed | dualtype | idpoke | idtype | idtype |   typename   
--------+--------------+----+--------+---------+----------+-----------+-------+----------+--------+--------+--------+--------------
     50 | Diglett      | 10 |     55 |      25 |       35 |        45 |    95 | f        |     50 |      5 |      5 | Ground      
(1 row) */


-- 6. Encontrar aquellos Pokemons que conocen movimientos de todas las categorías
-- (categories) posibles.