# Configuración WAL y recuperación PITR

## Parámetros de archivado

La configuración utilizada en PostgreSQL 18.6 fue:

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

El comando de archivado puede fallar si el archivo de destino ya existe.

## Parámetros de recuperación

Configuración aplicada a la copia física restaurada:

```ini
restore_command = 'cp /var/lib/pgsql/wal_archive/%f %p'
recovery_target_time = '2026-10-23 08:55:25.354183+00'
recovery_target_action = 'pause'
```

El archivo `recovery.signal` indica a PostgreSQL que debe iniciar
la recuperación desde WAL.

El objetivo temporal corresponde a la ejecución del 23/10/2026.

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