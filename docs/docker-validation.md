# Validación de Docker y CI

- Docker Engine: 29.9.1

- Docker Compose: v5.6.0

- Servicio `db_postgres_tienda` (`docker ps -a`):
    - `STATUS Up 25 minutes (healthy)`
    - `NAMES db_postgres_tienda`

- Recuentos iniciales:
    - `docker exec db_postgres_tienda psql -U postgres -d tienda -Atc 'SELECT count(*) FROM clientes;'` 24

    - `docker exec db_postgres_tienda psql -U postgres -d tienda -Atc 'SELECT count(*) FROM productos;'` 100

    - `docker exec db_postgres_tienda psql -U postgres -d tienda -Atc 'SELECT count(*) FROM pedidos;'` 200

    - `docker exec db_postgres_tienda psql -U postgres -d tienda -Atc 'SELECT count(*) FROM pedido_items;'` 200

- Persistencia de `persistencia@example.test` tras stop/start:
    - `docker exec db_postgres_tienda psql -U postgres -d tienda -Atc "SELECT count(*) FROM clientes WHERE email = 'persistencia@example.test';"` 1

- Workflow `validate.yml` (enlace y estado): PENDIENTE

- Workflow `postgresql-tests.yml` (enlace y estado): PENDIENTE

- Incidencias y solución aplicada: PENDIENTE