# Backup lógico y restauración

## Objetivo

Crear un backup lógico de la base de datos `tienda`, verificar que el fichero
es legible, restaurarlo en una base distinta, recuperar selectivamente la tabla
`productos` en un destino auxiliar y automatizar su ejecución con systemd.

## Backup

El backup se crea en formato custom con `pg_dump -Fc` dentro de
`/var/lib/pgsql/backups`.

Los ficheros `*.dump` no se almacenan en Git.

## Verificación

Cada backup se comprueba preliminarmente con `pg_restore --list` (solo consulta,
no restaura la base de datos). La validación completa requiere ejecutar una restauración
independiente y comprobar sus datos.

## Restauración de prueba

El backup se restaura en `tienda_restore`. La validación consiste en comparar
los recuentos de `clientes` y `pedidos` entre `tienda` y `tienda_restore`.

## Recuperación de una tabla específica

Restaura solo la tabla `productos` en la base de datos `tienda_tabla_rescate`,
compara datos recuperados y prepara un ensayo de corrección sobre `tienda`
que finaliza con `ROLLBACK`. No se efectúa ninguna actualización de producción.

## Automatización

- Script instalado: `/usr/local/sbin/pg-lab-backup`
- Servicio: `pg-lab-backup.service`
- Timer: `pg-lab-backup.timer`
- Usuario de ejecución: `postgres`

## Resultado

Consultar `validation.txt` para las salidas reales obtenidas.
