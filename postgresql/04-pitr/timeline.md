# Línea temporal de WAL y PITR — `pg-primary`

## 1. Objetivo y referencia horaria

- Escenario: eliminación deliberada de `tienda.public.pitr_marker` y recuperación física anterior al borrado.
- Zona horaria de todos los instantes: **UTC**, salvo que se indique lo contrario.
- Objetivo: `2026-10-23 08:55:25.354183+00`.

## 2. Secuencia de eventos

| Orden | Evento | Evidencia |
|---:|---|---|
| 1 | Fin de `pg_basebackup` | Consultar logs de la ejecución o notas originales |
| 2 | `INSERT` y `COMMIT` en `pitr_marker` | Consultar historia SQL o registro fiable |
| 3 | Instante objetivo PITR | `2026-10-23 08:55:25.354183+00` | `postgresql/04-pitr/README.md` |
| 4 | `DROP TABLE public.pitr_marker` | Consultar logs y transcripción original |
| 5 | `pg_switch_wal()` / archivado | Consultar evidencia original de WAL |
| 6 | Pausa de recuperación | `validation.txt`: `paused` e `pg_is_in_recovery()=t` |
| 7 | Pausa antes del COMMIT de transacción 932 | El log citado en `validation.txt` registra esa transacción; **no** atribuir esa hora al inicio de la pausa |
| 8 | Bloqueo `AccessExclusiveLock` | `validation.txt`: bloqueo del proceso startup sobre `pitr_marker` |
| 9 | `pg_wal_replay_resume()` | `validation.txt` registra ejecución correcta |
| 10 | Recuperación de la fila | `validation.txt`: una fila `Fila que debe sobrevivir` |
| 11 | Historial WAL archivado (`00000002.history`) | Instante registrado en `pg_stat_archiver`; **no** es necesariamente la hora del paso PITR |
| 12 | Retorno al PGDATA original | `validation.txt` confirma `active`, recuperación `f`, ausencia de tabla y recuentos |
| 13 | Restauración del snapshot `04_backup_logico_restauracion` | `validation.txt`: snapshot disponible, no utilizado |

## 3. Comprobación de coherencia del retorno

El retorno al **PGDATA original** consta como `VALIDADO` en `validation.txt`: servicio `active`, `pg_is_in_recovery()=f`, ausencia de `pitr_marker` y recuentos de `tienda` 24/100/200/200. En cambio, el snapshot `04_backup_logico_restauracion` estaba disponible y **no se utilizó**: su restauración no queda probada.

## 4. Conclusión

Cronología documental **PARCIAL**, horas exactas no registradas.
