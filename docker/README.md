# PostgreSQL de pruebas con Docker Compose

## 1. Objetivo y alcance

Instancia reproducible y separada de `pg-primary`.

## 2. Entorno y requisitos

- Ubuntu en WSL2 con Docker Desktop, Docker Engine y Docker Compose.
- Instancia de contenedor independiente del PostgreSQL nativo de `pg-primary`.
- Archivos SQL compartidos: `../postgresql/sql/schema.sql` y `../postgresql/sql/seed.sql`.
- Proyecto Compose `infraestructura-lab-docker-postgresql`.
- Puerto local `127.0.0.1:15432` y clave de volumen `tienda_data`.
- Nombre Docker predeterminado: `infraestructura-lab-docker-postgresql_tienda_data`.

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

La instancia usa `../postgresql/sql/schema.sql`, `../postgresql/sql/seed.sql` y el volumen `tienda_data`. Al inicializar una base vacía debe haber 24 clientes, 100 productos, 200 pedidos y 200 líneas. Los SQL de inicialización no se repiten al arrancar un volumen ya utilizado.

La prueba de persistencia se realizó mediante `docker compose down` y `docker compose up -d`, sin utilizar `down -v`. Se confirmó posteriormente la conservación del registro de prueba.

No se publican `docker/.env`, claves ni el volumen.

La construcción de la imagen propia se define en `image/Dockerfile`; el despliegue utiliza `image/docker-compose.yml` y el proyecto independiente `infraestructura-lab-docker-postgresql-imagen`. Consulta [su procedimiento](image/README.md) y [las evidencias](../docs/docker-image-validation.md). El contexto de construcción es la raíz del repositorio y `.dockerignore` excluye secretos.

## 6. Comprobaciones y criterios de aceptación

La aceptación requiere servicio disponible, recuentos comprobados y persistencia ensayada. Los resultados existentes se conservan en `validation.txt` y `../docs/docker-validation.md`.

## 7. Incidencias y limitaciones

Los scripts de entrada solo se ejecutan al inicializar un directorio de datos vacío; `docker compose up` sobre volumen existente no los repite.

## 8. Reversión y recuperación

Detener con `docker compose stop` preserva el volumen; no utilizar `down -v`, `prune` ni eliminar el volumen para reiniciar el laboratorio.

## 9. Seguridad

No publicar contraseñas, variables reales de `.env`, claves privadas, datos persistentes, dumps, WAL ni capturas sensibles.

## 10. Estado y evidencias

- **Evidencia existente:** despliegue, datos y CI registrados.
- **Configuración vigente:** proyecto `infraestructura-lab-docker-postgresql`, volumen `tienda_data` y variables explícitas; su validación funcional se registra en una ejecución propia.
