# Red del laboratorio

## Diseño

La VM `pg-primary` utiliza dos adaptadores:

- NAT: salida a Internet, DNF y descargas.
- Host-only: administración por SSH y tráfico privado del laboratorio.

La red Host-only utilizada es `192.168.56.0/24`. No tiene gateway ni DNS. La ruta por defecto debe permanecer en el adaptador NAT.

## Direccionamiento

| Equipo | IP Host-only | Estado |
|---|---|---|
| Anfitrión | `192.168.56.1/24` | Configurado |
| `ansible-control` | `192.168.56.10/24` | Previsto |
| `pg-primary` | `192.168.56.20/24` | Configurado |
| `pg-standby` | `192.168.56.21/24` | Previsto |
| `mariadb-lab` | `192.168.56.30/24` | Opcional |

## Interfaces reales de `pg-primary`

| Función | Interfaz | Perfil NetworkManager |
|---|---|---|
| NAT | `enp0s3` | `enp0s3` |
| Host-only | `enp0s8` | `enp0s8` |

## Validaciones

| Prueba | Resultado |
|---|---|
| Dirección Host-only `192.168.56.20/24` presente | `OK` |
| Ruta por defecto por NAT | `OK` |
| Resolución DNS | `OK` |
| Acceso HTTPS a Internet | `OK` |
| SSH anfitrión → `pg-primary` | `OK` |

## Observaciones

Sin incidencias relevantes.
