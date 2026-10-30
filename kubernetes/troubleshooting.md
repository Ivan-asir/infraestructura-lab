# Kubernetes — incidencias y recuperación

## 1. Síntoma y alcance

- Incidencia inicial: `kind create cluster` falló al publicar el puerto `34077` en Docker Desktop.
- K3 (readiness): ruta `/ruta-inexistente-k3`, nuevo Pod `0/1 Ready` y fallo HTTP `404`, conservando disponibles las dos réplicas anteriores.

## 2. Entorno y evidencias previas

- Windows 11 + Ubuntu/WSL2, Docker Desktop 4.97.0, Engine 29.9.2, contexto Docker `default`.
- Windows reservaba `34018–34117`, que incluye `34077`.
- Otros servicios Docker y volúmenes: conservarlos; inventariarlos por separado si se prevén cambios.

## 3. Diagnóstico

Windows PowerShell (consulta):

```powershell
Get-NetTCPConnection -LocalPort 34077 -ErrorAction SilentlyContinue
netsh interface ipv4 show excludedportrange protocol=tcp
```

Ubuntu/WSL2 (consulta):

```bash
kind get clusters
docker ps -a --filter 'name=infraestructura-lab-kubernetes'
```

En K3, el evento `Warning Unhealthy` confirmó el fallo de la sonda de readiness con HTTP `404`.

## 4. Corrección aplicada

Configurar la API en `127.0.0.1:34567` mediante `$HOME/.cache/infraestructura-lab/kubernetes/kind-config.yaml`. La nueva creación finalizó con `Ready after 16s`.

En K3 se ejecutó `kubectl rollout undo deployment/web-lab` sobre el contexto y namespace previstos, recuperando la revisión anterior.

## 5. Validación posterior

- `kind get clusters`: infraestructura-lab-kubernetes.
- Publicación de API: `127.0.0.1:34567`.
- Nodo de control: `Ready`, versión `v1.37.0`.
- Deployment `web-lab`: 2/2 disponibles; dos Pods `Running`, 0 reinicios.
- Service `web-lab`: `ClusterIP`, puerto 80/TCP.
- `rollout history`: revisiones 2 y 3; `describe`: revisión 3 y condiciones `Available=True`, `Progressing=True`.
- `rollout status`: `successfully rolled out`.
- HTTP local por `port-forward`: `200 OK`, con contenido de la ConfigMap.
- Eventos del namespace: ninguno registrado al consultar.

Estas comprobaciones acreditan el estado operativo **posterior**.

En la nueva comprobación de K3, el Deployment recuperó `2/2`, la sonda volvió a `/` y `curl` devolvió HTTP `200 OK`.

## 6. Reversión y recuperación

No se modificaron las reservas de Windows ni se eliminó el clúster. En K3 se ejecutó `rollout undo` y se confirmó la recuperación. Kubernetes mostró una advertencia sobre `last-applied-configuration`, sin impedir el rollback.

## 7. Estado y pendientes

- Puerto `34567`: clúster creado satisfactoriamente.
- K2: VALIDADO; dos réplicas y HTTP `200 OK`.
- K3: incidencia de readiness y recuperación mediante rollback VALIDADAS.
