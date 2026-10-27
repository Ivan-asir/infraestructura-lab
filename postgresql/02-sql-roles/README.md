# SQL, roles y permisos

## 1. Objetivo y alcance

Trabajar DDL, carga de datos, consultas SQL y permisos mínimos sobre la base `tienda`.

## 2. Entorno y requisitos

- `pg-primary`, Rocky Linux 9.8, PostgreSQL 18.6.
- Base `tienda`, esquema `public`, datos sintéticos y roles `NOLOGIN`.
- Archivos SQL comunes en `../sql/`; administrar la instancia únicamente con permisos autorizados.

## 3. Estructura de archivos

- `../sql/schema.sql`: tablas, claves y restricciones.
- `../sql/seed.sql`: carga reproducible de datos.
- `../sql/exercises.md`: enunciados y criterios.
- `../sql/exercises.sql`: soluciones SQL.
- `roles.sql`: definición de roles y permisos.

## 4. Preparación

En `pg-primary`, comprobar que `tienda` y sus cuatro tablas están presentes antes de aplicar el esquema, cargar datos o modificar permisos. Los SQL de inicialización no son idempotentes; consultar la evidencia antes de repetir pruebas.

## 5. Procedimiento de ejecución

### Roles

#### `tienda_readonly`

Puede conectarse a `tienda`, usar el esquema `public` y leer las tablas
existentes. No tiene permisos de modificación.

#### `tienda_readwrite`

Puede conectarse a `tienda`, usar el esquema `public`, leer y modificar las
tablas existentes y usar las secuencias necesarias para inserciones.

### Enunciados y análisis

Las consultas y criterios de aceptación están documentados
en `../sql/exercises.md`.

#### Clasificación de clientes por importe total de pedidos

Se relacionan clientes, pedidos y pedido_items mediante JOIN.

La agrupación se realiza por cliente para evitar obtener una
fila por cada pedido.

#### Identificación de clientes sin pedidos

Se utiliza NOT EXISTS para identificar clientes
que no aparecen en la tabla pedidos.

#### Análisis de la facturación mensual

Se utilizan EXTRACT(MONTH FROM p.fecha) y EXTRACT(YEAR FROM p.fecha)
para agrupar la facturación por año y mes.

#### Comparación de estrategias de agregación (CTE frente a cálculo directo)

Se utiliza una consulta directa con JOIN y una CTE.

#### Seguridad y permisos

- tienda_readonly: SELECT permitido y UPDATE denegado.
- tienda_readwrite: operaciones DML permitidas.
- Las inserciones de prueba se revierten con ROLLBACK.

Las pruebas se realizan con SET ROLE desde una sesión
administrativa. Los roles NOLOGIN no permiten iniciar
sesión directamente.

Los privilegios definidos se aplican a los objetos existentes.
Los objetos futuros pueden requerir nuevos GRANT o
ALTER DEFAULT PRIVILEGES.

## 6. Comprobaciones y criterios de aceptación

Los criterios siguientes se contrastaron con los resultados registrados en `validation.txt`.

El archivo `validation.txt` recoge:

1) Recuentos de las cuatro tablas.
2) Clientes sin pedidos.
3) Existencia de ambos roles.
4) Privilegios sobre los objetos.
5) Lectura permitida a tienda_readonly.
6) Modificación denegada a tienda_readonly.
7) Inserción permitida a tienda_readwrite.
8) ROLLBACK y comprobación posterior del recuento.

Criterio de cierre: todas las comprobaciones coinciden
con los resultados reales del laboratorio.

## 7. Incidencias y limitaciones

La ejecución de `seed.sql` y `schema.sql` no es idempotente sobre una base existente; comprobar primero sus objetos y datos.

## 8. Reversión y recuperación

Las pruebas DML deben cerrarse con `ROLLBACK`; no eliminar roles ni objetos sin comprobar dependencias.

## 9. Seguridad

Los roles son `NOLOGIN`; por tanto no contienen contraseñas.
No se versionan credenciales ni datos reales.

## 10. Estado y evidencias

- **Estado:** VALIDADO; cuatro recuentos, permisos por rol y `ROLLBACK` sin cambios persistentes.
- **Evidencia:** `validation.txt` y `../sql/exercises.md`.