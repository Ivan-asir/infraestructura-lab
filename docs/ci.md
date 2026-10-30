# Integración continua del laboratorio

- `validate.yml` ejecuta `bash scripts/validate-repository.sh`.
- `postgresql-tests.yml` crea una base efímera `tienda`, carga esquema y datos, ejecuta las consultas y comprueba recuentos y restricciones con `assertions.sql`.
- Los workflows arrancan automáticamente al hacer `git push` y al abrir una pull request.
- También admiten ejecución manual desde GitHub → Actions → workflow → Run workflow (solo si están publicados en la rama predeterminada).
- Para ver un fallo: Actions → ejecución → trabajo → primer paso rojo.
- Ningún workflow se conecta a las VMs ni despliega cambios en `pg-primary`.
- Las URL de ejecuciones reales se registran en `docs/docker-validation.md`.
- El validador de formato no detecta secretos dentro de archivos de texto.
- Jenkins mantiene su pipeline base de validación estática. No ejecuta estas pruebas SQL ni despliega la aplicación de Kubernetes.
- Aserciones SQL validadas localmente en `tienda_assertions_revision`:
  fixture correcto (24/100/200/200), ejecución positiva con código 0
  y prueba negativa detectada tras añadir un cliente.
- El registro de prueba se eliminó (`DELETE 1`).
- Tras eliminar el registro de prueba (`DELETE 1`), las aserciones
  volvieron a finalizar con código 0.

La prueba local positiva y la detección de la alteración están validadas.
