# Alcance actual del laboratorio

Este repositorio contiene las prácticas implementadas y documentadas
hasta la fecha. Los bloques futuros se incorporarán progresivamente
cuando se hayan realizado y validado.

## Sistemas y redes

- Preparación de Rocky Linux en VirtualBox.
- Configuración de red NAT y Host-only.
- Acceso SSH y comprobaciones básicas de seguridad.
- Servicios systemd, firewalld y SELinux.

## PostgreSQL

- Instalación y configuración de PostgreSQL 18.
- Creación de bases de datos, esquemas y roles.
- Consultas SQL, agregaciones, JOIN y CTE.
- Privilegios y pruebas con transacciones.
- Backup lógico y restauración completa y selectiva.
- Archivado WAL, copia base y recuperación PITR.

## Contenedores

- PostgreSQL con Docker Compose.
- Persistencia mediante volúmenes Docker.
- Construcción y despliegue de una imagen propia.
- Independencia entre los entornos de contenedores y la VM.

## Integración continua

- Validación del repositorio mediante GitHub Actions.
- Ejecución automatizada de pruebas SQL.
- Comprobación de los recuentos de datos de prueba.

## Evidencias

Cada práctica conserva documentación técnica y resultados reales
de validación. Las evidencias `validation.txt` siguen el formato
definido en `docs/formato-validaciones.md`.

Las tecnologías y acciones todavía no ejecutadas se incorporarán
al repositorio cuando corresponda.
