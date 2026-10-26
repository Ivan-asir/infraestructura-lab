# Consultas SQL y comprobación de roles y permisos

## Contexto

Base de datos `tienda`, con los siguientes datos principales:

- 24 clientes.
- 100 productos.
- 200 pedidos.
- 200 líneas de pedido.
- 20 clientes con pedidos y 4 sin pedidos.

## Consulta 1: clasificación de clientes por importe total de pedidos

Obtener el identificador, nombre y facturación total de cada cliente que tenga pedidos,
ordenando por facturación descendente y, en caso de empate, por identificador de cliente ascendente.

Criterio de aceptación: 20 filas, una por cliente con pedidos.

## Consulta 2: identificación de clientes sin pedidos

Mostrar el identificador y nombre de los clientes sin pedidos.

Criterio de aceptación: 4 filas.

## Consulta 3: análisis de la facturación mensual

Agrupar la facturación por mes natural, incluyendo el año,
y ordenar cronológicamente.

Criterio de aceptación: 12 meses con la carga original.

## Consulta 4: comparación de estrategias de agregación (CTE frente a cálculo directo)

Calcular la facturación total de los clientes con pedidos utilizando una CTE y una consulta
directa con JOIN, ordenando por facturación descendente y, en caso de empate, por identificador
de cliente ascendente.

Criterio: veinte filas y los mismos importes en ambas consultas.

## Comprobación de roles y permisos

Validar que:

1) tienda_readonly puede consultar las tablas.
2) tienda_readonly no puede modificar productos.
3) tienda_readwrite puede insertar registros.
4) La inserción de prueba se revierte con ROLLBACK.

Los roles son NOLOGIN y se prueban con SET ROLE.

## Evidencias

- postgresql/sql/exercises.sql: consultas resueltas.
- postgresql/02-sql-roles/roles.sql: permisos configurados.
- postgresql/02-sql-roles/validation.txt: resultados reales.

No se publican credenciales ni datos privados.
