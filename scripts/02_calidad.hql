-- Pregunta 2: resumen de calidad y nulos en los 21 campos.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
SET hive.vectorized.execution.enabled=false;
USE superstore_edson;

WITH duplicados AS (
  SELECT row_id, COUNT(*) AS n FROM ventas
  WHERE row_id IS NOT NULL GROUP BY row_id HAVING COUNT(*) > 1
), resumen_duplicados AS (
  SELECT COUNT(*) AS ids_duplicados, COALESCE(SUM(n-1),0) AS filas_excedentes
  FROM duplicados
), resumen AS (
  SELECT COUNT(*) AS registros, COUNT(DISTINCT order_id) AS ordenes_unicas,
    COUNT(DISTINCT customer_id) AS clientes_unicos,
    SUM(CASE WHEN order_date IS NULL OR ship_date IS NULL THEN 1 ELSE 0 END) AS fechas_nulas_o_invalidas,
    SUM(CASE WHEN ship_date < order_date THEN 1 ELSE 0 END) AS envios_anteriores,
    SUM(CASE WHEN sales <= 0 THEN 1 ELSE 0 END) AS ventas_no_positivas,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END) AS descuentos_fuera_rango,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS cantidades_no_positivas
  FROM ventas
)
SELECT r.*, d.ids_duplicados, d.filas_excedentes
FROM resumen r CROSS JOIN resumen_duplicados d;

WITH campos AS (
  SELECT STACK(21,
    'row_id', CAST(row_id AS STRING), 'order_id', order_id,
    'order_date', CAST(order_date AS STRING), 'ship_date', CAST(ship_date AS STRING),
    'ship_mode', ship_mode, 'customer_id', customer_id, 'customer_name', customer_name,
    'segment', segment, 'country', country, 'city', city, 'state', state,
    'postal_code', postal_code, 'region', region, 'product_id', product_id,
    'category', category, 'sub_category', sub_category, 'product_name', product_name,
    'sales', CAST(sales AS STRING), 'quantity', CAST(quantity AS STRING),
    'discount', CAST(discount AS STRING), 'profit', CAST(profit AS STRING)
  ) AS (campo, valor) FROM ventas
)
SELECT campo, SUM(CASE WHEN valor IS NULL THEN 1 ELSE 0 END) AS nulos
FROM campos GROUP BY campo ORDER BY campo;

SELECT
  SUM(CASE WHEN NULLIF(TRIM(order_date),'') IS NOT NULL
    AND CAST(order_date AS DATE FORMAT 'MM/DD/YYYY') IS NULL THEN 1 ELSE 0 END) AS pedidos_invalidos,
  SUM(CASE WHEN NULLIF(TRIM(ship_date),'') IS NOT NULL
    AND CAST(ship_date AS DATE FORMAT 'MM/DD/YYYY') IS NULL THEN 1 ELSE 0 END) AS envios_invalidos
FROM ventas_raw;

-- El nombre no es clave: un mismo ID puede tener distintas descripciones.
SELECT COUNT(*) AS productos_con_varios_nombres FROM (
  SELECT product_id FROM ventas GROUP BY product_id
  HAVING COUNT(DISTINCT product_name) > 1
) p;
