# Evidencias de ejecución

Estas capturas muestran la ejecución de la práctica en Docker y Hue. Cada imagen aparece también en el apartado que le corresponde del [desarrollo de las preguntas](../docs/preguntas_01_08.md), el [README principal](../README.md) o el [análisis de optimización](../docs/optimizacion.md).

| Captura | Contenido |
|---|---|
| [00_Servicios.png](00_Servicios.png) | Servicios del proyecto en ejecución. |
| [01_Modelo.png](01_Modelo.png) | Columnas y tipos de datos de la tabla de ventas. |
| [01_Carga.png](01_Carga.png) | Las dos tablas con 9.994 registros. |
| [02_Calidad.png](02_Calidad.png) | Resumen de pedidos, clientes y posibles errores. |
| [02_Nulos.png](02_Nulos.png) | Revisión de valores vacíos en los 21 campos. |
| [03_Regiones.png](03_Regiones.png) | Ventas, ganancias y posición de cada región en todo el período. |
| [03_Regiones_01.png](03_Regiones_01.png) | Ventas y ganancias por región y año, con sus cambios porcentuales. |
| [04_rmf.png](04_rmf.png) | Ejemplos de clientes con sus valores RFM y clasificación. |
| [05_Productos.png](05_Productos.png) | Márgenes y posiciones de los productos de Furniture. |
| [05_Productos_01.png](05_Productos_01.png) | Parte de la selección de productos con mayores ganancias y menores márgenes. |
| [06_Descuentos.png](06_Descuentos.png) | Resultados de los cuatro grupos de descuentos. |
| [06_Subcategorias.png](06_Subcategorias.png) | Grupos de productos ordenados por ganancia. |
| [07_Tendencias.png](07_Tendencias.png) | Resultados mensuales y comparaciones con períodos anteriores. |
| [07_Extremos.png](07_Extremos.png) | Los tres meses con más ventas y los tres con menos ventas. |
| [08_Pareto.png](08_Pareto.png) | Cantidad de productos que alcanza el 80% de ventas y ganancias. |
| [opt_planes.png](opt_planes.png) | Plan de la consulta que lee los datos del CSV. |

Los [resultados completos](../resultados/) incluyen las tablas que no aparecen enteras en las imágenes. Los [registros de ejecución](logs/) guardan las consultas y sus mensajes. También se incluyen el [estado de los servicios](logs/servicios.txt), los [tamaños de los archivos](logs/almacenamiento.txt) y el [resultado de los controles finales](../resultados/validacion.tsv).
