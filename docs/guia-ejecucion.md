# Guía de ejecución del laboratorio de Sistemas, Bases de Datos y Automatización

> Recorrido público de ejecución por bloques. Los comandos se aplican en el entorno indicado y se ejecutan una única vez cuando crean recursos. No incluye evidencias ni la documentación de las pruebas históricas.

## 1. Requisitos y recorrido

El laboratorio original utiliza **Rocky Linux 9.8** en **Oracle VirtualBox**, PostgreSQL **18.6** de AppStream, y un segundo entorno **Windows 11 + Ubuntu/WSL2 + Docker Desktop**. Son **dos instancias distintas** de PostgreSQL: la nativa en la VM y la del contenedor.

- VirtualBox con una VM Rocky Linux 9, usuario administrador con `sudo`, salida a Internet y una interfaz Host-only.
- Git, acceso al repositorio y conectividad SSH a la VM.
- Para el recorrido de contenedores: Docker Desktop con integración WSL2, Docker Compose y espacio para las imágenes y volúmenes.
- Ajustar direcciones IP y nombres de interfaces si el anfitrión utiliza una red diferente. Los valores de este documento corresponden a la red de ejemplo.
- La inicialización, instalación y restauración se plantean para máquinas y bases de datos nuevas; una restauración PITR requiere una copia de la VM.

Orden sugerido:

1. Preparar la VM y la red.
2. Instalar PostgreSQL nativo e inicializar el laboratorio SQL.
3. Aplicar roles y ejecutar consultas.
4. Configurar el backup lógico y probar una restauración aislada.
5. Realizar WAL/PITR **solo en una VM aislada, con punto de retorno verificado**.
6. En otro entorno, iniciar Docker Compose y probar la imagen propia.
7. Desplegar Jenkins con un agente SSH y su pipeline.
8. Crear el clúster Kubernetes y desplegar la aplicación Nginx.

Los archivos de cada módulo describen las dependencias y límites de la práctica. Este recorrido facilita los comandos y no exige generar informes de validación.

## 2. Descargar el repositorio

**En Rocky Linux y, separadamente, en Ubuntu/WSL2 si se realiza Docker:**

```bash
git clone https://github.com/Ivan-asir/infraestructura-lab.git
cd infraestructura-lab
```

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

Los roles `tienda_readonly` y `tienda_readwrite` son `NOLOGIN`: se prueban desde una sesión administrativa con `SET ROLE`, no con conexiones directas. Para comprobaciones de permisos y resultados, consultar `postgresql/sql/exercises.md` y `postgresql/02-sql-roles/README.md`. Las pruebas DML deben revertirse con `ROLLBACK` para mantener la carga original.

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

Finalmente salir con `\q`. La consulta muestra **solo las diferencias**: si devuelve cero filas, los datos comprobados coinciden, pero eso no demuestra que haya existido una corrupción real. `ROLLBACK` elimina la tabla temporal de esta transacción y descarta cualquier modificación no confirmada.

Rollback de la instalación del temporizador, si fuera necesario (no elimina los dumps):

```bash
sudo systemctl disable --now pg-lab-backup.timer
```

Para conocer las particularidades del servicio y las opciones de recuperación, consultar `postgresql/03-backups/README.md`.

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

Crear **localmente** `docker/.env` (ignorado por Git). El ejemplo incluye `POSTGRES_DB=tienda` y `POSTGRES_USER=postgres`; sustituir la contraseña de muestra mediante el editor, sin publicarla:

```bash
umask 077
test ! -e docker/.env && cp docker/.env.example docker/.env
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

En estos comandos se parte de `docker/` después de iniciar el Compose principal; si se abre otra terminal, ir explícitamente a `docker/image/`. El volumen y los puertos son **distintos** a los del Compose principal. Detalles de cada Compose: `docker/README.md` y `docker/image/README.md`.

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

## 11. Jenkins — controlador, agente SSH y PostgreSQL CI (Ubuntu/WSL2)

**Entorno:** terminal Ubuntu/WSL2; directorio raíz del repositorio. Jenkins es un proyecto Compose independiente; no reutiliza la base `tienda` del sistema Rocky ni el volumen del Compose de Docker.

El archivo `jenkins/.env.example` define las variables necesarias, pero sus contraseñas y la clave pública de acceso deben sustituirse localmente. Antes de generar una clave nueva, comprobar si ya existe una identidad destinada a este agente para evitar sobrescribirla. **No publicar la clave privada ni `.env`.**

```bash
cd "$(git rev-parse --show-toplevel)"
mkdir -p "$HOME/.ssh"
test ! -e "$HOME/.ssh/infraestructura-lab-jenkins-agent" && ssh-keygen -t ed25519 -f "$HOME/.ssh/infraestructura-lab-jenkins-agent" -C "jenkins-agent"
cat "$HOME/.ssh/infraestructura-lab-jenkins-agent.pub"
```

Copiar la clave **pública** completa al campo `JENKINS_AGENT_SSH_PUBKEY` del archivo privado `jenkins/.env`, y establecer dos contraseñas locales diferentes para `POSTGRES_PASSWORD` y `CI_PASSWORD`:

```bash
test ! -e jenkins/.env && cp jenkins/.env.example jenkins/.env
chmod 600 jenkins/.env
vi jenkins/.env
cd jenkins
docker compose config --quiet
docker compose build jenkins_agent
docker compose up -d
```

Abrir `http://127.0.0.1:18080` desde el anfitrión. Completar el asistente inicial de Jenkins y crear una cuenta administrativa local. Para un controlador recién creado, la contraseña inicial se obtiene localmente, sin publicarla:

```bash
docker exec jenkins_controller cat /var/jenkins_home/secrets/initialAdminPassword
```

Desde **Manage Jenkins → Credentials**, añadir la clave **privada del cliente** como credencial SSH del nodo (nunca subirla a Git). Desde **Manage Jenkins → Nodes**, crear `jenkins_agent` con 1 ejecutor y etiqueta `jenkins-lab`, acceso SSH al host Docker `jenkins_agent` puerto `22`. Para la verificación manual de identidad del servidor, obtener la clave pública de host una vez que el volumen `jenkins_agent_ssh_host` ya está montado:

```bash
docker compose exec -T jenkins_agent cat /etc/ssh/ssh_host_ed25519_key.pub
```

Configurarla en la estrategia **Manually provided key Verification Strategy** del nodo. Crear un job **Pipeline** cuyo código proceda del repositorio público Git, con ruta de script `jenkins/Jenkinsfile`. Las fases se ejecutan sobre el agente con etiqueta `jenkins-lab`.

## 12. Kubernetes — `kind`, `kubectl` y aplicación web (Ubuntu/WSL2)

**Entorno:** terminal Ubuntu/WSL2 con Docker Desktop e integración WSL2 habilitada; usuario ordinario con acceso a Docker. `sudo` se utiliza únicamente para instalar ejecutables en `/usr/local/bin`. La aplicación utiliza un clúster local, no un servicio cloud.

Este bloque se divide en tres ejercicios. **K1, K2 y K3 son identificadores de prácticas de este repositorio; no son componentes ni comandos propios de Kubernetes.**

| Ejercicio | Qué se realiza | Qué se aprende |
|---|---|---|
| **K1 — Crear el clúster local** | Instalar `kind`, crear el clúster e instalar `kubectl`. | Nodos, plano de control, contexto y API de Kubernetes. |
| **K2 — Desplegar una aplicación** | Aplicar los manifiestos de Nginx y acceder mediante un Service. | Namespace, ConfigMap, Deployment, Pods, Service y sondas de salud. |
| **K3 — Incidencia y recuperación** | Introducir opcionalmente un fallo controlado de readiness y revertir la revisión. | Diagnóstico, reconciliación, historial y `rollout undo`. |

### 12.1. Requisitos previos e instalación de `kind`

**Consulta previa en Ubuntu/WSL2:**

```bash
docker version
docker info --format '{{.ServerVersion}}'
uname -m
command -v kind || true
kind version 2>/dev/null || true
command -v kubectl || true
kubectl version --client 2>/dev/null || true
```

Docker debe responder y la arquitectura de referencia es `x86_64` (`amd64`). Si `kind` ya está instalado, **conservarlo y continuar con 12.2**; no sobrescribir su ejecutable. En otra arquitectura, usar el binario correspondiente de la [distribución oficial de kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

**Solo si `kind` no existe**, preparar las herramientas de descarga que falten:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
```

Descargar la versión de referencia `v0.33.0` de `kind` y su suma de comprobación en un directorio de caché **fuera del repositorio** (instrucciones para `x86_64`):

```bash
mkdir -p "$HOME/.cache/infraestructura-lab/kubernetes"
cd "$HOME/.cache/infraestructura-lab/kubernetes"
curl -fL --retry 3 -o kind-linux-amd64 \
  https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
curl -fL --retry 3 -o kind-linux-amd64.sha256sum \
  https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-amd64.sha256sum
sha256sum --check kind-linux-amd64.sha256sum
```

Continuar **únicamente si** la comprobación devuelve `kind-linux-amd64: OK`. Antes de instalar, comprobar que no se va a reemplazar un ejecutable existente:

```bash
command -v kind || true
ls -l /usr/local/bin/kind 2>/dev/null || true
```

Si no existe un `kind` instalado y el checksum es correcto:

```bash
sudo install -o root -g root -m 0755 kind-linux-amd64 /usr/local/bin/kind
kind version
```

### 12.2. K1 — Crear o reutilizar el clúster local

Antes de crear el clúster, comprobar los recursos Docker y los clústeres existentes:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
kind get clusters
```

Si aparece `infraestructura-lab-kubernetes`, **no volver a crearlo**; pasar a la instalación o comprobación de `kubectl`. La creación consume recursos de Docker Desktop, por lo que conviene no mantener simultáneamente otros entornos pesados sin comprobar la memoria disponible.

La API se publica en `127.0.0.1:34567`. Este puerto resolvió un conflicto previo con un intervalo reservado en Windows. **En PowerShell de Windows** y solo para una instalación nueva, comprobarlo antes de crear el clúster:

```powershell
Get-NetTCPConnection -LocalPort 34567 -ErrorAction SilentlyContinue
netsh interface ipv4 show excludedportrange protocol=tcp
```

Si el puerto está ocupado o reservado, elegir otro puerto libre comprobado y actualizar `apiServerPort` en el archivo de configuración *antes de crear* el clúster. No eliminar reservas de Windows ni exponer la API en todas las interfaces.

**En Ubuntu/WSL2**, consultar si existe una configuración previa:

```bash
mkdir -p "$HOME/.cache/infraestructura-lab/kubernetes"
ls -l "$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml" 2>/dev/null || true
```

Si **no existe**, crear el archivo local `~/.cache/infraestructura-lab/kubernetes/kind-config.yaml`:

```bash
cat > "$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml" <<'YAML'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 34567
nodes:
  - role: control-plane
YAML
```

Si el archivo ya existía, inspeccionar su contenido y **no ejecutar el bloque de escritura anterior**. Crear el clúster **una sola vez**, si el nombre no figura en `kind get clusters`:

```bash
kind create cluster \
  --name infraestructura-lab-kubernetes \
  --config "$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml" \
  --wait 180s
```

Esto crea un nodo Docker con el plano de control y configura el contexto `kind-infraestructura-lab-kubernetes`. Comprobar la publicación de la API:

```bash
kind get clusters
docker port infraestructura-lab-kubernetes-control-plane 6443/tcp
```

### 12.3. Instalar y comprobar `kubectl`

`kubectl` es el cliente que se comunica con la API del clúster. **Si ya está instalado y su versión es compatible, mantenerlo**. Comprueba la instalación existente y la versión del nodo:

```bash
kubectl version --client 2>/dev/null || true
docker exec infraestructura-lab-kubernetes-control-plane kubelet --version
```

La versión menor de `kubectl` debe estar dentro de una versión menor de diferencia respecto al plano de control. Si falta el cliente, descargaremos **la versión del nodo recién creado**, en lugar de elegir sin comprobar la versión estable más reciente.

Solo si `kubectl` no está instalado, ejecutar en Ubuntu/WSL2 (`x86_64`):

```bash
KUBE_VERSION="$(docker exec infraestructura-lab-kubernetes-control-plane kubelet --version | awk '{print $2}')"
printf 'Versión Kubernetes del nodo: %s\n' "$KUBE_VERSION"
printf '%s\n' "$KUBE_VERSION" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'
```

La última orden debe terminar sin error. Si la versión está vacía o tiene un formato inesperado, **no continuar**. Descargar el binario y el checksum de **esa misma versión**:

```bash
cd "$HOME/.cache/infraestructura-lab/kubernetes"
curl -fL --retry 3 -o kubectl \
  "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
curl -fL --retry 3 -o kubectl.sha256 \
  "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl.sha256"
printf '%s  kubectl\n' "$(cat kubectl.sha256)" | sha256sum --check
```

Continuar únicamente si devuelve `kubectl: OK`. Comprobar que el destino de instalación no existe:

```bash
command -v kubectl || true
ls -l /usr/local/bin/kubectl 2>/dev/null || true
```

Si el binario no estaba instalado y la comprobación SHA-256 es correcta:

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

Comprobar el acceso al clúster sin cambiar el contexto global:

```bash
kubectl config get-contexts
kubectl --context kind-infraestructura-lab-kubernetes cluster-info
kubectl --context kind-infraestructura-lab-kubernetes get nodes -o wide
```

Si el contexto no aparece o el nodo no está `Ready`, resolver primero ese problema antes de desplegar recursos. Procedimiento oficial: [instalar `kubectl` en Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).

### 12.4. K2 — Desplegar y acceder a la aplicación

Desde la raíz del repositorio, aplicar `kubernetes/web-lab.yml`. El manifiesto declara Namespace, ConfigMap, Deployment de dos réplicas y Service `ClusterIP`:

```bash
cd "$(git rev-parse --show-toplevel)"
kubectl --context kind-infraestructura-lab-kubernetes apply -f kubernetes/web-lab.yml
```

Consultar el despliegue y esperar a que termine:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  rollout status deployment/web-lab --timeout=180s
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  get deployments,services,pods -o wide
```

En **una terminal de Ubuntu/WSL2**, mantener abierto el acceso temporal al Service:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  port-forward svc/web-lab 18081:80 --address 127.0.0.1
```

En **otra terminal**, abrir la página mediante:

```bash
curl -i --max-time 10 http://127.0.0.1:18081/
```

También se puede abrir `http://127.0.0.1:18081/` en el navegador del equipo. Un `HTTP 200` y la página del laboratorio indican que el Service permite acceder a la aplicación. Para detener únicamente el `port-forward`, pulsar `Ctrl+C` en la primera terminal.

### 12.5. K3 — Incidencia controlada y recuperación (opcional)

**Esta práctica modifica temporalmente el Deployment y puede afectar a sus nuevas réplicas. Ejecutarla solo en un clúster de laboratorio**, nunca sobre una aplicación ajena o de producción. El procedimiento siguiente sirve para reproducir el concepto de K3: no representa una transcripción de los comandos ejecutados históricamente en este repositorio.

Primero comprobar el estado sano y la ruta de readiness actual:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab get deployment,pods
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  get deployment web-lab -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}{"\n"}'
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab rollout history deployment/web-lab
```

**Continuar solo si hay dos réplicas disponibles y la ruta de readiness es `/`.** Inyectar una ruta inexistente para provocar una nueva revisión con Pods no listos:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  patch deployment web-lab --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ruta-inexistente-k3"}]'
```

Examinar el comportamiento sin repetir el cambio:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  rollout status deployment/web-lab --timeout=35s
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  get deployments,replicasets,pods
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  describe deployment/web-lab
```

Que `rollout status` termine por tiempo de espera es **esperable** en este ejercicio. Algunas réplicas anteriores pueden continuar sirviendo la aplicación mientras las nuevas no superan la readiness probe.

**Reversión:** restaurar la revisión anterior del Deployment:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  rollout undo deployment/web-lab
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  rollout status deployment/web-lab --timeout=180s
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  get deployment,pods
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab \
  get deployment web-lab -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}{"\n"}'
```

La ruta de readiness debe volver a `/` y las dos réplicas deben recuperarse. `rollout undo` revierte la **plantilla del Deployment**, no datos externos ni ConfigMaps. Si falla la recuperación, no borrar recursos: conservar `describe` y los eventos para investigar. No eliminar el clúster ni reiniciar Docker Desktop como parte del ejercicio.

## 13. Cierre de una sesión de laboratorio

Los datos de PostgreSQL y Jenkins viven en volúmenes; detener un contenedor no los elimina. Cuando se termine una sesión, se pueden parar los servicios que se estén usando con `docker compose stop` desde el directorio del proyecto correspondiente. **No utilizar** `docker compose down -v`, `docker volume prune` ni `kind delete cluster` como parte de una parada rutinaria.

Para profundizar en una práctica, consultar el README del directorio correspondiente. Este documento es únicamente un recorrido operativo de reproducción.