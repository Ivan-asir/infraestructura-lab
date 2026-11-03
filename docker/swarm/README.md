# Docker Swarm — servicios, escalado y reversión

## 1. Objetivo y alcance

Práctica de Swarm con un solo manager y Nginx. Permite distinguir servicios y tareas, desplegar una pila, escalar, actualizar gradualmente y revertir. No es una prueba de alta disponibilidad multinodo ni un despliegue de producción.

## 2. Entorno y requisitos

- Ubuntu/WSL2, usuario normal, conectado al Docker Engine Linux de Docker Desktop de laboratorio.
- Docker CLI y Engine operativos; consultar contexto y estado Swarm antes de iniciarlo.
- Acceso para descargar `nginx:stable-alpine`; puerto publicado `18082/TCP` libre y permitido para esta prueba.
- No utilizar un Docker Engine de producción ni reutilizar un Swarm existente sin comprobar sus recursos.

## 3. Estructura de archivos

- `stack.yml`: definición del servicio HTTP sin datos persistentes.
- `README.md`: objetivo, ejecución, verificaciones y precauciones.
- `validation.txt`: resumen de los resultados **reales**.

## 4. Preparación

Revisar `docker context show`, `docker info`, `docker stack ls`, `docker service ls` y el puerto 18082 desde Windows/PowerShell. Detenerse si el contexto no es el esperado o ya existe la pila `swarm_lab`. No capturar ni publicar el token de unión mostrado por `docker swarm init`.

## 5. Procedimiento de ejecución

Ejecutar los pasos siguientes en un motor Docker de laboratorio después de completar el diagnóstico.

```bash
# Desde la raíz del repositorio; ejecuta solo tras los diagnósticos previos.
docker swarm init      # Solo cuando Swarm esté inactive; no publicar el token
docker stack config -c docker/swarm/stack.yml
docker stack deploy -c docker/swarm/stack.yml swarm_lab
docker stack services swarm_lab
docker service ps swarm_lab_web
curl -i http://127.0.0.1:18082/
docker service scale swarm_lab_web=3
docker service scale swarm_lab_web=2
docker service update --env-add LAB_REVISION=v2 swarm_lab_web
docker service inspect --format '{{json .Spec.TaskTemplate.ContainerSpec.Env}}' swarm_lab_web
docker service rollback swarm_lab_web
```

## 6. Comprobaciones y criterios de aceptación

Confirmar manager `Ready`, servicio `swarm_lab_web` en `2/2`, HTTP 200, escalado `3/3` y vuelta a `2/2`, nueva variable en la especificación del servicio y desaparición de esa variable después del rollback. Comprobar estado final en `validation.txt`.

## 7. Incidencias y limitaciones

Un único nodo demuestra gestión de servicios, **no tolerancia a fallos de nodo**. Swarm publica el puerto en las interfaces del motor Docker (no garantiza vinculación solo a loopback). Si el puerto está ocupado o reservado, revisar la configuración antes de desplegar. `docker stack deploy` admite un subconjunto del formato Compose moderno; este laboratorio utiliza un archivo compatible con Stack.

## 8. Reversión y recuperación

`docker service rollback swarm_lab_web` revierte la última actualización del servicio. Para retirar **solo esta pila**, después de verificar que `swarm_lab` es la pila del laboratorio, usar `docker stack rm swarm_lab`. La salida de Swarm del Engine es una operación diferente que no se automatiza ni se ejecuta de forma rutinaria.

## 9. Seguridad

No incluir tokens `docker swarm join`, credenciales, direcciones privadas innecesarias ni logs sensibles en Git. El puerto de demostración puede ser accesible desde otras interfaces; utilizar únicamente un anfitrión de laboratorio con controles de red adecuados. Ninguna prueba necesita volúmenes PostgreSQL ni Jenkins.

## 10. Estado y encias

- **Estado inicial del módulo:** `Swarm=inactive`.
- **Estado durante el laboratorio:** se crea un manager, la pila `swarm_lab` y el servicio `swarm_lab_web`.
- **Resultado definitivo:** registrado en `validation.txt`.
