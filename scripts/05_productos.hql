-- Pregunta 5: volumen = unidades; menor rentabilidad = menor margen porcentual.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

CREATE OR REPLACE VIEW productos_ranking AS
WITH margen AS (
  SELECT *, 100.0*ganancia/NULLIF(ventas,0) AS margen_pct
  FROM productos_resumen
)
SELECT *,
  RANK() OVER (PARTITION BY category ORDER BY ganancia DESC) AS rank_categoria,
  DENSE_RANK() OVER (ORDER BY unidades DESC) AS rank_volumen,
  RANK() OVER (ORDER BY margen_pct) AS rank_menor_margen,
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY ganancia DESC, product_id) AS fila_categoria,
  ROW_NUMBER() OVER (ORDER BY unidades DESC, product_id) AS fila_volumen,
  ROW_NUMBER() OVER (ORDER BY margen_pct, product_id) AS fila_menor_margen,
  SUM(ganancia) OVER (PARTITION BY category ORDER BY ganancia DESC, product_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ganancia_acumulada_categoria
FROM margen;

WITH seleccion AS (
  SELECT 'Top ganancia por categoria' AS criterio, * FROM productos_ranking WHERE fila_categoria<=5
  UNION ALL
  SELECT 'Top unidades' AS criterio, * FROM productos_ranking WHERE fila_volumen<=5
  UNION ALL
  SELECT 'Menor margen' AS criterio, * FROM productos_ranking WHERE fila_menor_margen<=5
)
SELECT criterio, category, product_id, product_name, ROUND(ventas,2) AS ventas,
  ROUND(ganancia,2) AS ganancia, unidades, ROUND(margen_pct,2) AS margen_pct,
  rank_categoria, rank_volumen, rank_menor_margen,
  ROUND(ganancia_acumulada_categoria,2) AS ganancia_acumulada_categoria
FROM seleccion ORDER BY criterio, category, ganancia DESC, product_id;

-- Margen y posicion de todos los productos, disponibles tambien en la vista.
SELECT product_id, category, ROUND(margen_pct,2) AS margen_pct, rank_categoria
FROM productos_ranking ORDER BY category, rank_categoria, product_id;
