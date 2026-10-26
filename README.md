# Laboratorio de Sistemas, Bases de Datos y Automatización

## Objetivo

Desarrollar un entorno práctico y reproducible para instalar, configurar, administrar,
asegurar y supervisar servicios e infraestructuras.

El proyecto parte de PostgreSQL y Rocky Linux, e incorpora progresivamente Docker, GitHub Actions,
Ansible, Jenkins, Oracle Database Free y Kubernetes.

Cada bloque combina configuraciones, scripts, procedimientos técnicos y evidencias de validación.

## Entorno de trabajo

- VirtualBox
- Rocky Linux 9
- PostgreSQL
- Jenkins
- Ansible Core
- Docker y Docker Compose.
- WSL2.
- GitHub Actions.
- Oracle Database Free.
- Kubernetes.

## Estado

| Apartado  | Estado |
|---|---|
| Red y SSH | `OK` |
| Preparación de Rocky Linux | `OK` |
| Instalación de PostgreSQL | `OK` |
| SQL, roles y permisos | `OK` |
| Backup y restore | `OK` |
| PITR | `OK` |
| Rendimiento | Pendiente |
| Monitorización y troubleshooting | Pendiente |
| Replicación | Pendiente |
| Docker Compose y CI | `OK` |
| Jenkins | Pendiente |
| Ansible | Pendiente |
| Oracle Database Free | Pendiente |
| Kubernetes | Pendiente |

## Guía de ejecución

Para preparar un entorno nuevo y repetir las prácticas ya
implementadas, consultar la [guía de ejecución](docs/guia-ejecucion.md).

## Alcance

Consultar `docs/scope.md`.

## Validación del repositorio

Antes de cada commit se puede ejecutar:

```bash
bash scripts/validate-repository.sh
```

La revisión final de lo preparado se realiza siempre con `git diff --cached`.

## Seguridad

No se publican contraseñas, claves privadas, `.pgpass`, ficheros Vault reales,
dumps, WAL, discos de máquinas virtuales ni datos ajenos al laboratorio.

## Aviso

Este repositorio documenta un laboratorio de práctica. No representa una
configuración preparada para producción.
