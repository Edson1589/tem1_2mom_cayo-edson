SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;
ANALYZE TABLE ventas COMPUTE STATISTICS;
EXPLAIN SELECT region, SUM(sales) AS ventas FROM ventas
WHERE order_date>='2017-01-01' AND order_date<'2018-01-01' GROUP BY region;
EXPLAIN SELECT region, SUM(sales) AS ventas FROM ventas_tipadas
WHERE order_date>='2017-01-01' AND order_date<'2018-01-01' GROUP BY region;
