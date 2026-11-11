-- Pregunta 6: perdida = profit<0; no rentable = profit<=0.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

CREATE OR REPLACE VIEW ventas_descuentos AS
SELECT *, CASE WHEN discount=0 THEN '0 Sin descuento'
  WHEN discount>0 AND discount<=0.2 THEN '1 Bajo (0,20%]'
  WHEN discount>0.2 AND discount<=0.5 THEN '2 Medio (20%,50%]'
  WHEN discount>0.5 AND discount<=1 THEN '3 Alto (50%,100%]'
  ELSE '4 Invalido' END AS rango
FROM ventas;

SELECT rango, COUNT(*) AS registros, ROUND(SUM(sales),2) AS ventas,
  ROUND(SUM(profit),2) AS ganancia,
  ROUND(100.0*SUM(profit)/NULLIF(SUM(sales),0),2) AS margen_pct,
  SUM(CASE WHEN profit<0 THEN 1 ELSE 0 END) AS registros_perdida,
  SUM(CASE WHEN profit<=0 THEN 1 ELSE 0 END) AS registros_no_rentables,
  ROUND(100.0*SUM(CASE WHEN profit<=0 THEN 1 ELSE 0 END)/COUNT(*),2) AS no_rentables_pct,
  ROUND(100.0*AVG(discount),2) AS descuento_promedio_pct
FROM ventas_descuentos GROUP BY rango ORDER BY rango;

-- Desglose por rango, categoria y subcategoria; permite localizar el efecto.
SELECT rango, category, sub_category, COUNT(*) AS registros,
  ROUND(SUM(sales),2) AS ventas, ROUND(SUM(profit),2) AS ganancia,
  ROUND(100.0*SUM(profit)/NULLIF(SUM(sales),0),2) AS margen_pct,
  SUM(CASE WHEN profit<0 THEN 1 ELSE 0 END) AS registros_perdida,
  ROUND(100.0*SUM(CASE WHEN profit<=0 THEN 1 ELSE 0 END)/COUNT(*),2) AS no_rentables_pct,
  ROUND(100.0*AVG(discount),2) AS descuento_promedio_pct
FROM ventas_descuentos GROUP BY rango, category, sub_category
ORDER BY ganancia, rango, category, sub_category;

SELECT category, ROUND(SUM(profit),2) AS ganancia,
  ROUND(100.0*SUM(profit)/NULLIF(SUM(sales),0),2) AS margen_pct
FROM ventas GROUP BY category ORDER BY ganancia;
