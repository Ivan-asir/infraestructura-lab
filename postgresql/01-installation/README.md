# Instalación de PostgreSQL

## Entorno

- Host: `pg-primary`
- Rocky Linux: `Rocky Linux release 9.8 (Blue Onyx)`
- Paquetes PostgreSQL instalados: `postgresql-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`, `postgresql-private-libs-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`, `postgresql-server-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`
- Servicio: `postgresql.service`

## Procedimiento

1. Comprobar el stream disponible.
2. Instalar el servidor PostgreSQL.
3. Inicializar el cluster.
4. Habilitar y arrancar `postgresql.service`.
5. Crear el rol `app_user`, la base `appdb` y el esquema `app`.
6. Configurar la contraseña de `app_user` de forma interactiva, sin
   almacenarla en el repositorio.

## Creación de objetos iniciales

El archivo `create-lab-db.sql` permite crear el rol
`app_user`, la base `appdb` y el esquema `app`.

Está destinado a instalaciones nuevas y debe ejecutarse
una sola vez, sobre un entorno donde no existan los objetos.

La contraseña de `app_user` se configura posteriormente
de forma interactiva mediante `\password app_user`.

## Rutas efectivas

- `data_directory`: `/var/lib/pgsql/data`
- `config_file`: `/var/lib/pgsql/data/postgresql.conf`
- `hba_file`: `/var/lib/pgsql/data/pg_hba.conf`
- `listen_addresses`: `localhost`

## Validación

La instalación se considera correcta cuando:

- `postgresql.service` está activo.
- `pg_isready` responde correctamente en local.
- PostgreSQL devuelve su versión.
- No se ha abierto todavía el puerto 5432 a la red Host-only.

La evidencia de lo anterior se encuentra en `validation.txt`.
