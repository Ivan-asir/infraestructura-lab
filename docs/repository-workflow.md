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

El script `scripts/validate-repository.sh` comprueba que se ejecuta dentro de
un repositorio Git, revisa los cambios con `git diff --check` y
`git diff --cached --check`, detecta algunos nombres de archivos sensibles
entre los versionados y valida los scripts de `scripts/` con `bash -n`.

No analiza el contenido para detectar secretos ni ejecuta ShellCheck,
`ansible-playbook` o `ansible-lint`. Esas comprobaciones, cuando se utilicen,
deben ejecutarse por separado.

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
