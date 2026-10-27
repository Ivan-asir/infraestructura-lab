# Kubernetes con kind — aplicación web de laboratorio

## 1. Objetivo y alcance

Crear un clúster local con `kind` y estudiar Deployment, Service, probes, escalado, ConfigMap y recuperación de una incidencia controlada.

## 2. Entorno y requisitos

- Ubuntu/WSL2 con Docker Desktop.
- Clúster: `infraestructura-lab-kubernetes`.
- Contexto: `kind-infraestructura-lab-kubernetes`.
- API: `127.0.0.1:34567` (puerto fijo tras conflicto en `34077`).
- Namespace de la aplicación: `web-lab`.

## 3. Estructura de archivos

- `web-lab.yml`: manifiestos de la aplicación web.
- `validation.txt`: evidencia estructurada.
- `troubleshooting.md`: incidencia de readiness, evidencias y reversión.
- Configuración local de creación del clúster: `$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml` (no confundir con el manifiesto versionado).

## 4. Preparación

Verificar Docker, `kind get clusters`, `kubectl config get-contexts` y la disponibilidad del puerto API. No recrear el clúster cuando ya existe.

## 5. Procedimiento de ejecución

Configuración local de `kind` utilizada:

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
- **K3:** el historial conserva las revisiones 2 y 3, la revisión 3 figura disponible y el servicio responde.

Los resultados obtenidos se detallan en `validation.txt`.

## 7. Incidencias y limitaciones

El intento inicial con puerto aleatorio `34077` falló por una exclusión Windows que incluía `34018–34117`. El clúster se creó correctamente usando `34567`.

## 8. Reversión y recuperación

Restaurar la configuración de la aplicación y documentar el estado previo y posterior. No eliminar el clúster ni reiniciar Docker Desktop automáticamente; cualquier parada puede afectar otros servicios.

## 9. Seguridad

Mantener la API en loopback; no publicar kubeconfig, tokens, certificados ni secretos. Verificar `--context` en comandos con cambios.

## 10. Estado y evidencias

- **K1:** VALIDADO. El control-plane alcanzó `Ready` después de 16 segundos.
- **K2:** VALIDADO. Deployment `2/2`, dos Pods `Running`/`Ready`, respuesta HTTP `200 OK` y `rollout status` correcto.
- **K3:** el despliegue final en revisión 3 está operativo.
- **Evidencias:** `validation.txt`.
- **Incidencias:** `troubleshooting.md`.