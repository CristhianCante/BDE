SELECT
    u."NOMBRE" AS nombre_upz,
    COUNT(e.id) AS numero_estaciones,
    u.porcentaje_inseguridad
FROM
    upz_kennedy_con_indices u
LEFT JOIN
    kenn_estransr e ON ST_Contains(u.geom, e.geom)
WHERE
    u."NOMBRE" = (
        SELECT
            "NOMBRE"
        FROM
            upz_kennedy_con_indices
        WHERE
            porcentaje_inseguridad IS NOT NULL
        ORDER BY
            porcentaje_inseguridad DESC
        LIMIT 1
    )
AND u.porcentaje_inseguridad IS NOT NULL
GROUP BY
    u."NOMBRE", u.porcentaje_inseguridad;