-- Paso 1: Seleccionar variables y filtrar por Municipio (equivalente a Vars y Bogota en R)
-- Esto se puede hacer en un solo paso o creando una vista/tabla intermedia si lo prefieres.
-- Asumimos que la tabla importada se llama "basecompleta".
-- Nota: En SQL, los nombres de columna con mayúsculas o caracteres especiales deben ir entre comillas dobles.

-- Creamos una tabla temporal o una vista para facilitar el manejo, similar a tu objeto "Bogota"
CREATE TEMP TABLE Bogota_temp AS
SELECT
    "MPIO",
    "COD_LOCALIDAD" AS "Cod_Localidad",
    "NOMBRE_LOCALIDAD" AS "Nombre_Loc",
    "COD_UPZ_GRUPO" AS "Cod_UPZ", 
    "NOMBRE_UPZ_GRUPO" AS "Nombre_UPZ", 
    "NVCBP11AA" AS "Estrato",
    "NVCBP5" AS "IluNoct",
    "NVCBP14F" AS "Drogas",
    "NVCBP15C" AS "Inseguridad",
    "NPCHP4" AS "NivEdu"
FROM
    basecompleta 
WHERE
    "MPIO" = 11001; 

-- Paso 2: Eliminar filas con valores nulos (complete.cases)
DELETE FROM Bogota_temp
WHERE
    "Estrato" IS NULL OR
    "IluNoct" IS NULL OR
    "Drogas" IS NULL OR
    "Inseguridad" IS NULL OR
    "NivEdu" IS NULL;
-- Ten en cuenta que si las columnas ya están definidas como NOT NULL en la tabla, este paso no sería necesario
-- o podrías haber filtrado durante la creación de Bogota_temp.

-- Paso 3: Crear nuevas columnas basadas en condiciones (ifelse)
-- Esto se hace con la sentencia CASE WHEN en SQL.
-- Vamos a crear una nueva tabla o actualizar la existente. Por simplicidad, creemos una nueva tabla derivada.

CREATE TEMP TABLE Bogota_procesada AS
SELECT
    *,
    CASE WHEN "Drogas" = '1' THEN 1 ELSE 0 END AS "SiDrogas",
    CASE WHEN "Inseguridad" = '1' THEN 1 ELSE 0 END AS "SiInseguridad",
    CASE WHEN CAST("Estrato" AS INTEGER) >= 4 THEN 1 ELSE 0 END AS "EstratoAlto",
    CASE WHEN CAST("NivEdu" AS INTEGER) >= 9 THEN 1 ELSE 0 END AS "EduSup"
FROM
    Bogota_temp;

-- Paso 4: Agrupar y resumir para crear los índices (group_by y summarise)
CREATE TABLE resumen_upz AS -- Creamos una tabla persistente para los resultados
SELECT
    "Cod_UPZ",
    "Cod_Localidad",
    "Nombre_Loc", 
    "Nombre_UPZ",
    AVG("SiDrogas") * 100 AS porcentaje_drogas,
    AVG("SiInseguridad") * 100 AS porcentaje_Inseguridad,
    AVG("EstratoAlto") * 100 AS porcentaje_EstratoAlto,
    AVG("EduSup") * 100 AS porcentaje_EduSup
FROM
    Bogota_procesada
GROUP BY
    "Cod_UPZ",
    "Cod_Localidad",
    "Nombre_Loc",
    "Nombre_UPZ";

ALTER TABLE upz_kennedy
ALTER COLUMN "CODIGO_UPZ" TYPE INTEGER
USING "CODIGO_UPZ"::integer;

-- Paso 5: Unir los datos resumidos (resumen_upz) a la capa espacial (upz_kennedy)
-- Esto se hace con un LEFT JOIN. El resultado puede ser una nueva tabla o actualizar la existente.
-- Crearemos una nueva tabla con los datos unidos.

CREATE TABLE upz_kennedy_con_indices AS
SELECT
    u.*, -- Selecciona todas las columnas de la tabla upz_kennedy
    r.porcentaje_drogas,
    r.porcentaje_Inseguridad,
    r.porcentaje_EstratoAlto,
    r.porcentaje_EduSup,
    r."Cod_Localidad" AS cod_loc, 
    r."Nombre_Loc" AS Nom_loc     
FROM
    upz_kennedy u 
LEFT JOIN
    resumen_upz r ON u."CODIGO_UPZ" = r."Cod_UPZ"; -- La condición de unión