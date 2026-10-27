# Imagen PostgreSQL propia — Compose independiente

## 1. Objetivo y alcance

Construir la imagen `postgresql-tienda:lab` basada en `postgres:18`, con los scripts SQL de inicialización de `tienda`, y probarla en un servicio separado del despliegue principal.

## 2. Entorno y requisitos

Ubuntu/WSL2, Docker Desktop y Docker Compose. Asegurar recursos y puertos libres; comprobar Docker antes del build.

## 3. Estructura de archivos

- `Dockerfile`: imagen y copia de SQL.
- `docker-compose.yml`: servicio `db_postgres_tienda_imagen`, proyecto `tienda-imagen-lab`.
- `validation.txt`: resumen homogéneo de resultados de la práctica.
- `../../docs/docker-image-validation.md`: evidencia ampliada.
- `../../.dockerignore`: exclusión de secretos del contexto de construcción.

## 4. Preparación

Desde la raíz del repositorio, comprobar que `postgresql/sql/schema.sql`, `postgresql/sql/seed.sql`, `docker/.env` y los dos archivos de este directorio existan. No publicar `docker/.env`.

## 5. Procedimiento de ejecución

El Compose del subdirectorio utiliza la raíz del repositorio como contexto de construcción. Desde `docker/` se puede validar y construir el proyecto separado, sin cambiar el despliegue principal:

```bash
docker compose --env-file .env -f image/docker-compose.yml config --quiet
docker compose --env-file .env -f image/docker-compose.yml build
docker compose --env-file .env -f image/docker-compose.yml up -d
docker compose --env-file .env -f image/docker-compose.yml ps
```

Antes de arrancar, comprobar el puerto `127.0.0.1:15433` y el volumen `pg_tienda_imagen_data`. No ejecutar `down -v`; los comandos anteriores crean o inician recursos y no son de solo lectura.

## 6. Comprobaciones y criterios de aceptación

Validar Compose; comprobar contenedor healthy, tablas y recuentos; comprobar que no altera `db_postgres_tienda`; documentar la persistencia separada si se ensaya. Registrar resultados en `validation.txt`.

## 7. Incidencias y limitaciones

El entrypoint de PostgreSQL solo ejecuta SQL inicial cuando el directorio de datos está vacío. La presencia de la imagen no prueba que el SQL se haya aplicado sobre un volumen existente.

## 8. Reversión y recuperación

Detener exclusivamente el proyecto `tienda-imagen-lab` preservando `pg_tienda_imagen_data`. No eliminar volúmenes ni imágenes compartidas durante esta práctica.

## 9. Seguridad

Excluir `.env`, claves, dumps y ficheros privados del contexto y del repositorio. Puertos publicados solo en `127.0.0.1`.

## 10. Estado y evidencias

- **Estado:** VALIDADO (imagen, despliegue, recuentos, persistencia e independencia del contenedor principal).
- Evidencia ampliada: `../../docs/docker-image-validation.md`.
- Resumen estructurado: `validation.txt`.