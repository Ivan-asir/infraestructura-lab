# Validación de la imagen PostgreSQL personalizada con Docker Compose

## 1) Objetivo y alcance

Construir una imagen propia de PostgreSQL 18 que incorpore los scripts `sql/schema.sql` y `sql/seed.sql`, desplegarla mediante `docker/image/compose.yaml` y demostrar que funciona sin sustituir el contenedor principal `db_postgres_tienda`.

La imagen contiene **scripts de inicialización**, no una base de datos ya cargada ni una copia de seguridad. Los scripts se procesan únicamente al inicializar un directorio de datos vacío.

## 2) Entorno de la prueba

| Elemento | Resultado obtenido |
|---|---|
| Sistema utilizado | Ubuntu / WSL2 |
| Docker Engine | 29.9.1 |
| Docker Compose | 5.6.0 |
| SQL de esquema y carga presentes | Sí: ambos archivos no vacíos |
| Archivo de variables `docker/.env` presente e ignorado por Git | Sí: archivo presente e ignorado por Git |

## 3) Construcción de la imagen

| Elemento o comprobación | Configuración esperada | Resultado obtenido |
|---|---|---|
| Dockerfile | `docker/image/Dockerfile` | Presente |
| Archivo Compose | `docker/image/docker-compose.yaml` | Presente |
| Validación de Compose | Sin errores | Correcto (código 0) |
| Servicio declarado | `db_postgres_tienda_imagen` | `db_postgres_tienda_imagen` |
| Imagen base | `postgres:18` | Revisar `FROM` en el Dockerfile |
| Imagen personalizada | `postgresql-tienda:lab` | Imagen existente |
| Identificador de imagen | Identificador `sha256:...` | `sha256:15f79b8c75cf5cb13a5634c997083de6ab1142f09841e26d7ce0061089d6fe7c` |
| Construcción mediante `docker compose build` | Terminación sin errores | Construcción correcta |
| Scripts SQL incluidos en el contenedor | Ambos disponibles | Ambos scripts presentes |

## 4) Despliegue, conectividad y almacenamiento

| Elemento | Resultado esperado | Resultado obtenido |
|---|---|---|
| Proyecto Compose | `tienda-imagen-lab` | Declarado en `docker/image/docker-compose.yaml` |
| Servicio y contenedor | `db_postgres_tienda_imagen` | running |
| Imagen utilizada por el contenedor | `postgresql-tienda:lab` | `postgresql-tienda:lab` |
| Healthcheck | `healthy` | healthy |
| Puerto publicado | `127.0.0.1:15433` → `5432/tcp` | `127.0.0.1:15433` |
| Volumen de datos | `tienda-imagen-lab_pg_tienda_imagen_data` | `tienda-imagen-lab_pg_tienda_imagen_data` |
| Punto de montaje | `/var/lib/postgresql` | /var/lib/postgresql |
| Versión PostgreSQL | Versión principal 18 | `18.6 (Debian 18.6-1.pgdg13+2)` |

## 5) Inicialización y comprobación de datos

| Tabla | Registros esperados con volumen nuevo | Registros observados |
|---|---:|---:|
| `clientes` | 24 | 24 |
| `productos` | 100 | 100 |
| `pedidos` | 200 | 200 |
| `pedido_items` | 200 | 200 |

| Comprobación | Resultado |
|---|---|
| Resultado conjunto `clientes\|productos\|pedidos\|pedido_items` | `24\|100\|200\|200` |
| Coincidencia con la carga inicial `24\|100\|200\|200` | Coincidente |

## 6) Independencia y persistencia

### 6.1) Aislamiento respecto al Compose principal

| Comprobación | Resultado registrado |
|---|---|
| Identificador del contenedor principal **antes** de comenzar | `20014d30d9484a2affe85255df209b53b439b75bb0d3f9e5eef74b4929670a01` |
| Identificador del contenedor principal **después** | `20014d30d9484a2affe85255df209b53b439b75bb0d3f9e5eef74b4929670a01` |
| Estado actual del contenedor principal | running |
| Comparación de identificadores antes/después | Identificadores coincidentes |

### 6.2) Prueba controlada de `stop/start`

| Evidencia | Antes de `stop` | Después de `start` |
|---|---|---|
| Recuentos `clientes\|productos\|pedidos\|pedido_items` | `24\|100\|200\|200` | `24\|100\|200\|200` |
| Nombre del volumen asociado | `tienda-imagen-lab_pg_tienda_imagen_data` | `tienda-imagen-lab_pg_tienda_imagen_data` |
| Estado de salud | `healthy` | `healthy` |