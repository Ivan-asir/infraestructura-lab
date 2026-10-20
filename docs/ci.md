# Integración continua del laboratorio

- `validate.yml` ejecuta `bash scripts/validate-repository.sh`.
- `postgresql-tests.yml` crea una base efímera `tienda` y comprueba los SQL.
- Los workflows arrancan automáticamente al hacer `git push` y al abrir una pull request.
- También admiten ejecución manual desde GitHub → Actions → workflow → Run workflow
  (solo si están publicados en la rama predeterminada).
- Para ver un fallo: Actions → ejecución → trabajo → primer paso rojo.
- Ningún workflow se conecta a las VMs ni despliega cambios en `pg-primary`.
- Las URL de ejecuciones reales se registran en `docs/docker-validation.md`.
- El validador de formato no detecta secretos dentro de archivos de texto.
