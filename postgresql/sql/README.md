# SQL compartido del laboratorio `tienda`

Este directorio contiene **recursos comunes**, no una práctica independiente.

## Contenido

- `schema.sql`: estructura y restricciones.
- `seed.sql`: datos sintéticos de inicialización.
- `exercises.sql`: soluciones de consultas.
- `exercises.md`: enunciados y criterios.

## Uso y dependencia

Estos archivos se consumen desde `postgresql/02-sql-roles/` y desde `docker/` y `docker/image/`. **No ejecutar los scripts de creación y carga sobre una base con datos sin inspeccionar primero el estado.**

## Validación

La validación de este material queda registrada en `postgresql/02-sql-roles/validation.txt` y en las evidencias de los contenedores que lo utilizan. No se duplica aquí.
