# PostgreSQL — índice de prácticas

Este directorio agrupa prácticas y materiales compartidos de PostgreSQL. Es un **directorio índice**, no una práctica autónoma; cada práctica numerada mantiene `README.md` y `validation.txt`.

## Prácticas

- [`01-installation/`](01-installation/README.md): instalación, objetos iniciales y comprobación.
- [`02-sql-roles/`](02-sql-roles/README.md): SQL, roles y permisos.
- [`03-backups/`](03-backups/README.md): backup lógico, restauración y timer.
- [`04-pitr/`](04-pitr/README.md): WAL, copia base, PITR y reversión.
- [`05-performance/`](05-performance/README.md): planes antes/después del índice y límites de la medición.
- [`sql/`](sql/README.md): SQL compartido por distintas prácticas.

## Convenciones

Las prácticas usan los diez epígrafes comunes de `../docs/plantilla-readme.md` y las cinco secciones de `../docs/plantilla-validaciones.md`. No se publican datos de `PGDATA`, WAL, dumps, contraseñas ni secretos. La carpeta `sql/` no representa un despliegue independiente, por lo que no genera una segunda `validation.txt`.
