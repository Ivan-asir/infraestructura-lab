# Kubernetes con kind — aplicación web de laboratorio

## 1. Objetivo y alcance

Crear un clúster local con `kind` y estudiar Deployment, Service, probes, escalado, ConfigMap y recuperación de una incidencia controlada.

## 2. Entorno y requisitos

- Ubuntu/WSL2 con Docker Desktop.
- Clúster: `infraestructura-lab-kubernetes`.
- Contexto: `kind-infraestructura-lab-kubernetes`.
- API de referencia: `127.0.0.1:34567`; comprobar disponibilidad y exclusiones de Windows antes de crear el clúster.
- Namespace de la aplicación: `web-lab`.

## 3. Estructura de archivos

- `web-lab.yml`: manifiestos de la aplicación web.
- `validation.txt`: evidencia estructurada.
- `troubleshooting.md`: incidencia de readiness, evidencias y reversión.
- Configuración local de creación del clúster: `$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml` (no confundir con el manifiesto versionado).

## 4. Preparación

Verificar Docker, `kind get clusters`, `kubectl config get-contexts` y la disponibilidad del puerto API. No recrear el clúster cuando ya existe.

## 5. Procedimiento de ejecución

Configuración local de referencia para crear el clúster, solo si no existe:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 34567
nodes:
  - role: control-plane
```

Antes de cada `kubectl apply`, verificar explícitamente `--context kind-infraestructura-lab-kubernetes` y namespace.

### Cliente interno DNS/Service

**Alcance del acceso local con `port-forward`:** selecciona un Pod mediante el Service y abre un túnel a ese Pod. El HTTP 200 demuestra acceso local a la aplicación; no prueba por sí solo DNS, ClusterIP ni reparto entre réplicas.

**Prueba interna de DNS y Service (Ubuntu/WSL2, usuario habitual).** Crea un Pod cliente desechable solo en el contexto y namespace del ejercicio. Necesita acceso al registro para descargar `busybox:1.37.0`; registra el identificador de imagen efectivo. Antes, comprueba que el nombre esté libre:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab get pod web-lab-http-check --ignore-not-found
```

Continúa únicamente si la consulta termina correctamente y no muestra ningún Pod. Si falla la API, detente; si existe el Pod, identifícalo y no lo sobrescribas. Cambio:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab run web-lab-http-check \
  --image=busybox:1.37.0 --restart=Never --command -- \
  sh -c 'nslookup web-lab.web-lab.svc.cluster.local && wget -T 10 -S -O - http://web-lab.web-lab.svc.cluster.local/'
```

Validación; si `wait` falla, conserva el error y continúa únicamente con el diagnóstico de este Pod:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab wait \
  --for=jsonpath='{.status.phase}'=Succeeded pod/web-lab-http-check --timeout=120s
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab logs web-lab-http-check
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab get pod web-lab-http-check \
  -o jsonpath='{.status.phase}{"\n"}{.status.containerStatuses[0].state.terminated.exitCode}{"\n"}{.status.containerStatuses[0].imageID}{"\n"}'
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab get endpointslices \
  -l kubernetes.io/service-name=web-lab -o yaml
```

**Aceptación:** resolución del nombre, respuesta HTTP 200 con el texto de la página, cliente `Succeeded` con código 0 y endpoints listos. Esta prueba confirma un recorrido interno DNS/Service/aplicación, no distribución uniforme entre réplicas. Si falla, consulta `describe pod/web-lab-http-check`; distingue descarga, DNS y conexión HTTP antes de modificar la aplicación. Conserva resultados y el identificador de imagen en la evidencia.

**Limpieza deliberada:** solo después de guardar los resultados, elimina exclusivamente el cliente creado para esta prueba:

```bash
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab delete pod web-lab-http-check
kubectl --context kind-infraestructura-lab-kubernetes -n web-lab get pod web-lab-http-check --ignore-not-found
```

La segunda consulta debe terminar sin mostrar el cliente. No elimina el Service ni las réplicas de la aplicación.

## 6. Comprobaciones y criterios de aceptación

- **K1:** clúster `infraestructura-lab-kubernetes` y nodo `Ready`; API publicada en `127.0.0.1:34567`.
- **K2:** Deployment con `2/2` réplicas disponibles, dos Pods `Running` sin reinicios, Service `ClusterIP` y respuesta `HTTP 200 OK` por `port-forward`.
- **K3:** capturar estado sano, fallo controlado, orden de reversión y estado recuperado. Un despliegue final sano no demuestra por sí solo que se haya ejecutado `rollout undo`.
- **Acceso interno DNS/Service:** el Pod cliente resuelve `web-lab.web-lab.svc.cluster.local`, recibe HTTP 200 con la página del laboratorio y termina en `Succeeded` con código 0; EndpointSlices contiene endpoints listos. Esta prueba es independiente del túnel local y no demuestra distribución uniforme entre réplicas.

Los resultados obtenidos se detallan en `validation.txt`.

## 7. Incidencias y limitaciones

Comprobar puertos ocupados y excluidos antes de crear el clúster. Si el puerto de referencia no está disponible, elegir otro verificado y ajustar `apiServerPort` antes de la creación. Los incidentes observados y sus resultados se conservan en `troubleshooting.md`.

Un HTTP 200 por `port-forward` no acredita el acceso DNS/ClusterIP desde otro Pod. Hasta ejecutar el cliente interno, ese alcance permanece PENDIENTE. Si el cliente falla, distinguir descarga de imagen, resolución DNS y conectividad HTTP mediante sus logs, estado y eventos antes de modificar la aplicación.

## 8. Reversión y recuperación

Restaurar la configuración de la aplicación y documentar el estado previo y posterior. No eliminar el clúster ni reiniciar Docker Desktop automáticamente; cualquier parada puede afectar otros servicios.

## 9. Seguridad

Mantener la API en loopback; no publicar kubeconfig, tokens, certificados ni secretos. Verificar `--context` en comandos con cambios.

## 10. Estado y evidencias

- **K1:** VALIDADO. El control-plane alcanzó `Ready` después de 16 segundos.
- **K2:** VALIDADO. Deployment `2/2`, dos Pods `Running`/`Ready`, respuesta HTTP `200 OK` y `rollout status` correcto.
- **K3:** VALIDADO. Fallo controlado de readiness HTTP `404`, recuperación mediante `rollout undo`, Deployment `2/2` y respuesta HTTP `200 OK` posterior.
- **Evidencias:** `validation.txt`.
- **Incidencias:** `troubleshooting.md`.
- **Acceso interno DNS/Service:** VALIDADO en la ejecución adicional de `validation.txt` con resolución DNS, HTTP 200, cliente `Succeeded`/código 0 y endpoints listos.
