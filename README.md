# Laboratorio de Sistemas, Bases de Datos y Automatización

Laboratorio técnico orientado a la administración de sistemas Linux, bases de datos,
redes, contenedores, automatización y prácticas DevOps.

## Objetivo

Desarrollar un entorno práctico y reproducible para instalar, configurar, administrar,
asegurar y supervisar servicios e infraestructuras.

El proyecto parte de PostgreSQL y Rocky Linux, e incorpora progresivamente Docker, GitHub Actions,
Ansible, Oracle Database Free y Kubernetes.

Cada bloque combina configuraciones, scripts, procedimientos técnicos y evidencias de validación.

## Entorno de trabajo

- VirtualBox
- Rocky Linux 9
- PostgreSQL
- Ansible Core
- Docker y Docker Compose.
- WSL2.
- GitHub Actions.
- Oracle Database Free.
- Kubernetes con kind.

## Estado

| Apartado  | Estado |
|---|---|
| Red y SSH | OK |
| Preparación de Rocky Linux | OK |
| Instalación de PostgreSQL | OK |
| SQL, roles y permisos | OK |
| Backup y restore | OK |
| PITR | Pendiente |
| Rendimiento | Pendiente |
| Monitorización y troubleshooting | Pendiente |
| Replicación | Pendiente |
| Ansible | Pendiente |
| Docker Compose y CI | OK |
| Oracle Database Free | Pendiente |
| Kubernetes | Pendiente |

## Guía de reproducción

Para preparar un entorno nuevo y repetir las prácticas ya
implementadas, consulta la [guía pública de reproducción](docs/guia-reproduccion.md).

## Alcance

Consulta `docs/scope.md`.

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
