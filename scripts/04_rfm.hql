-- Pregunta 4: quintiles, con 5 como mejor puntuacion.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
USE superstore_edson;

CREATE OR REPLACE VIEW clientes_rfm AS
WITH referencia AS (SELECT MAX(order_date) AS fecha FROM ventas),
metricas AS (
  SELECT customer_id, MIN(customer_name) AS customer_name,
    DATEDIFF(r.fecha,MAX(order_date)) AS recency,
    COUNT(DISTINCT order_id) AS frequency, SUM(sales) AS monetary
  FROM ventas CROSS JOIN referencia r
  GROUP BY customer_id, r.fecha
), puntuaciones AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency DESC, customer_id) AS r,
    NTILE(5) OVER (ORDER BY frequency, customer_id) AS f,
    NTILE(5) OVER (ORDER BY monetary, customer_id) AS m
  FROM metricas
)
SELECT *, CONCAT(CAST(r AS STRING),CAST(f AS STRING),CAST(m AS STRING)) AS rfm,
  CASE WHEN r>=4 AND f>=4 AND m>=4 THEN 'Alto valor'
       WHEN r<=2 THEN 'En riesgo'
       WHEN f>=4 THEN 'Recurrentes'
       ELSE 'Otros' END AS segmento_rfm
FROM puntuaciones;

SELECT segmento_rfm, COUNT(*) AS clientes,
  ROUND(SUM(monetary),2) AS ventas, ROUND(AVG(recency),2) AS recency_promedio
FROM clientes_rfm GROUP BY segmento_rfm ORDER BY ventas DESC;
SELECT customer_id, customer_name, recency, frequency, ROUND(monetary,2) AS monetary,
  r, f, m, rfm, segmento_rfm
FROM clientes_rfm ORDER BY monetary DESC, customer_id;
