# Laboratorio de Sistemas, Bases de Datos y Automatización

## Objetivo

Desarrollar un entorno práctico y reproducible para instalar, configurar, administrar,
asegurar y supervisar servicios e infraestructuras.

El proyecto parte de PostgreSQL y Rocky Linux, e incorpora progresivamente Docker, GitHub Actions,
Ansible, Jenkins, Oracle Database Free y Kubernetes.

Cada bloque combina configuraciones, scripts, procedimientos técnicos y evidencias de validación.

## Organización del repositorio

Las prácticas de PostgreSQL se agrupan en `postgresql/` y se
numeran según su orden de ejecución:

- `postgresql/01-installation/`: instalación y validación inicial.
- `postgresql/02-sql-roles/`: SQL, roles y permisos.
- `postgresql/03-backups/`: backup lógico y restauración.
- `postgresql/04-pitr/`: archivado WAL y recuperación PITR.
- `postgresql/05-performance/`: comparación de planes y rendimiento.
- `postgresql/sql/`: esquema, datos y ejercicios SQL compartidos.

El resto de tecnologías mantiene directorios independientes, por ejemplo:

- `docker/`: contenedores y construcción de imágenes.
- `kubernetes/`: clúster `kind`, aplicación Nginx y diagnóstico.
- `jenkins/`: CI autogestionada y agentes.
- `.github/workflows/`: integración continua en GitHub Actions.
- `scripts/`: scripts reutilizables.
- `docs/`: documentación general y evidencias transversales.

La numeración identifica las prácticas dentro de PostgreSQL;
no representa una numeración global de todas las tecnologías.

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

| Apartado                                    | Estado    |
| ------------------------------------------- | --------- |
| Red y SSH                                   | `OK`    |
| Preparación de Rocky Linux                 | `OK`    |
| Instalación de PostgreSQL                  | `OK`    |
| SQL, roles y permisos                       | `OK`    |
| Backup y restore                            | `OK`    |
| PITR                                        | `OK`    |
| Rendimiento                                 | `OK` |
| Monitorización y troubleshooting           | Pendiente |
| Replicación                                | Pendiente |
| Docker Compose y CI                         | `OK`    |
| Jenkins                                     | `OK`    |
| Ansible                                     | Pendiente |
| Oracle Database Free                        | Pendiente |
| Kubernetes (creación de clúster `kind`) | `OK`    |
| Kubernetes (Deployment y Service) | `OK` |
| Kubernetes (K3: fallo de readiness y rollback) | `OK` |

## Reproducir las prácticas

La [guía pública de ejecución](docs/guia-ejecucion.md) organiza los comandos por bloque y entorno.
Los README de cada módulo detallan su configuración y las evidencias conservadas.
El estado de las prácticas se resume en este README y las evidencias de cada apartado se conservan en sus respectivos `validation.txt`.

## Documentación técnica

Los procedimientos reproducibles, las dependencias y los criterios de aceptación se encuentran en los README de `postgresql/`, `docker/`, `jenkins/` y `kubernetes/`. Las comprobaciones ejecutadas se recogen en los respectivos `validation.txt` y en `docs/`.

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

Este repositorio documenta un laboratorio de práctica. No representa una configuración preparada para producción.