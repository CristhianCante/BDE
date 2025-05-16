SELECT
    b.barriocomu AS nombre_barrio,
    u."NOMBRE" AS nombre_upz,
    u.porcentaje_edusup AS porcentaje_educacion_superior
FROM
    upz_kennedy_con_indices u
JOIN
    kenn_barr b ON ST_Intersects(b.geom, u.geom)
WHERE
    u."NOMBRE" = (
        SELECT
            "NOMBRE"
        FROM
            upz_kennedy_con_indices
        WHERE
            porcentaje_edusup IS NOT NULL
        ORDER BY
            porcentaje_edusup DESC
        LIMIT 1
    );