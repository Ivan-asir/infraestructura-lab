# Imagen PostgreSQL propia — Compose independiente

## 1. Objetivo y alcance

Construir la imagen `postgresql-tienda:lab` basada en `postgres:18`, con los scripts SQL de inicialización de `tienda`, y probarla en un servicio separado del despliegue principal.

## 2. Entorno y requisitos

Ubuntu/WSL2, Docker Desktop y Docker Compose. Asegurar recursos y puertos libres; comprobar Docker antes del build.

## 3. Estructura de archivos

- `Dockerfile`: imagen y copia de SQL.
- `docker-compose.yml`: servicio `db_postgres_tienda_imagen`, proyecto `infraestructura-lab-docker-postgresql-imagen`.
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

Antes de arrancar, comprobar el puerto `127.0.0.1:15433` y la clave de volumen `tienda_imagen` (nombre Docker predeterminado: `infraestructura-lab-docker-postgresql-imagen_tienda_imagen`). Los comandos anteriores ya cargan `docker/.env` mediante `--env-file .env` desde `docker/`. No ejecutar `down -v`; `build` y `up` crean o inician recursos.

## 6. Comprobaciones y criterios de aceptación

Validar Compose; comprobar contenedor healthy, tablas y recuentos; comprobar que no altera `db_postgres_tienda`; documentar la persistencia separada si se ensaya. Registrar resultados en `validation.txt`.

## 7. Incidencias y limitaciones

El entrypoint de PostgreSQL solo ejecuta SQL inicial cuando el directorio de datos está vacío. La presencia de la imagen no prueba que el SQL se haya aplicado sobre un volumen existente.

## 8. Reversión y recuperación

Detener exclusivamente el proyecto `infraestructura-lab-docker-postgresql-imagen` preservando `tienda_imagen`. Desde `docker/`, utilizar `docker compose --env-file .env -f image/docker-compose.yml stop`. Conservar esos mismos argumentos al usar `start`, `ps` o `logs`. No eliminar volúmenes ni imágenes compartidas.

## 9. Seguridad

Excluir `.env`, claves, dumps y ficheros privados del contexto y del repositorio. Puertos publicados solo en `127.0.0.1`.

## 10. Estado y evidencias

- **Ejecución conservada:** pruebas con el proyecto `tienda-imagen-lab` y el volumen de aquella ejecución; ver los archivos de evidencia.
- **Configuración vigente:** proyecto `infraestructura-lab-docker-postgresql-imagen` y volumen `tienda_imagen`.
- Evidencia ampliada: `../../docs/docker-image-validation.md`.
- Resumen estructurado: `validation.txt`.
