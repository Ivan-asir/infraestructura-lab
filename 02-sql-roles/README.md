# SQL, roles y permisos

## Objetivo

Trabajar DDL, carga de datos, consultas SQL y permisos mínimos
sobre la base `tienda`.

## Ficheros SQL

- `../sql/schema.sql`: tablas, claves y restricciones.
- `../sql/seed.sql`: carga reproducible de datos.
- `../sql/exercises.md`: enunciados y criterios.
- `../sql/exercises.sql`: soluciones SQL.
- `roles.sql`: definición de roles y permisos.

## Roles

### `tienda_readonly`

Puede conectarse a `tienda`, usar el esquema `public` y leer las tablas
existentes. No tiene permisos de modificación.

### `tienda_readwrite`

Puede conectarse a `tienda`, usar el esquema `public`, leer y modificar las
tablas existentes y usar las secuencias necesarias para inserciones.

## Seguridad

Los roles son `NOLOGIN`; por tanto no contienen contraseñas.
No se versionan credenciales ni datos reales.

## Enunciados y análisis

Las consultas y criterios de aceptación están documentados
en `../sql/exercises.md`.

### Facturación por cliente

Se relacionan clientes, pedidos y pedido_items mediante JOIN.

La agrupación se realiza por cliente para evitar obtener una
fila por cada pedido.

### Clientes sin pedidos

Se utiliza NOT EXISTS para identificar clientes
que no aparecen en la tabla pedidos.

### Facturación mensual

Se utilizan EXTRACT(MONTH FROM p.fecha) y EXTRACT(YEAR FROM p.fecha)
para agrupar la facturación por año y mes.

### Facturación por cliente (con/sin CTE)

Se utiliza una consulta directa con JOIN y una CTE.

### Seguridad y permisos

- tienda_readonly: SELECT permitido y UPDATE denegado.
- tienda_readwrite: operaciones DML permitidas.
- Las inserciones de prueba se revierten con ROLLBACK.

Las pruebas se realizan con SET ROLE desde una sesión
administrativa. Los roles NOLOGIN no permiten iniciar
sesión directamente.

Los privilegios definidos se aplican a los objetos existentes.
Los objetos futuros pueden requerir nuevos GRANT o
ALTER DEFAULT PRIVILEGES.

## Validación

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
