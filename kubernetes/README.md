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

## 6. Comprobaciones y criterios de aceptación

- **K1:** clúster `infraestructura-lab-kubernetes` y nodo `Ready`; API publicada en `127.0.0.1:34567`.
- **K2:** Deployment con `2/2` réplicas disponibles, dos Pods `Running` sin reinicios, Service `ClusterIP` y respuesta `HTTP 200 OK` por `port-forward`.
- **K3:** capturar estado sano, fallo controlado, orden de reversión y estado recuperado. Un despliegue final sano no demuestra por sí solo que se haya ejecutado `rollout undo`.

Los resultados obtenidos se detallan en `validation.txt`.

## 7. Incidencias y limitaciones

Comprobar puertos ocupados y excluidos antes de crear el clúster. Si el puerto de referencia no está disponible, elegir otro verificado y ajustar `apiServerPort` antes de la creación. Los incidentes observados y sus resultados se conservan en `troubleshooting.md`.

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
