# Guía de ejecución del laboratorio de Sistemas, Bases de Datos y Automatización

> **Documento de ejecución.** Resume los pasos para reproducir las prácticas de este laboratorio.

## 1. Requisitos y recorrido

El laboratorio original utiliza **Rocky Linux 9.8** en **Oracle VirtualBox**, PostgreSQL **18.6** de AppStream, y un segundo entorno **Windows 11 + Ubuntu/WSL2 + Docker Desktop**. Son **dos instancias distintas** de PostgreSQL: la nativa en la VM y la del contenedor.

- VirtualBox con una VM Rocky Linux 9, usuario administrador con `sudo`, salida a Internet y una interfaz Host-only.
- Git, acceso al repositorio y conectividad SSH a la VM.
- Para el recorrido de contenedores: Docker Desktop con integración WSL2, Docker Compose y espacio para las imágenes y volúmenes.
- Ajustar direcciones IP y nombres de interfaces si el anfitrión utiliza una red diferente. Los valores de este documento corresponden a la red de ejemplo.
- La inicialización, instalación y restauración se plantean para máquinas y bases de datos nuevas.

Orden sugerido:

1. Preparar la VM y la red.
2. Instalar PostgreSQL nativo e inicializar el laboratorio SQL.
3. Aplicar roles y ejecutar consultas.
4. Configurar el backup lógico y probar una restauración aislada.
5. Realizar WAL/PITR **solo en una VM aislada, con punto de retorno verificado**.
6. En otro entorno, iniciar Docker Compose y probar la imagen propia.
7. Validar el repositorio y consultar los resultados de GitHub Actions.

Los documentos `docs/network.md`, `docs/rocky-baseline.md`, `postgresql/01-installation/README.md`, `postgresql/02-sql-roles/README.md`, `postgresql/03-backups/README.md`, `postgresql/04-pitr/README.md` y `docs/docker-validation.md` contienen la configuración y los resultados registrados en el laboratorio original. Sus evidencias sirven de referencia, **no son salidas garantizadas en otro equipo**.

Las evidencias `validation.txt` de cada capítulo utilizan la [misma estructura](formato-validaciones.md): contexto, resultados, incidencias, estado final/reversión y conclusión. No se deben publicar salidas de ejemplo como evidencias reales.

## 2. Descargar el repositorio

**En Rocky Linux y, separadamente, en Ubuntu/WSL2 si se realiza Docker:**

```bash
git clone https://github.com/Ivan-asir/infraestructura-lab.git
cd infraestructura-lab
bash scripts/validate-repository.sh
```

El validador requiere un repositorio Git (`.git`): si se descarga un ZIP, la verificación basada en Git no podrá funcionar sin inicializar un repositorio. No usar `git add .` ni publicar datos privados.

## 3. Crear la VM, red y acceso SSH

**En VirtualBox (interfaz gráfica):** crear una VM Rocky Linux 9 con un adaptador **NAT** y otro **Host-only** en `192.168.56.0/24`. Configurar el anfitrión Host-only como `192.168.56.1/24`. En la VM de referencia, NAT es `enp0s3` y Host-only es `enp0s8`; identificar las interfaces reales antes de modificar perfiles.

**En Rocky Linux, como usuario administrador (ejemplo: `labadmin`):**

```bash
cat /etc/rocky-release
ip -br -4 addr
ip -4 route
nmcli connection show
```

Solo si se ha identificado que el perfil Host-only se llama `enp0s8` y todavía no tiene dirección:

```bash
sudo nmcli connection modify enp0s8 ipv4.method manual ipv4.addresses 192.168.56.20/24 ipv4.never-default yes
sudo nmcli connection up enp0s8
```

Se espera una interfaz Host-only en `192.168.56.20/24` y que **la ruta por defecto siga pasando por NAT**. No configurar una segunda puerta de enlace en Host-only. Ajustar el perfil si NetworkManager utiliza otro nombre.

Comprobaciones:

```bash
ip -br -4 addr
ip -4 route
getent hosts github.com
systemctl is-active sshd.service
systemctl is-active firewalld.service
getenforce
```

Desde el anfitrión, probar SSH a `labadmin@192.168.56.20` con el método de autenticación configurado. No guardar claves privadas, contraseñas ni archivos `.ppk` en Git. Véanse `docs/network.md` y `docs/diagrams/network-topology.md`.

## 4. Instalar PostgreSQL nativo

**En Rocky Linux, usuario administrador; solo instalación nueva.** Comprobar primero que no existe un clúster con datos:

```bash
rpm -qa | grep '^postgresql'
systemctl status postgresql.service --no-pager
sudo dnf module list postgresql
```

Si AppStream ofrece el stream **18** previsto en el laboratorio, instalarlo. No ejecutar `--initdb` sobre un clúster existente:

```bash
sudo dnf -y module install postgresql:18/server
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql.service
```

Validar el servicio, la versión y **las rutas efectivas**, que pueden cambiar según el empaquetado:

```bash
systemctl is-active postgresql.service
sudo -u postgres pg_isready
sudo -u postgres psql -c 'SELECT version();'
sudo -u postgres psql -c 'SHOW data_directory;'
sudo -u postgres psql -c 'SHOW listen_addresses;'
```

La instalación de referencia escucha en `localhost`. Para estas prácticas **no es necesario abrir el puerto 5432 a Host-only**.

## 5. Crear las bases de datos y cargar el modelo SQL

**En la raíz del repositorio clonado en Rocky Linux, como `labadmin`:**

El archivo `postgresql/01-installation/create-lab-db.sql` crea `app_user`, `appdb` y el esquema `app`. **Ejecutar una vez, solamente si no existen esos objetos:**

```bash
sudo -u postgres psql -v ON_ERROR_STOP=1 -d postgres < postgresql/01-installation/create-lab-db.sql
```

Establecer la contraseña del rol, si se necesita autenticación por contraseña, **interactivamente**:

```bash
sudo -u postgres psql -d postgres
```

Dentro de `psql`: `\password app_user` y, para salir, `\q`. No escribir contraseñas en los scripts ni en el repositorio.

**`appdb` y `tienda` son bases de datos diferentes.** Crear la base de datos `tienda` solo si aún no existe, y cargar el esquema y los datos, **una sola vez**:

```bash
sudo -u postgres createdb tienda
sudo -u postgres psql -v ON_ERROR_STOP=1 -d tienda < postgresql/sql/schema.sql
sudo -u postgres psql -v ON_ERROR_STOP=1 -d tienda < postgresql/sql/seed.sql
```

La redirección `<` permite que la terminal de `labadmin` lea los SQL del repositorio y envíe su contenido a `psql` ejecutado como `postgres`, incluso cuando `postgres` no tiene acceso directo al directorio personal de `labadmin`.

```bash
sudo -u postgres psql -d tienda -c 'SELECT count(*) FROM clientes;'
sudo -u postgres psql -d tienda -c 'SELECT count(*) FROM productos;'
sudo -u postgres psql -d tienda -c 'SELECT count(*) FROM pedidos;'
sudo -u postgres psql -d tienda -c 'SELECT count(*) FROM pedido_items;'
```

Recuentos de referencia: **24, 100, 200 y 200**. Las fechas de los pedidos se calculan a partir de `now()` en `postgresql/sql/seed.sql`, por lo que serán relativas al día de la carga.

## 6. SQL, roles y permisos

**Sobre una instalación nueva de `tienda`**, crear una sola vez los roles definidos en el repositorio:

```bash
sudo -u postgres psql -v ON_ERROR_STOP=1 -d tienda < postgresql/02-sql-roles/roles.sql
sudo -u postgres psql -v ON_ERROR_STOP=1 -d tienda < postgresql/sql/exercises.sql
```

Los roles `tienda_readonly` y `tienda_readwrite` son `NOLOGIN`: se prueban desde una sesión administrativa con `SET ROLE`, no con conexiones directas. Para comprobaciones de permisos y resultados, consultar `postgresql/sql/exercises.md`, `postgresql/02-sql-roles/README.md` y `postgresql/02-sql-roles/validation.txt`. Las pruebas DML deben revertirse con `ROLLBACK` para mantener la carga original.

## 7. Backup lógico y restauración (VM Rocky Linux)

**Prerrequisito:** la base de datos `tienda` funciona y existen los cuatro recuentos anteriores. Los siguientes comandos **modifican archivos de sistema y habilitan una tarea programada**. Ejecutar solo en la VM del laboratorio.

Crear el directorio de backups y comprobar permisos:

```bash
sudo install -d -o postgres -g postgres -m 0750 /var/lib/pgsql/backups
sudo ls -ld /var/lib/pgsql/backups
```

Comprobar la sintaxis del script, conservar el ejecutable anterior si existe y copiar la versión del repositorio:

```bash
bash -n scripts/backup.sh
sudo test -f /usr/local/sbin/pg-lab-backup && sudo cp -a /usr/local/sbin/pg-lab-backup /usr/local/sbin/pg-lab-backup.bak
sudo install -o root -g root -m 0755 scripts/backup.sh /usr/local/sbin/pg-lab-backup
```

Instalar unidades systemd y habilitar el temporizador:

```bash
sudo install -o root -g root -m 0644 postgresql/03-backups/systemd/pg-lab-backup.service /etc/systemd/system/pg-lab-backup.service
sudo install -o root -g root -m 0644 postgresql/03-backups/systemd/pg-lab-backup.timer /etc/systemd/system/pg-lab-backup.timer
sudo systemctl daemon-reload
sudo systemctl enable --now pg-lab-backup.timer
```

Para probar un backup manual sin esperar al temporizador:

```bash
sudo -u postgres /usr/local/sbin/pg-lab-backup
sudo -u postgres ls -lt /var/lib/pgsql/backups
systemctl list-timers --all pg-lab-backup.timer
```

El script guarda un archivo con el patrón `tienda_FECHA_HORA.dump` en formato custom y valida la lectura del catálogo. **No garantiza por sí solo una restauración válida; por eso se utiliza otra base de datos.**

**Restauración completa de prueba.** Localizar el archivo realmente creado y escribir su ruta completa en la variable `DUMP`. El nombre siguiente es **solo un marcador** que debe sustituirse. Antes, comprobar que `tienda_restore` no exista ni contenga datos que deban conservarse:

```bash
sudo -u postgres ls -lt /var/lib/pgsql/backups
DUMP="/var/lib/pgsql/backups/tienda_FECHA_HORA.dump"
sudo -u postgres pg_restore --list "$DUMP"
sudo -u postgres psql -l
sudo -u postgres createdb tienda_restore
sudo -u postgres pg_restore --no-owner --no-privileges -d tienda_restore "$DUMP"
sudo -u postgres psql -d tienda_restore -c 'SELECT count(*) FROM public.clientes;'
sudo -u postgres psql -d tienda_restore -c 'SELECT count(*) FROM public.pedidos;'
```

La restauración va a `tienda_restore`, **nunca directamente a `tienda`**. `createdb` y `pg_restore` fallarán o necesitarán un procedimiento diferente si la base de datos ya existe o contiene objetos.

**Recuperación selectiva:** crear una segunda base de datos auxiliar vacía `tienda_tabla_rescate` (si no existe) y restaurar únicamente `productos` desde el mismo dump:

```bash
sudo -u postgres createdb tienda_tabla_rescate
sudo -u postgres pg_restore --no-owner --no-privileges -t productos -d tienda_tabla_rescate "$DUMP"
sudo -u postgres psql -d tienda_tabla_rescate -c 'SELECT count(*) FROM public.productos;'
```

`-t productos` **no garantiza recuperar índices, clave primaria y otras dependencias**; verificar la definición con `\d public.productos` dentro de `psql` si se pretende usar la tabla fuera de la práctica. Para comparar datos con `tienda`, exportarlos desde la base de datos auxiliar a un CSV local y utilizar una tabla temporal dentro de una transacción:

```bash
sudo -u postgres psql -d tienda_tabla_rescate -c "\copy (SELECT id, nombre, precio FROM public.productos ORDER BY id) TO '/var/lib/pgsql/backups/productos_rescate.csv' WITH (FORMAT csv, HEADER true)"
sudo -u postgres psql -d tienda
```

**Dentro de esa sesión de `psql`**, ejecutar en orden:

```sql
BEGIN;
CREATE TEMP TABLE productos_rescate (
    id bigint PRIMARY KEY,
    nombre text NOT NULL,
    precio numeric(10,2) NOT NULL
) ON COMMIT DROP;
```

Importar el CSV con el metacomando de `psql`:

```text
\copy productos_rescate (id, nombre, precio) FROM '/var/lib/pgsql/backups/productos_rescate.csv' WITH (FORMAT csv, HEADER true)
```

Comparar filas presentes y valores diferentes:

```sql
SELECT COALESCE(p.id, pr.id) AS id, p.nombre AS nombre_actual,
       pr.nombre AS nombre_backup, p.precio AS precio_actual,
       pr.precio AS precio_backup
FROM public.productos p
FULL JOIN productos_rescate pr ON pr.id = p.id
WHERE p.id IS NULL OR pr.id IS NULL
   OR p.nombre IS DISTINCT FROM pr.nombre
   OR p.precio IS DISTINCT FROM pr.precio
ORDER BY id;
ROLLBACK;
```

Finalmente salir con `\q`. La consulta muestra **solo las diferencias**: si devuelve cero filas, los datos comprobados coinciden, pero eso no demuestra que haya existido una corrupción real. `ROLLBACK` elimina la tabla temporal de esta transacción y descarta cualquier modificación no confirmada. La evidencia resumida está en `postgresql/03-backups/validation.txt`.

Rollback de la instalación del temporizador, si fuera necesario (no elimina los dumps):

```bash
sudo systemctl disable --now pg-lab-backup.timer
```

Consultar `postgresql/03-backups/README.md` para objetivos y `postgresql/03-backups/validation.txt` para los resultados registrados.

## 8. WAL, copia base y recuperación PITR (VM Rocky Linux)

**Práctica de riesgo alto:** cambia la configuración de PostgreSQL, necesita reiniciar el servicio, y durante la restauración **detiene el clúster físico completo**, no solo la base `tienda`. No repetir sobre la instancia actual sin identificar el estado previo, el directorio de datos y un snapshot o resguardo validado. Esta sección resume la práctica realizada. El archivo [`postgresql/04-pitr/README.md`](../postgresql/04-pitr/README.md) complementa la guía con el entorno, las fases de recuperación, las comprobaciones de seguridad y los criterios de validación. No constituye por sí solo un procedimiento ejecutable completo de restauración.

1. **Diagnóstico:** consultar `SHOW wal_level`, `SHOW archive_mode`, `SHOW archive_command`, espacio libre y estadísticas de `pg_stat_archiver`.
2. **Archivado:** preparar `/var/lib/pgsql/wal_archive`, configurar únicamente los parámetros faltantes y comprobar la llegada de un segmento **nuevo** con `pg_switch_wal()`.
3. **Copia física:** crear `/var/lib/pgsql/backups/pitr-base` sin reutilizar un destino con datos. Verificar con `pg_verifybackup` cuando estén disponibles sus dependencias. En la ejecución documentada, la comprobación de archivos y checksums se realizó correctamente con `--no-parse-wal`; la verificación automática adicional de WAL no se completó.
4. **Punto objetivo:** insertar una fila sintética en `public.pitr_marker`, registrar `clock_timestamp()` **después de confirmar el INSERT** y efectuar `DROP TABLE` más tarde. Verificar los WAL disponibles antes de continuar.
5. **Recuperación:** solo después de respaldar el estado original, detener PostgreSQL, colocar la copia base en el directorio de datos y configurar `restore_command`, `recovery_target_time` y `recovery.signal`.
6. **Pausa y diagnóstico:** comprobar `pg_is_in_recovery()`, `pg_get_wal_replay_pause_state()` y los logs reales de PostgreSQL. **No exigir que `TABLE pitr_marker` responda durante la pausa:** un `AccessExclusiveLock` reproducido desde WAL puede impedir la lectura.
7. **Finalización controlada:** si los logs confirman el objetivo correcto y existe un retorno viable, ejecutar `pg_wal_replay_resume()`, comprobar que `pg_is_in_recovery()` devuelve `f` y **solo entonces** consultar el registro recuperado.
8. **Retorno:** conservar la evidencia del clúster recuperado y devolver el PGDATA original previamente resguardado mediante un intercambio controlado de directorios, con PostgreSQL detenido. Validar después el servicio, las bases de datos y la ausencia de `pitr_marker`. El snapshot de VirtualBox queda como alternativa de reversión, previa comprobación de su estado y de los cambios que podrían perderse.

## 9. Docker Compose y construcción de imagen propia (Ubuntu/WSL2)

**Desde la copia del repositorio en Ubuntu/WSL2**, comprobar que Docker Desktop está arrancado e integrado con esa distribución:

```bash
docker version
docker compose version
```

Crear **localmente** `docker/.env` (el repositorio lo excluye de Git). El siguiente valor es un **marcador, no una contraseña utilizable**; sustituirlo por una contraseña propia con el editor, sin publicarla ni escribir el secreto en el historial de comandos:

```bash
umask 077
printf 'POSTGRES_PASSWORD=CAMBIAR_ESTA_CONTRASENA\n' > docker/.env
vi docker/.env
chmod 600 docker/.env
```

**Compose principal** (puerto local `15432`):

```bash
cd docker
docker compose config --quiet
docker compose up -d
docker compose ps
docker exec db_postgres_tienda psql -U postgres -d tienda -c 'SELECT count(*) FROM clientes;'
```

Los SQL se ejecutan **solo al inicializar por primera vez un volumen vacío**. Para comprobar persistencia:

```bash
docker compose stop
docker compose start
docker compose ps
```

**Imagen propia** (desde el directorio `docker/image`; Compose independiente y puerto local `15433`):

```bash
cd image
docker compose --env-file ../.env -f docker-compose.yml config --quiet
docker compose --env-file ../.env -f docker-compose.yml build db_postgres_tienda_imagen
docker compose --env-file ../.env -f docker-compose.yml up -d --no-build
docker exec db_postgres_tienda_imagen psql -U postgres -d tienda -c 'SELECT count(*) FROM productos;'
```

En estos comandos se parte de `docker/` después de iniciar el Compose principal; si se abre otra terminal, ir explícitamente a `docker/image/`. El volumen y los puertos son **distintos** a los del Compose principal. Evidencias: `docs/docker-validation.md` y `docs/docker-image-validation.md`.

## 10. GitHub Actions y publicación

El repositorio contiene dos flujos en `.github/workflows/`:

- `validate.yml`: estructura, cambios preparados y sintaxis Bash con `scripts/validate-repository.sh`.
- `postgresql-tests.yml`: servidor PostgreSQL efímero, carga SQL, consultas y comprobación de recuentos.

Tras un `git push`, consultar los resultados en la pestaña **Actions** del repositorio. Una ejecución correcta de CI **no valida la VM Rocky Linux, los timers systemd ni una restauración real**.

Antes de preparar una publicación, desde la raíz de cualquier clon:

```bash
git status --short
bash scripts/validate-repository.sh
git diff --check
git diff --cached
```

Publicar únicamente archivos revisados. **No incluir:** `docker/.env`, claves privadas, dumps, directorios de datos, WAL, snapshots ni CSV con datos sensibles. La guía de flujo Git es `docs/repository-workflow.md`.

## 11. Comprobaciones finales y limitaciones

Los bloques 01 a 04 se consideran completados cuando:

- PostgreSQL nativo está instalado y operativo en `pg-primary`.
- La base de datos `tienda` contiene los recuentos esperados.
- Los roles y permisos funcionan según lo documentado.
- El backup lógico se ha restaurado correctamente en bases auxiliares.
- El archivado WAL y la recuperación PITR han sido validados.
- El retorno al `PGDATA` original se ha comprobado sin pérdida de los datos principales del laboratorio.

Los contenidos relativos a Docker Compose y GitHub Actions se validan por separado mediante sus propias evidencias y ejecuciones de CI.

**Referencias:** [PostgreSQL 18](https://www.postgresql.org/docs/18/), [Rocky Linux](https://docs.rockylinux.org/), [Docker Compose](https://docs.docker.com/compose/), [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html).
