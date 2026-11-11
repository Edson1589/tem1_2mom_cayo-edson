# Diccionario de datos

**Autor:** Edson Marcelo Cayo Ali.

El CSV tiene 9.994 filas y 21 columnas separadas por comas. Los textos que contienen comas están entre comillas dobles. Las fechas originales tienen el formato `M/d/yyyy` y los números usan punto decimal. Para la carga se creó una copia UTF-8 sin la fila de títulos. En `ventas_raw` todos los campos se leen como texto y en `ventas` se usan los tipos indicados abajo.

| Campo original → Hive | Tipo en Hive | Descripción y regla de revisión |
|---|---|---|
| Row ID → row_id | INT | Identificador de línea, positivo, único y no nulo. |
| Order ID → order_id | STRING | Orden comercial; se repite cuando contiene varios productos. |
| Order Date → order_date | DATE | Fecha válida del pedido. |
| Ship Date → ship_date | DATE | Fecha válida de envío, igual o posterior al pedido. |
| Ship Mode → ship_mode | STRING | First Class, Second Class, Standard Class o Same Day. |
| Customer ID → customer_id | STRING | Identificador del cliente, no nulo. |
| Customer Name → customer_name | STRING | Nombre descriptivo del cliente; no se usa como clave. |
| Segment → segment | STRING | Consumer, Corporate o Home Office. |
| Country → country | STRING | País; United States en este archivo. |
| City → city | STRING | Ciudad de la operación. |
| State → state | STRING | Estado de la operación. |
| Postal Code → postal_code | STRING | Código postal; texto para conservar posibles ceros iniciales. |
| Region → region | STRING | Central, East, South o West. |
| Product ID → product_id | STRING | Identificador del producto; puede repetirse entre operaciones. |
| Category → category | STRING | Furniture, Office Supplies o Technology. |
| Sub-Category → sub_category | STRING | Subcategoría comercial. |
| Product Name → product_name | STRING | Descripción; puede contener comas y variar para un mismo ID. |
| Sales → sales | DECIMAL(18,4) | Importe de venta de la línea, esperado >0. No se multiplica por Quantity. |
| Quantity → quantity | INT | Unidades vendidas, esperado >0. |
| Discount → discount | DECIMAL(5,4) | Proporción entre 0 y 1; 0.2 equivale a 20%. |
| Profit → profit | DECIMAL(18,4) | Ganancia de la línea; los negativos representan pérdidas válidas. |

Estas reglas se comprueban en la pregunta 2; Hive no las aplica automáticamente. Los campos vacíos se guardan como NULL y no se eliminan filas durante la carga. Los productos se agrupan por su ID y categoría. Cuando un ID tiene varios nombres, `MIN(product_name)` elige uno para mostrarlo sin separar las ventas del mismo producto.
