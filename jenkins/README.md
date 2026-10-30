# Jenkins con controller y agente SSH

## 1. Objetivo y alcance

CI autogestionada: controller, agente SSH y PostgreSQL CI aislado.

## 2. Entorno y requisitos

- Ubuntu/WSL2 con Docker Desktop, Docker Compose y almacenamiento persistente.
- Servicios Compose: `jenkins_controller`, `jenkins_agent`, `jenkins_postgres_ci`.
- Acceso web local: `127.0.0.1:18080`; conexión SSH del agente solo dentro de la red Docker `ci`.

## 3. Estructura de archivos

- `docker-compose.yml`
- `Jenkinsfile`
- `validation.txt`
- `.env.example`
- `agent/Dockerfile`
- `initdb/01-create-ci-role.sh`
- `troubleshooting.md`

## 4. Preparación

Desde `jenkins/`, verificar `docker compose config --quiet`, los contenedores existentes y los volúmenes `jenkins_home`, `jenkins_pg_ci_data` y `jenkins_agent_ssh_host`. Conservar la configuración y las credenciales locales sin publicarlas.

## 5. Procedimiento de ejecución

El proyecto Compose `infraestructura-lab-jenkins` ejecuta `jenkins_controller`,
`jenkins_agent` y `jenkins_postgres_ci` dentro de la red `ci`.

### Variables por servicio

El agente recibe únicamente `JENKINS_AGENT_SSH_PUBKEY`. PostgreSQL CI recibe
`POSTGRES_USER`, `POSTGRES_PASSWORD` y `CI_PASSWORD`. El archivo `.env` privado
sirve para interpolar esos valores; no se inyecta completo en los contenedores.
No publicar su contenido ni la salida de `docker compose config` sin `--quiet`.

El pipeline base descarga el repositorio y ejecuta validaciones estáticas.
PostgreSQL CI es una instancia independiente; el Jenkinsfile base no ejecuta
pruebas SQL ni despliega la aplicación Kubernetes.

### Identidad SSH del agente

El servicio `jenkins_agent` monta el volumen Docker con nombre
`jenkins_agent_ssh_host` en `/etc/ssh`. El volumen se administra mediante
Docker Compose (no utiliza `external: true`) y conserva las claves de host SSH
cuando se recrea el contenedor. Estas claves identifican al **servidor SSH**
ante el controller y **no** son el par de cliente almacenado en las credenciales
Jenkins y `JENKINS_AGENT_SSH_PUBKEY`.

La primera recreación con un volumen vacío puede generar **una clave de host
nueva**, incluso si antes se había recreado el contenedor sin ese montaje.
La identidad definitiva es la obtenida **después** de montar el volumen y
arrancar el agente. Verifica su clave pública en el contenedor y configúrala en
**Manage Jenkins → Nodes → jenkins_agent → Configure → Host Key Verification
Strategy → Manually provided key Verification Strategy**.

## 6. Comprobaciones y criterios de aceptación

La evidencia existente identifica el commit y build probados. Tras modificar el Compose, comprobar de nuevo el agente ONLINE, la misma huella SSH y un pipeline correcto. Registrar esa ejecución por separado.

### Comprobaciones sin cambios

Ejecuta como usuario habitual en Ubuntu/WSL2, desde `jenkins/`:

```bash
docker compose config --quiet
docker compose ps
docker inspect jenkins_agent \
  --format '{{range .Mounts}}{{if eq .Destination "/etc/ssh"}}tipo={{.Type}} volumen={{.Name}} destino={{.Destination}}{{end}}{{end}}'
docker compose exec -T jenkins_agent \
  ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
docker compose exec -T jenkins_agent \
  cat /etc/ssh/ssh_host_ed25519_key.pub
```

Con el agente arrancado, comprobar que no recibe las contraseñas SQL sin imprimir el entorno ni sus valores:

```bash
docker compose exec -T jenkins_agent sh -c \
  'test -z "${POSTGRES_PASSWORD+x}" && test -z "${CI_PASSWORD+x}"'
```

Código de salida esperado: `0`. La comprobación no sustituye la verificación del nodo ni la ejecución del pipeline.

Para **probar** la persistencia, anotar la huella, confirmar que no hay builds en
curso y, durante una ventana de mantenimiento, recrear únicamente el agente:

```bash
docker compose up -d --no-deps --no-build --force-recreate jenkins_agent
```

## 7. Incidencias y limitaciones

La identidad de host del servidor SSH del agente es distinta de la clave cliente de Jenkins. La continuidad tras recreación requiere comparar la misma huella.

## 8. Reversión y recuperación

La recreación del agente puede interrumpir builds; efectuarla solo en una ventana controlada y sin tocar volúmenes de Jenkins ni PostgreSQL CI.

Para detener conservando datos, utilizar `docker compose stop`. `docker compose down` sin `-v` conserva los volúmenes, pero elimina contenedores y redes del proyecto. Si falla la conexión, revisar `docker compose logs --tail=60 jenkins_agent` y el registro del nodo en Jenkins antes de cambiar claves.

## 9. Seguridad

No publicar `.env`, credenciales, claves privadas ni contenido de volúmenes. Conservar `jenkins_home`, `jenkins_pg_ci_data` y `jenkins_agent_ssh_host`. No utilizar `docker compose down -v`, `docker volume rm` ni `docker volume prune` como solución a errores SSH.

## 10. Estado y evidencias

- **Ejecución conservada:** agente `ONLINE`, huella SSH persistente y pipeline `SUCCESS` en build `#2`.
- **Configuración con variables limitadas por servicio:** VALIDADA. Compose correcto, PostgreSQL CI `healthy`, contraseñas SQL ausentes del agente y huella SSH conservada tras recreación.
- **Evidencia:** `validation.txt`; incidencia de identidad SSH en `troubleshooting.md`.