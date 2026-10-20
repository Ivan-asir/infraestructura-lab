# PostgreSQL de pruebas emplando Docker Compose

Desde `docker/`, validar con `docker compose config --quiet`, iniciar con
`docker compose up -d` y comprobar el servicio `db` mediante `docker ps -a`.

La instancia usa `../sql/schema.sql`, `../sql/seed.sql` y un volumen con nombre.
Al inicializar una base vacía debe haber 24 clientes, 100 productos,
200 pedidos y 200 líneas. Los SQL de inicialización **no se repiten** al arrancar
un volumen ya utilizado.

La prueba de persistencia usa `docker compose stop` y `docker compose start`;
`docker compose down -v` elimina el almacenamiento y **no debe usarse**.
No publicar `docker/.env`, claves ni el volumen.
