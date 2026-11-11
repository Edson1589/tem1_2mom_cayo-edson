-- Controles de integridad y reconciliacion; ASSERT_TRUE devuelve NULL si cumple.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

SELECT ASSERT_TRUE(COUNT(*)=793 AND COUNT(DISTINCT customer_id)=793
  AND SUM(monetary)=2297200.8603) AS control_rfm
FROM clientes_rfm;

SELECT ASSERT_TRUE(COUNT(*)=1862 AND SUM(ventas)=2297200.8603
  AND SUM(ganancia)=286397.0217) AS control_productos
FROM productos_resumen;

SELECT ASSERT_TRUE(COUNT(*)=48 AND MIN(mes)='2014-01-01' AND MAX(mes)='2017-12-01'
  AND SUM(ventas)=2297200.8603 AND SUM(ganancia)=286397.0217) AS control_meses
FROM tendencias_mensuales;

SELECT metrica, ASSERT_TRUE(SUM(dentro_80)>0
  AND MAX(CASE WHEN dentro_80=1 THEN acumulado END)>=0.8*MAX(total)
  AND MAX(CASE WHEN dentro_80=1 THEN acumulado-aporte END)<0.8*MAX(total)) AS control_umbral_80
FROM pareto_productos GROUP BY metrica;
