-- Pregunta 3: evolucion anual y desempeno global por ganancia acumulada.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

WITH anual AS (
  SELECT region, YEAR(order_date) AS anio, SUM(sales) AS ventas, SUM(profit) AS ganancia
  FROM ventas GROUP BY region, YEAR(order_date)
), anterior AS (
  SELECT *, LAG(ventas) OVER (PARTITION BY region ORDER BY anio) AS ventas_anterior,
    LAG(ganancia) OVER (PARTITION BY region ORDER BY anio) AS ganancia_anterior
  FROM anual
)
SELECT region, anio, ROUND(ventas,2) AS ventas, ROUND(ganancia,2) AS ganancia,
  ROUND(100.0*ganancia/NULLIF(ventas,0),2) AS margen_pct,
  ROUND(100.0*(ventas-ventas_anterior)/NULLIF(ventas_anterior,0),2) AS variacion_ventas_pct,
  ROUND(100.0*(ganancia-ganancia_anterior)/NULLIF(ABS(ganancia_anterior),0),2) AS variacion_ganancia_pct
FROM anterior ORDER BY region, anio;

WITH region_total AS (
  SELECT region, SUM(sales) AS ventas, SUM(profit) AS ganancia
  FROM ventas GROUP BY region
)
SELECT region, ROUND(ventas,2) AS ventas, ROUND(ganancia,2) AS ganancia,
  ROUND(100.0*ganancia/NULLIF(ventas,0),2) AS margen_pct,
  RANK() OVER (ORDER BY ganancia DESC) AS posicion
FROM region_total ORDER BY posicion;
