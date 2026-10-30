# Configuración WAL y recuperación PITR

## Parámetros de archivado

Configuración de referencia para el archivado. Antes de aplicarla, comprobar servicio, PGDATA, permisos, espacio y parámetros existentes. Las rutas del ejemplo deben corresponder al entorno identificado:

```ini
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /var/lib/pgsql/wal_archive/%f && cp %p /var/lib/pgsql/wal_archive/%f'
```

- `wal_level`: información WAL adecuada para recuperación y replicación.
- `archive_mode`: activa el archivado de segmentos WAL completos.
- `archive_command`: copia cada archivo WAL al directorio de archivado,
  evitando sobrescribir otro archivo con el mismo nombre.

Directorio de archivado:

`/var/lib/pgsql/wal_archive`

El comando de archivado puede fallar si el archivo de destino ya existe. Es un ejemplo: no sustituye una solución de archivado durable. Investigar el destino existente; no añadir un éxito incondicional que oculte un WAL diferente o incompleto.

## Parámetros de recuperación

Configuración para la copia física restaurada. Sustituir `<OBJETIVO_UTC_DE_LA_EJECUCION>` por el instante confirmado en esa ejecución antes de arrancar; el bloque con el marcador no es una configuración lista para usar:

```ini
restore_command = 'cp /var/lib/pgsql/wal_archive/%f %p'
recovery_target_time = '<OBJETIVO_UTC_DE_LA_EJECUCION>'
recovery_target_action = 'pause'
```

El archivo `recovery.signal` indica a PostgreSQL que debe iniciar
la recuperación desde WAL.

El objetivo conservado de la ejecución del 23/10/2026 es `2026-10-23 08:55:25.354183+00`; consultar `timeline.md`. No reutilizarlo en una recuperación nueva.

## Comportamiento de la pausa

`recovery_target_action = pause` detiene la reproducción al
alcanzar el objetivo configurado.

Durante la pausa pueden mantenerse bloqueos derivados de operaciones
DDL reproducidas desde WAL. Por tanto, una consulta de la tabla
recuperada puede quedar bloqueada hasta finalizar la recuperación.

La pausa se comprueba mediante:

```sql
SELECT pg_is_in_recovery();
SELECT pg_get_wal_replay_pause_state();
```

Después de verificar los logs y el objetivo temporal:

```sql
SELECT pg_wal_replay_resume();
```

En este laboratorio, la ejecución satisfactoria permitió completar
la recuperación y convertir el clúster restaurado en primario.

## Verificación de la copia base

Directorio:

`/var/lib/pgsql/backups/pitr-base`

Se validaron correctamente los archivos y checksums mediante
`pg_verifybackup --no-parse-wal`.

Esto no equivale a una verificación automática completa de WAL.
La recuperación funcional PITR sí fue ejecutada y comprobada.

## Evidencia

Consultar `validation.txt`.
