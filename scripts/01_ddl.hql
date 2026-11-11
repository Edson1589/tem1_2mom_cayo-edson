-- Pregunta 1: modelo. Ejecutar antes de 01_dml.hql.
SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
CREATE DATABASE IF NOT EXISTS superstore_edson;
USE superstore_edson;

CREATE EXTERNAL TABLE IF NOT EXISTS ventas_raw (
  row_id STRING, order_id STRING, order_date STRING, ship_date STRING,
  ship_mode STRING, customer_id STRING, customer_name STRING, segment STRING,
  country STRING, city STRING, state STRING, postal_code STRING, region STRING,
  product_id STRING, category STRING, sub_category STRING, product_name STRING,
  sales STRING, quantity STRING, discount STRING, profit STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ('separatorChar'=',', 'quoteChar'='"')
STORED AS TEXTFILE
LOCATION '/user/hive/superstore_edson/raw'
TBLPROPERTIES ('skip.header.line.count'='0');
-- La copia de ingesta ya excluye la cabecera, tambien al repetir una carga previa.
ALTER TABLE ventas_raw SET TBLPROPERTIES ('skip.header.line.count'='0');

-- OpenCSVSerde entrega STRING; las conversiones se hacen antes de escribir Parquet.
CREATE OR REPLACE VIEW ventas_tipadas AS
SELECT
  CAST(NULLIF(TRIM(row_id),'') AS INT) AS row_id,
  NULLIF(TRIM(order_id),'') AS order_id,
  CAST(NULLIF(TRIM(order_date),'') AS DATE FORMAT 'MM/DD/YYYY') AS order_date,
  CAST(NULLIF(TRIM(ship_date),'') AS DATE FORMAT 'MM/DD/YYYY') AS ship_date,
  NULLIF(TRIM(ship_mode),'') AS ship_mode,
  NULLIF(TRIM(customer_id),'') AS customer_id,
  NULLIF(TRIM(customer_name),'') AS customer_name,
  NULLIF(TRIM(segment),'') AS segment,
  NULLIF(TRIM(country),'') AS country,
  NULLIF(TRIM(city),'') AS city,
  NULLIF(TRIM(state),'') AS state,
  NULLIF(TRIM(postal_code),'') AS postal_code,
  NULLIF(TRIM(region),'') AS region,
  NULLIF(TRIM(product_id),'') AS product_id,
  NULLIF(TRIM(category),'') AS category,
  NULLIF(TRIM(sub_category),'') AS sub_category,
  NULLIF(TRIM(product_name),'') AS product_name,
  CAST(NULLIF(TRIM(sales),'') AS DECIMAL(18,4)) AS sales,
  CAST(NULLIF(TRIM(quantity),'') AS INT) AS quantity,
  CAST(NULLIF(TRIM(discount),'') AS DECIMAL(5,4)) AS discount,
  CAST(NULLIF(TRIM(profit),'') AS DECIMAL(18,4)) AS profit
FROM ventas_raw;

CREATE TABLE IF NOT EXISTS ventas (
  row_id INT, order_id STRING, order_date DATE, ship_date DATE,
  ship_mode STRING, customer_id STRING, customer_name STRING, segment STRING,
  country STRING, city STRING, state STRING, postal_code STRING, region STRING,
  product_id STRING, category STRING, sub_category STRING, product_name STRING,
  sales DECIMAL(18,4), quantity INT, discount DECIMAL(5,4), profit DECIMAL(18,4)
)
STORED AS PARQUET
TBLPROPERTIES ('transactional'='false', 'parquet.compression'='SNAPPY');

CREATE OR REPLACE VIEW productos_resumen AS
SELECT product_id, category, MIN(product_name) AS product_name,
       SUM(sales) AS ventas, SUM(profit) AS ganancia, SUM(quantity) AS unidades
FROM ventas
GROUP BY product_id, category;
