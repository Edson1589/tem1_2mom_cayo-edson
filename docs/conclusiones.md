# Conclusiones generales

1. Cargué **9.994 filas, 5.009 pedidos y 793 clientes**, con ventas de **2.297.200,86**, ganancias de **286.397,02** y un margen total aproximado de **12,47%**. No encontré valores vacíos, filas duplicadas ni fechas incorrectas.
2. **West** presenta el mejor desempeño por ganancia acumulada; **Central**, el menor. La comparación demuestra que vender más no garantiza un margen mayor.
3. Con RFM identifiqué **104 clientes de alto valor** y **318 que llevan más tiempo sin comprar**. Esto permite distinguir a quiénes conviene mantener y a quiénes se podría volver a contactar.
4. Las **856 filas con descuento superior al 50% tuvieron pérdidas**. Binders, Tables y Machines necesitan una revisión de sus descuentos. Los datos muestran esta relación, aunque no permiten asegurar que el descuento sea la única causa.
5. Los meses con más ventas se concentran hacia el final del año. Comparar con el mes anterior, con el mismo mes del año anterior y con el promedio de tres meses ayuda a entender mejor los cambios.
6. **414 productos** concentran el 80% de ventas y **164** el 80% de la ganancia neta. El negocio depende de un conjunto reducido de productos rentables.

El uso de Parquet permitió guardar los datos en menos espacio y dejarlos preparados para las consultas. Las capturas, los resultados guardados y los controles finales muestran el trabajo realizado en Hive. En general, la práctica me permitió comprobar que las ventas deben revisarse junto con las ganancias para entender cómo está funcionando el negocio.
