# PostgreSQL 18 oficial con servidor ya instalado

FROM postgres:18

# Añadir esquema y datos (no contraseñas ni volúmenes)

COPY postgresql/sql/schema.sql /docker-entrypoint-initdb.d/01-schema.sql

COPY postgresql/sql/seed.sql /docker-entrypoint-initdb.d/02-seed.sql