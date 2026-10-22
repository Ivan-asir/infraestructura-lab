# Validación de Docker y CI

## 1. Entorno

| Componente | Versión |
|---|---|
| Docker Engine | 29.9.1 |
| Docker Compose | v5.6.0 |
| Imagen PostgreSQL | 18 |
| Contenedor | `db_postgres_tienda` |
| Estado | Healthy |

La instancia PostgreSQL se ejecuta en un contenedor independiente de la máquina virtual `pg-primary`.

## 2. Validación de datos

Se ha comprobado la correcta inicialización de la base de datos `tienda` mediante los scripts `sql/schema.sql` y `sql/seed.sql`.

| Tabla | Registros iniciales |
|---|---:|
| `clientes` | 24 |
| `productos` | 100 |
| `pedidos` | 200 |
| `pedido_items` | 200 |

**Resultado:** los recuentos iniciales coinciden con los datos esperados.

## 3. Prueba de persistencia

Se ha insertado un cliente de prueba con el correo `persistencia@example.test` y se ha comprobado su permanencia tras detener y arrancar nuevamente el contenedor mediante `docker compose stop` y `docker compose start`.

**Resultado:** el registro continúa existiendo después del reinicio (1 coincidencia).

Esto confirma la persistencia de los datos almacenados en el volumen Docker utilizado por PostgreSQL.

## 4. Integración continua

Se han ejecutado correctamente los dos workflows configurados en GitHub Actions.

| Workflow | Estado | Evidencia |
|---|---|---|
| `validate.yml` | Correcto | [Ver ejecución](https://github.com/Ivan-asir/infraestructura-lab/actions/runs/39417186845) |
| `postgresql-tests.yml` | Correcto | [Ver ejecución](https://github.com/Ivan-asir/infraestructura-lab/actions/runs/39417186632) |

El primero valida los archivos del repositorio y el segundo comprueba automáticamente la creación del esquema y la carga de datos SQL.

## 5. Conclusión

El laboratorio PostgreSQL en Docker funciona correctamente, los datos persisten tras detener y arrancar el contenedor y ambos workflows de GitHub Actions han finalizado satisfactoriamente.
