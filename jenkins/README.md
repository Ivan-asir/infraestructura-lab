# Jenkins: persistencia de claves SSH del agente

El proyecto Compose `infraestructura-lab-jenkins` ejecuta `jenkins_controller`,
`jenkins_agent` y `jenkins_postgres_ci` dentro de la red `ci`.

## Identidad SSH del agente

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

## Comprobaciones sin cambios

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

Para **probar** la persistencia, anota la huella, confirma que no hay builds en
curso y, durante una ventana de mantenimiento, recrea únicamente el agente:

```bash
docker compose up -d --no-deps --no-build --force-recreate jenkins_agent
```

Después repite la consulta de la huella y comprueba que sigue siendo idéntica,
que el nodo vuelve a estar `ONLINE` y que un build termina en `SUCCESS`.
No documentes el resultado como validado si no has realizado esta prueba.

## Seguridad y recuperación

- **No publicar** `.env`, claves privadas ni contenido de volúmenes Docker.
- Conservar `jenkins_home`, `jenkins_pg_ci_data` y `jenkins_agent_ssh_host`.
- `docker compose stop`, `start` y `down` sin `-v` conservan esos volúmenes.
- **No ejecutar** `docker compose down -v`, `docker volume rm` o
  `docker volume prune` para solucionar problemas de autenticación.
- Si falla la conexión, revisar `docker compose logs --tail=60 jenkins_agent`
  y **Manage Jenkins → Nodes → jenkins_agent → Log** antes de cambiar claves.

Registra la huella y la prueba de persistencia (si se realizó) en
`jenkins/validation.txt`, sin guardar claves privadas ni contraseñas.