-- Pregunta 1: carga reproducible; reemplaza solo la tabla de esta practica.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
-- Hive 4.0.1 falla al vectorizar CAST FORMAT sobre este CSV; convertir por fila.
SET hive.vectorized.execution.enabled=false;
USE superstore_edson;
INSERT OVERWRITE TABLE ventas SELECT * FROM ventas_tipadas;

DESCRIBE FORMATTED ventas;
SELECT 'raw' AS capa, COUNT(*) AS registros FROM ventas_raw
UNION ALL
SELECT 'parquet' AS capa, COUNT(*) AS registros FROM ventas;
SELECT MIN(order_date) AS fecha_inicial, MAX(order_date) AS fecha_final,
       SUM(sales) AS ventas, SUM(profit) AS ganancia FROM ventas;
-- Totales de control calculados independientemente desde el CSV original.
SELECT ASSERT_TRUE(COUNT(*)=9994 AND COUNT(DISTINCT row_id)=9994
  AND SUM(sales)=2297200.8603 AND SUM(profit)=286397.0217) AS control_carga
FROM ventas;
SELECT row_id, order_date, product_name, sales, profit
FROM ventas ORDER BY row_id LIMIT 5;
