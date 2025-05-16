SELECT
    u."NOMBRE" AS nombre_upz,
    COUNT(e.id) AS numero_estaciones,
    u.porcentaje_inseguridad
FROM
    upz_kennedy_con_indices u
JOIN
    kenn_estransr e ON ST_Contains(u.geom, e.geom)
	WHERE
    u.porcentaje_inseguridad IS NOT NULL
GROUP BY
    u."NOMBRE", u.porcentaje_inseguridad
ORDER BY
    numero_estaciones DESC
LIMIT 1;