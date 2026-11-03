# Flujo de trabajo del repositorio

## Antes de preparar un commit

1. Ejecutar las validaciones específicas de cada apartado.
2. Revisar los ficheros modificados con `git status --short`.
3. Añadir únicamente rutas concretas con `git add RUTA`.
4. Ejecutar `bash scripts/validate-repository.sh`.
5. Revisar los nombres preparados con `git diff --cached --name-only`.
6. Revisar el contenido exacto con `git diff --cached`.
7. Crear el commit.
8. Hacer `git push`.

## Validación común

El script `scripts/validate-repository.sh` comprueba que se ejecuta dentro de un repositorio Git y trabaja desde su raíz. Revisa cambios con `git diff --check` y `git diff --cached --check`, espacios finales en todos los archivos de texto versionados del árbol de trabajo, nombres de archivos sensibles y sintaxis de todos los `*.sh` versionados mediante `bash -n`.

En CI, la comprobación de espacios finales se aplica al checkout completo aunque no existan diferencias locales. Los archivos nuevos no quedan incluidos hasta prepararlos expresamente con `git add`.

No detecta secretos dentro del contenido ni ejecuta ShellCheck, validación semántica YAML, `ansible-playbook` o `ansible-lint`. Las pruebas SQL corresponden al workflow `postgresql-tests.yml`. Ninguno de estos controles valida por sí solo los servicios o restauraciones de las VMs.

## Política de publicación

No se publican:

- Contraseñas ni tokens.
- Claves privadas.
- `.pgpass`.
- Ficheros de contraseña de Ansible Vault.
- `vault.yml` real, aunque esté cifrado, según el criterio de este laboratorio.
- Dumps o backups.
- WAL.
- Certificados privados.
- Directorios `.ssh`.
- Datos reales o identificables.
- Configuración de otros entornos.

Si un secreto llega a un commit o a un remoto, debe revocarse o rotarse.
Borrarlo en un commit posterior no elimina la exposición.

## Regla de preparación

No usar `git add .`. Preparar únicamente las rutas revisadas.
