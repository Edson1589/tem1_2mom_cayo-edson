-- Pregunta 8: ventas y ganancias NETAS, con el producto que cruza el 80% incluido.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

CREATE OR REPLACE VIEW pareto_productos AS
WITH aportes AS (
  SELECT 'Ventas' AS metrica, product_id, product_name, ventas AS aporte FROM productos_resumen
  UNION ALL
  SELECT 'Ganancia neta' AS metrica, product_id, product_name, ganancia AS aporte FROM productos_resumen
), acumulados AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY metrica ORDER BY aporte DESC, product_id) AS posicion,
    SUM(aporte) OVER (PARTITION BY metrica) AS total,
    COUNT(*) OVER (PARTITION BY metrica) AS total_productos,
    SUM(aporte) OVER (PARTITION BY metrica ORDER BY aporte DESC, product_id
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS acumulado
  FROM aportes
)
SELECT *, 100.0*aporte/NULLIF(total,0) AS participacion_pct,
  100.0*acumulado/NULLIF(total,0) AS acumulado_pct,
  CASE WHEN total>0 AND acumulado-aporte<0.8*total THEN 1 ELSE 0 END AS dentro_80
FROM acumulados;

SELECT metrica, MAX(total_productos) AS total_productos,
  SUM(dentro_80) AS productos_hasta_80,
  ROUND(100.0*SUM(dentro_80)/MAX(total_productos),2) AS productos_pct,
  ROUND(SUM(CASE WHEN dentro_80=1 THEN aporte ELSE 0 END),2) AS aporte_seleccionado,
  ROUND(MAX(total),2) AS total,
  ROUND(100.0*SUM(CASE WHEN dentro_80=1 THEN aporte ELSE 0 END)/MAX(total),2) AS porcentaje_alcanzado
FROM pareto_productos GROUP BY metrica ORDER BY metrica;

SELECT metrica, posicion, product_id, product_name, ROUND(aporte,2) AS aporte,
  ROUND(participacion_pct,4) AS participacion_pct,
  ROUND(acumulado_pct,4) AS acumulado_pct, dentro_80
FROM pareto_productos ORDER BY metrica, posicion;
