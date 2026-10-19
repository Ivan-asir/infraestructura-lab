# Consultas SQL y comprobación de roles y permisos

## Contexto

Base de datos `tienda`, con los siguientes datos principales:

- 24 clientes.
- 100 productos.
- 200 pedidos.
- 200 líneas de pedido.
- 20 clientes con pedidos y 4 sin pedidos.

## Consulta 1: facturación por cliente

Obtener el identificador, nombre y facturación total de cada
cliente que tenga pedidos, ordenados por facturación descendente.

Criterio de aceptación: 20 filas, una por cliente con pedidos.

## Consulta 2: clientes sin pedidos

Mostrar el identificador y nombre de los clientes sin pedidos.

Criterio de aceptación: 4 filas.

## Consulta 3: facturación mensual

Agrupar la facturación por mes natural, incluyendo el año,
y ordenar cronológicamente.

Criterio de aceptación: 12 meses con la carga original.

## Consulta 4: facturación por cliente con y sin CTE

Calcular la facturación total de los clientes con pedidos utilizando una CTE
y una consulta directa con JOIN, ordenando por facturación descendente.

Criterio: veinte filas y los mismos importes en ambas consultas.

## Comprobación de roles y permisos

Validar que:

1) tienda_readonly puede consultar las tablas.
2) tienda_readonly no puede modificar productos.
3) tienda_readwrite puede insertar registros.
4) La inserción de prueba se revierte con ROLLBACK.

Los roles son NOLOGIN y se prueban con SET ROLE.

## Evidencias

- sql/exercises.sql: consultas resueltas.
- 02-sql-roles/roles.sql: permisos configurados.
- 02-sql-roles/validation.txt: resultados reales.

No se publican credenciales ni datos privados.
