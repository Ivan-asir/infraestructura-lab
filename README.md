# Laboratorio PostgreSQL DBA

Laboratorio de administración PostgreSQL sobre Rocky Linux 9.

## Objetivo

Instalación y administración de PostgreSQL, SQL, roles y permisos,
backup y restore, PITR, rendimiento, monitorización, troubleshooting,
replicación física y automatización con Ansible.

El laboratorio se amplía progresivamente hacia Docker,
GitHub Actions, Oracle Database Free y Kubernetes.

El objetivo es relacionar administración DBA, sistemas Linux,
automatización, contenedores y prácticas DevOps mediante
ejercicios reproducibles y evidencias técnicas.

## Entorno empleado

- VirtualBox
- Rocky Linux 9
- PostgreSQL
- Ansible Core

## Tecnologías previstas para ampliación

- Docker y Docker Compose.
- WSL2.
- GitHub Actions.
- Oracle Database Free.
- Kubernetes con kind.

Estas tecnologías se incorporarán progresivamente.
Su inclusión en el alcance no implica que estén instaladas.

## Estado

| Apartado  | Estado |
|---|---|
| Red y SSH | OK |
| Preparación de Rocky Linux | OK |
| Instalación de PostgreSQL | OK |
| SQL, roles y permisos | OK |
| Backup y restore | Pendiente |
| PITR | Pendiente |
| Rendimiento | Pendiente |
| Monitorización y troubleshooting | Pendiente |
| Replicación | Pendiente |
| Ansible | Pendiente |
| Docker Compose y CI | Pendiente |
| Oracle Database Free | Pendiente |
| Kubernetes | Pendiente |

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
