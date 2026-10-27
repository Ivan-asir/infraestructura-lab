# Instalación de PostgreSQL

## 1. Objetivo y alcance

Instalación nativa PostgreSQL sobre `pg-primary`.

## 2. Entorno y requisitos

- Servidor `pg-primary`: Rocky Linux 9.8 y PostgreSQL 18.6 de AppStream.
- Servicio del sistema `postgresql.service`; escucha limitada a `localhost`.
- Los comandos de administración de base de datos usan la cuenta de servicio `postgres`.

### Versiones y paquetes verificados

- Paquetes PostgreSQL instalados: `postgresql-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`, `postgresql-private-libs-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`, `postgresql-server-18.6-1.module+el9.8.0+40321+a908ab5d.x86_64`
- Servicio: `postgresql.service`

### Rutas efectivas

- `data_directory`: `/var/lib/pgsql/data`
- `config_file`: `/var/lib/pgsql/data/postgresql.conf`
- `hba_file`: `/var/lib/pgsql/data/pg_hba.conf`
- `listen_addresses`: `localhost`

## 3. Estructura de archivos

- `create-lab-db.sql`
- `validation.txt`

## 4. Preparación

En `pg-primary`, verificar `systemctl is-active postgresql.service`, `pg_isready` y la existencia previa de los objetos SQL. La inicialización y `create-lab-db.sql` son para instalaciones nuevas; no ejecutarlos de nuevo sobre una instancia poblada.

## 5. Procedimiento de ejecución

1. Comprobar el stream disponible.
2. Instalar el servidor PostgreSQL.
3. Inicializar el cluster.
4. Habilitar y arrancar `postgresql.service`.
5. Crear el rol `app_user`, la base `appdb` y el esquema `app`.
6. Configurar la contraseña de `app_user` de forma interactiva, sin
   almacenarla en el repositorio.

### Creación de objetos iniciales

El archivo `create-lab-db.sql` permite crear el rol
`app_user`, la base `appdb` y el esquema `app`.

Está destinado a instalaciones nuevas y debe ejecutarse
una sola vez, sobre un entorno donde no existan los objetos.

La contraseña de `app_user` se configura posteriormente
de forma interactiva mediante `\password app_user`.

## 6. Comprobaciones y criterios de aceptación

Los criterios siguientes se contrastaron con los resultados registrados en `validation.txt`.

La instalación se considera correcta cuando:

- `postgresql.service` está activo.
- `pg_isready` responde correctamente en local.
- PostgreSQL devuelve su versión.
- No se ha abierto todavía el puerto 5432 a la red Host-only.

La evidencia de lo anterior se encuentra en `validation.txt`.

## 7. Incidencias y limitaciones

La inicialización y la creación de objetos solo deben repetirse en una instancia nueva y previamente comprobada.

## 8. Reversión y recuperación

No hay reversión de instalación documentada aquí; antes de cambios en la VM, preparar snapshot y conservar datos.

## 9. Seguridad

No publicar contraseñas, variables reales de `.env`, claves privadas, datos persistentes, dumps, WAL ni capturas sensibles.

## 10. Estado y evidencias

- **Estado:** VALIDADO para PostgreSQL 18.6, `postgresql.service`, rol `app_user`, base `appdb` y esquema `app`.
- **Evidencia:** `validation.txt`.