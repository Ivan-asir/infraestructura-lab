# Backup lógico y restauración

## 1. Objetivo y alcance

Crear un backup lógico de `tienda`, comprobar su restaurabilidad en una base independiente, recuperar selectivamente `productos` y automatizar la copia con `systemd`.

## 2. Entorno y requisitos

- `pg-primary` con PostgreSQL 18.6 y espacio de copia en `/var/lib/pgsql/backups`.
- `pg_dump`, `pg_restore`, script `../../scripts/backup.sh` y unidades `systemd` de `systemd/`.

## 3. Estructura de archivos

- `validation.txt`
- `systemd/pg-lab-backup.service`
- `systemd/pg-lab-backup.timer`
- `../../scripts/backup.sh`

## 4. Preparación

Comprobar capacidad y permisos en `/var/lib/pgsql/backups`, la existencia del backup y las bases de destino antes de restaurar. Preservar `tienda`; la recuperación se hace en bases auxiliares.

## 5. Procedimiento de ejecución

### Backup

El backup se crea en formato custom con `pg_dump -Fc` dentro de
`/var/lib/pgsql/backups`.

Los ficheros `*.dump` no se almacenan en Git.

### Restauración de prueba

El backup se restaura en `tienda_restore`. La validación compara las cuatro tablas entre `tienda` y `tienda_restore`.

### Recuperación de una tabla específica

Restaura solo la tabla `productos` en la base de datos `tienda_tabla_rescate`,
compara datos recuperados y prepara un ensayo de corrección sobre `tienda`
que finaliza con `ROLLBACK`. No se efectúa ninguna actualización de producción.

### Automatización

- Script instalado: `/usr/local/sbin/pg-lab-backup`
- Servicio: `pg-lab-backup.service`
- Timer: `pg-lab-backup.timer`
- Usuario de ejecución: `postgres`

## 6. Comprobaciones y criterios de aceptación

Los criterios siguientes se contrastaron con los resultados registrados en `validation.txt`.

Cada backup se comprueba preliminarmente con `pg_restore --list` (solo consulta,
no restaura la base de datos). La validación completa requiere ejecutar una restauración
independiente y comprobar sus datos.

## 7. Incidencias y limitaciones

El listado de un dump no acredita su restaurabilidad completa; probar una restauración aislada.

## 8. Reversión y recuperación

No sobrescribir `tienda`: la recuperación se prueba sobre bases auxiliares. No borrar dumps sin validar retención y recuperación.

## 9. Seguridad

No publicar contraseñas, variables reales de `.env`, claves privadas, datos persistentes, dumps, WAL ni capturas sensibles.

## 10. Estado y evidencias

- **Estado:** VALIDADO; dump `14 288` bytes, restauración completa, tabla selectiva, timer y reversión transaccional.
- **Evidencia:** `validation.txt`.