# Jenkins — incidencia de identidad SSH del agente

## 1. Síntoma y alcance

Tras recrear el agente SSH, Jenkins puede rechazar la conexión si cambia la clave de host anunciada por el servidor del agente.

## 2. Entorno y evidencias previas

Proyecto Compose `infraestructura-lab-jenkins`, servicios `jenkins_controller`, `jenkins_agent` y `jenkins_postgres_ci`; volumen lógico `jenkins_agent_ssh_host` montado en `/etc/ssh`.

## 3. Diagnóstico (sin cambios)

Desde `jenkins/` en Ubuntu/WSL2:

```bash
docker compose config --quiet
docker compose ps
docker inspect jenkins_agent --format '{{range .Mounts}}{{if eq .Destination "/etc/ssh"}}{{.Name}}{{end}}{{end}}'
docker compose exec -T jenkins_agent ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Si el agente no está en marcha, no ejecutar `exec`: registrar ese estado primero.

## 4. Corrección documentada

Persistir la identidad SSH del servidor del agente bajo `/etc/ssh` usando el volumen Compose y configurar la clave pública efectiva en la estrategia de verificación manual del nodo Jenkins. No confundirla con las credenciales cliente.

## 5. Validación posterior

`jenkins/validation.txt` registra históricamente `ONLINE`, pipeline `SUCCESS` y huella coincidente tras recreación. Para revalidar en el estado actual, comprobar fecha, agente y ejecución real; no volver a recrear servicios sin ventana de mantenimiento.

## 6. Reversión y recuperación

Conservar `jenkins_home`, `jenkins_pg_ci_data` y `jenkins_agent_ssh_host`. No usar `down -v`, `volume prune` ni regenerar claves automáticamente.

## 7. Estado y pendientes

Validación correcta.
