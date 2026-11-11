-- Pregunta 7: meses calendario, comparacion mensual e interanual.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

CREATE OR REPLACE VIEW tendencias_mensuales AS
-- shortcut: media movil sobre meses consecutivos del CSV, completar calendario si hay meses ausentes.
WITH mensual AS (
  SELECT DATE_SUB(order_date,DAYOFMONTH(order_date)-1) AS mes,
    SUM(sales) AS ventas, SUM(profit) AS ganancia
  FROM ventas GROUP BY DATE_SUB(order_date,DAYOFMONTH(order_date)-1)
), ventanas AS (
  SELECT *, LAG(mes) OVER (ORDER BY mes) AS mes_anterior,
    LAG(ventas) OVER (ORDER BY mes) AS ventas_anterior,
    LAG(ganancia) OVER (ORDER BY mes) AS ganancia_anterior,
    AVG(ventas) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media3_ventas,
    AVG(ganancia) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media3_ganancia,
    COUNT(*) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS meses_media,
    ROW_NUMBER() OVER (ORDER BY ventas DESC, mes) AS top_ventas,
    ROW_NUMBER() OVER (ORDER BY ventas, mes) AS bottom_ventas
  FROM mensual
)
SELECT a.mes, a.ventas, a.ganancia,
  CASE WHEN a.mes_anterior=ADD_MONTHS(a.mes,-1)
    THEN 100.0*(a.ventas-a.ventas_anterior)/NULLIF(a.ventas_anterior,0) END AS ventas_mom_pct,
  CASE WHEN a.mes_anterior=ADD_MONTHS(a.mes,-1)
    THEN 100.0*(a.ganancia-a.ganancia_anterior)/NULLIF(ABS(a.ganancia_anterior),0) END AS ganancia_mom_pct,
  b.ventas AS ventas_anio_anterior, b.ganancia AS ganancia_anio_anterior,
  100.0*(a.ventas-b.ventas)/NULLIF(b.ventas,0) AS ventas_yoy_pct,
  100.0*(a.ganancia-b.ganancia)/NULLIF(ABS(b.ganancia),0) AS ganancia_yoy_pct,
  CASE WHEN a.meses_media=3 THEN a.media3_ventas END AS media3_ventas,
  CASE WHEN a.meses_media=3 THEN a.media3_ganancia END AS media3_ganancia,
  a.top_ventas, a.bottom_ventas
FROM ventanas a LEFT JOIN mensual b ON b.mes=ADD_MONTHS(a.mes,-12);

SELECT mes, ROUND(ventas,2) AS ventas, ROUND(ganancia,2) AS ganancia,
  ROUND(ventas_mom_pct,2) AS ventas_mom_pct, ROUND(ganancia_mom_pct,2) AS ganancia_mom_pct,
  ROUND(ventas_anio_anterior,2) AS ventas_anio_anterior,
  ROUND(ganancia_anio_anterior,2) AS ganancia_anio_anterior,
  ROUND(ventas_yoy_pct,2) AS ventas_yoy_pct, ROUND(ganancia_yoy_pct,2) AS ganancia_yoy_pct,
  ROUND(media3_ventas,2) AS media3_ventas, ROUND(media3_ganancia,2) AS media3_ganancia,
  top_ventas, bottom_ventas
FROM tendencias_mensuales ORDER BY mes;
SELECT mes, ROUND(ventas,2) AS ventas, top_ventas, bottom_ventas
FROM tendencias_mensuales WHERE top_ventas<=3 OR bottom_ventas<=3 ORDER BY ventas DESC;
