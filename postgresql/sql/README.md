# SQL compartido del laboratorio `tienda`

Este directorio contiene **recursos comunes**, no una práctica independiente.

## Contenido

- `schema.sql`: estructura y restricciones.
- `seed.sql`: datos sintéticos de inicialización.
- `exercises.sql`: soluciones de consultas.
- `exercises.md`: enunciados y criterios.
- `assertions.sql`: aserciones de recuentos, integridad y rechazo de valores inválidos en el fixture inicial.

## Uso y dependencia

Estos archivos se consumen desde `postgresql/02-sql-roles/` y desde `docker/` y `docker/image/`. **No ejecutar los scripts de creación y carga sobre una base con datos sin inspeccionar primero el estado.**

## Validación

En una base de CI desechable, después de cargar `schema.sql`, `seed.sql` y `exercises.sql`, ejecutar:

```bash
psql -X -v ON_ERROR_STOP=1 -f postgresql/sql/assertions.sql
```

La conexión se configura con las variables PostgreSQL del entorno de CI.
Las comprobaciones se ejecutan en una transacción que termina con `ROLLBACK`.
Cualquier incumplimiento debe devolver un código distinto de cero. No aplicar
los recuentos del fixture a una base modificada por ejercicios de persistencia.