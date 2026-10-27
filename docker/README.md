# PostgreSQL de pruebas con Docker Compose

## 1. Objetivo y alcance

Instancia reproducible y separada de `pg-primary`.

## 2. Entorno y requisitos

- Ubuntu en WSL2 con Docker Desktop, Docker Engine y Docker Compose.
- Instancia de contenedor independiente del PostgreSQL nativo de `pg-primary`.
- Archivos SQL compartidos: `../postgresql/sql/schema.sql` y `../postgresql/sql/seed.sql`.
- Puerto local `127.0.0.1:15432` y volumen Compose `pg_lab_data`.

## 3. Estructura de archivos

- `docker-compose.yml`
- `.env.example`
- `validation.txt`
- `image/README.md`
- `image/validation.txt`

## 4. Preparación

Desde `docker/`, revisar el archivo `.env` local sin publicarlo, comprobar `docker compose ps -a`, `docker volume ls` y validar `docker compose config --quiet` antes de iniciar el servicio. Si ya hay datos, no reinicializar el volumen.

## 5. Procedimiento de ejecución

Desde `docker/`, validar con `docker compose config --quiet`, iniciar con
`docker compose up -d` y comprobar el servicio `db_postgres_tienda` y el contenedor `db_postgres_tienda` mediante `docker compose ps`.

La instancia usa `../postgresql/sql/schema.sql`, `../postgresql/sql/seed.sql` y el volumen `pg_lab_data`. Al inicializar una base vacía debe haber 24 clientes, 100 productos, 200 pedidos y 200 líneas. Los SQL de inicialización **no se repiten** al arrancar un volumen ya utilizado.

La prueba de persistencia usa `docker compose stop` y `docker compose start`.

No se publican `docker/.env`, claves ni el volumen.

La construcción de una imagen propia (sin datos persistentes) se documenta en `docker/image/Dockerfile`; el despliegue se define en `docker/image/docker-compose.yml` mediante el proyecto independiente `tienda-imagen-lab`. La construcción y sus pruebas se registran en `docs/docker-image-validation.md`. Para el build se utiliza la raíz del repositorio como contexto y se excluyen secretos mediante `.dockerignore`.

## 6. Comprobaciones y criterios de aceptación

El archivo `validation.txt` recoge la validación histórica del servicio: contenedor `healthy`, recuentos `24/100/200/200`, persistencia tras `stop/start` y dos workflows de CI correctos. El detalle está en `../docs/docker-validation.md`.

## 7. Incidencias y limitaciones

Los scripts de entrada solo se ejecutan al inicializar un directorio de datos vacío; `docker compose up` sobre volumen existente no los repite.

## 8. Reversión y recuperación

Detener con `docker compose stop` preserva el volumen; no utilizar `down -v`, `prune` ni eliminar el volumen para reiniciar el laboratorio.

## 9. Seguridad

No publicar contraseñas, variables reales de `.env`, claves privadas, datos persistentes, dumps, WAL ni capturas sensibles.

## 10. Estado y evidencias

- **Estado de la práctica documentada:** VALIDADO (véase `validation.txt` y `../docs/docker-validation.md`).
