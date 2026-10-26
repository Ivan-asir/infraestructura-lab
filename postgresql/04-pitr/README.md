# WAL y recuperación PITR

## Objetivo

Configurar el archivado WAL de PostgreSQL, realizar una copia base
física y recuperar el clúster hasta un instante anterior a un
`DROP TABLE`.

La validación funcional se realiza sobre `tienda.public.pitr_marker`.

## Entorno

- Servidor: `pg-primary`.
- Sistema operativo: Rocky Linux 9.
- PostgreSQL: 18.6, instalación nativa.
- Directorio de datos: `/var/lib/pgsql/data`.
- Archivo WAL: `/var/lib/pgsql/wal_archive`.
- Copia base: `/var/lib/pgsql/backups/pitr-base`.

Esta recuperación afecta al clúster PostgreSQL completo, no solo
a la base de datos `tienda`.

## Requisitos de seguridad

Ejecutar en una VM de laboratorio y con opciones para revertir cambios disponibles.

Antes de detener PostgreSQL deben verificarse el servicio,
las rutas, el espacio disponible y la existencia de la copia base.

No sobrescribir directorios existentes ni eliminar el clúster
original para realizar la recuperación.

## 1. Diagnóstico del archivado

Desde `pg-primary`, como `labadmin`:

```bash
sudo -u postgres psql -X -d postgres -c "
SHOW wal_level;
SHOW archive_mode;
SHOW archive_command;
"
```

Consultar también las estadísticas:

```bash
sudo -u postgres psql -X -d postgres -c "
SELECT last_archived_wal, last_archived_time,
       archived_count, failed_count, last_failed_time
FROM pg_stat_archiver;
"
```

El detalle de los parámetros está en `configuration.md`.

## 2. Copia base

La copia física se realiza con `pg_basebackup`, sobre un
directorio de destino que no contenga archivos anteriores.

Comando de referencia:

```bash
sudo -u postgres pg_basebackup \
  -D /var/lib/pgsql/backups/pitr-base \
  -Fp -Xs -P
```

Antes de ejecutarlo es imprescindible comprobar que el destino
está disponible y que existe espacio suficiente.

Verificación completa, si las herramientas están disponibles:

```bash
cd /tmp
sudo -u postgres pg_verifybackup \
  /var/lib/pgsql/backups/pitr-base
```

Comprobar la integridad de archivos y checksums:

```bash
sudo -u postgres pg_verifybackup --no-parse-wal \
  /var/lib/pgsql/backups/pitr-base
```

Esto no incluye la comprobación automática adicional de WAL.

## 3. Instante objetivo

Se creó una fila de prueba en `public.pitr_marker` y se registró
un instante UTC después de confirmar su inserción.

Posteriormente se ejecutó `DROP TABLE` para provocar la pérdida
controlada del objeto.

Objetivo registrado:

`2026-10-23 08:55:25.354183+00`

Este instante pertenece a la ejecución documentada; no debe
reutilizarse en una práctica nueva.

## 4. Recuperación física

La recuperación requiere:

1. Detener `postgresql.service`.
2. Preservar el PGDATA original sin sobrescribirlo.
3. Colocar una copia del backup físico en la ruta de datos activa.
4. Configurar `restore_command` y `recovery_target_time`.
5. Establecer `recovery_target_action = pause`.
6. Crear `recovery.signal`.
7. Arrancar PostgreSQL y comprobar el progreso en los logs.

La configuración utilizada se describe en `configuration.md`.

**Advertencia:** no repetir esta secuencia sobre el clúster actual
sin comprobar antes los directorios y el procedimiento de retorno.

## 5. Pausa y bloqueo observado

Se alcanzó el instante objetivo con:

- `pg_is_in_recovery() = t`.
- `pg_get_wal_replay_pause_state() = paused`.

La lectura de `public.pitr_marker` quedó bloqueada por un
`AccessExclusiveLock` del proceso `startup` durante la recuperación.

Por este motivo, la validación de la pausa se realizó mediante
las funciones de recuperación y el log de PostgreSQL, no
mediante una lectura bloqueante de la tabla.

## 6. Finalización

Una vez confirmado el objetivo en los logs, se ejecutó:

```sql
SELECT pg_wal_replay_resume();
```

Después se comprobó:

```sql
SELECT pg_is_in_recovery();
```

Resultado obtenido: `f`.

Finalmente se pudo consultar `public.pitr_marker` y recuperar:

`Fila que debe sobrevivir`

## 7. Retorno al estado original

Se conservó el PGDATA anterior a PITR en:

`/var/lib/pgsql/data-after-drop`

El procedimiento de retorno consiste en detener PostgreSQL,
conservar el clúster PITR en otro directorio y devolver el
PGDATA original a `/var/lib/pgsql/data`.

No restaurar directamente un snapshot antiguo sin evaluar
los cambios que se perderían.

El retorno se considera validado únicamente cuando:

- `postgresql.service` vuelve a estar activo.
- El clúster original utiliza `/var/lib/pgsql/data`.
- `pg_is_in_recovery()` devuelve `f`.
- `public.pitr_marker` está ausente.
- Los recuentos principales de `tienda` son correctos.
- El clúster PITR permanece conservado como evidencia.

## Evidencias

Consultar `validation.txt` para los resultados reales, las
incidencias encontradas y el estado de la reversión.