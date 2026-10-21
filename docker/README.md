# PostgreSQL de pruebas con Docker Compose

Desde `docker/`, validar con `docker compose config --quiet`, iniciar con
`docker compose up -d` y comprobar el servicio `db_postgres_tienda` y el contenedor `db_postgres_tienda` mediante `docker compose ps`.

La instancia usa `../sql/schema.sql`, `../sql/seed.sql` y un volumen con nombre. Al inicializar una base vacía debe haber 24 clientes, 100 productos,
200 pedidos y 200 líneas. Los SQL de inicialización **no se repiten** al arrancar un volumen ya utilizado.

La prueba de persistencia usa `docker compose stop` y `docker compose start`.

No se publican `docker/.env`, claves ni el volumen.

La construcción de una imagen propia (sin datos persistentes) se documenta en `docker/image/Dockerfile`; el despliegue se define en `docker/image/docker-compose.yml` mediante el proyecto independiente `tienda-imagen-lab`. La construcción y sus pruebas se registran en `docs/docker-image-validation.md`. Para el build se utiliza la raíz del repositorio como contexto y se excluyen secretos mediante `.dockerignore`.