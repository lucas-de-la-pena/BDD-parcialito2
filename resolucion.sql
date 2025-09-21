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
            ) A
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
            ) B 
            ON A.idpoke = B.idpoke
        WHERE 
            A.CANTIDAD = B.CANTIDAD
    )
ORDER BY 
    NOMBRE;


-- 2. Encontrar todos los Pokemon tienen movimientos de tipo 'Normal' y 'Flying',
-- pero que no tienen ninguna del tipo 'Fire'.

-- 3. Encontrar los 5 tipos de Pokemon con el mayor promedio de “ataque especial”
-- (spattack). Devolver el nombre del tipo y su promedio. En caso de empates,
-- resolverlo utilizando el nombre del tipo.


-- 4. Obtener el ID, nombre y la velocidad del Pokemon, para aquellos que tengan una
-- suma de “poder” (power) de todos sus movimientos mayor a 250 y un promedio de
-- “precisión” (accuracy) de al menos 95.


-- 5. Se necesita saber qué Pokemon/s tiene/n la estadística de 'defensa' (defense) más
-- baja, sólo considerando los Pokémon de tipo 'Ground'. Devolver el nombre del
-- Pokémon y su defensa.


-- 6. Encontrar aquellos Pokemons que conocen movimientos de todas las categorías
-- (categories) posibles.