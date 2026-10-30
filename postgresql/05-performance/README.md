# Rendimiento: análisis de planes e índices PostgreSQL

## 1. Objetivo y alcance

Comparar `EXPLAIN (ANALYZE, BUFFERS)` de una consulta sobre `public.eventos` antes y después de crear un índice por `usuario_id`. Como ampliación de la misma práctica, comparar el filtro combinado por `usuario_id` y `fecha` antes y después de crear un índice compuesto.

Se utilizan datos sintéticos de laboratorio. Las mediciones documentan el comportamiento observado en estas ejecuciones; no representan una garantía de rendimiento ni un benchmark de producción.

## 2. Entorno y requisitos

- Máquina: `pg-primary`, Rocky Linux; usuario de operación: `labadmin`.
- Servidor: PostgreSQL **18.6**, servicio `postgresql.service` activo, directorio de datos `/var/lib/pgsql/data`.
- Base de datos histórica: `perf_lab`, tabla `public.eventos` con **200.000** filas y **24** coincidencias para `usuario_id = 1234`. Durante la comprobación existían `eventos_pkey` e `idx_eventos_usuario`, pero no `idx_eventos_usuario_fecha`.
- Base de datos empleada en la repetición: `perf_lab_bench`, creada separadamente y cargada con `setup.sql`; **200.000** filas. Al iniciar las mediciones solo existía `eventos_pkey`.

`setup.sql` usa `random()` y `now()`: los datos de dos cargas independientes no serán idénticos. Comparar siempre el antes y el después **dentro de la misma base de datos y carga**.

## 3. Estructura de archivos

- `README.md`: procedimiento reproducible y alcance de la práctica.
- `setup.sql`: creación de `eventos`, inserción de 200.000 filas y `ANALYZE`.
- `queries.sql`: consultas y DDL de los índices, para ejecución **por fases**.
- `plan-before.txt`: plan histórico íntegro anterior al índice simple.
- `plan-after.txt`: plan histórico íntegro posterior al índice simple.
- `validation.txt`: contexto, resultados medidos (incluidas las repeticiones y el índice compuesto), incidencias y estado final.

## 4. Preparación

**Equipo:** `pg-primary`. **Usuario:** `labadmin`, con acceso autorizado a `sudo -u postgres`. Situarse en la raíz del clon de Rocky y verificar la ruta antes de utilizar archivos relativos:

```bash
cd "$HOME/infraestructura-lab"
git rev-parse --show-toplevel
sudo systemctl is-active postgresql.service
sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d postgres \
  -c "SELECT datname FROM pg_database WHERE datname IN ('perf_lab','perf_lab_bench');"
```

Antes de modificar una base de datos, comprobar sus índices:

```bash
sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d perf_lab_bench \
  -c "SELECT indexname, indexdef FROM pg_indexes
      WHERE schemaname = 'public' AND tablename = 'eventos'
      ORDER BY indexname;"
```

## 5. Procedimiento de ejecución

El siguiente es el **orden reproducible para una base de datos auxiliar nueva**.

1. Comprobar que el nombre elegido para la nueva base de datos está libre; crearla y cargar `setup.sql` una sola vez. Desde la raíz del clon, la redirección de entrada permite que el usuario `labadmin` lea el SQL:

   ```bash
   # Ejemplo solo si perf_lab_bench NO existe.
   sudo -u postgres createdb perf_lab_bench
   sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d perf_lab_bench \
     < postgresql/05-performance/setup.sql
   ```

2. Verificar 200.000 filas y que inicialmente solo exista `eventos_pkey`. Ejecutar cinco veces esta consulta y registrar cada `Execution Time` y su plan:

   ```bash
   sudo -u postgres psql -X -v ON_ERROR_STOP=1 -P pager=off \
     -d perf_lab_bench \
     -c 'EXPLAIN (ANALYZE, BUFFERS)
         SELECT * FROM public.eventos WHERE usuario_id = 1234;'
   ```

3. Crear el índice simple **solo en esa base de datos de ensayo** y actualizar las estadísticas:

   ```bash
   sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d perf_lab_bench \
     -c 'CREATE INDEX idx_eventos_usuario ON public.eventos (usuario_id);
         ANALYZE public.eventos;'
   ```

4. Ejecutar cinco veces la misma consulta del paso 2, con los mismos datos. Comparar planes, tiempos y buffers; calcular la **mediana** de cada grupo de cinco medidas.

5. Antes de crear el índice compuesto, obtener el plan de esta consulta:

   ```bash
   sudo -u postgres psql -X -v ON_ERROR_STOP=1 -P pager=off \
     -d perf_lab_bench \
     -c "EXPLAIN (ANALYZE, BUFFERS)
         SELECT usuario_id, count(*) FROM public.eventos
         WHERE usuario_id = 1234
           AND fecha >= now() - interval '30 days'
         GROUP BY usuario_id;"
   ```

6. Crear el índice compuesto **en la misma base de datos auxiliar**:

   ```bash
   sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d perf_lab_bench \
     -c 'CREATE INDEX idx_eventos_usuario_fecha
         ON public.eventos (usuario_id, fecha);
         ANALYZE public.eventos;'
   ```

7. Ejecutar otra vez la consulta del paso 5 y comprobar el catálogo final de índices. Registrar los resultados de las dos consultas en `validation.txt`.

**Advertencia:** `queries.sql` incluye `CREATE INDEX` y no es idempotente. Leerlo y ejecutar sus operaciones por fases; no usar `psql -f queries.sql` sobre una base de datos ya indexada. `EXPLAIN ANALYZE` ejecuta la consulta, aunque aquí solo se han usado `SELECT`.

## 6. Comprobaciones y criterios de aceptación

En la base de datos `perf_lab_bench`:

| Prueba | Antes | Después |
|---|---|---|
| Consulta por usuario, acceso | `Gather / Parallel Seq Scan` | `Bitmap Heap Scan / Bitmap Index Scan` |
| Consulta por usuario, filas reales | 27 | 27 |
| Consulta por usuario, mediana de 5 ejecuciones | 19.055 ms | 0.180 ms |
| Consulta por usuario y fecha, acceso | `Bitmap Heap Scan` con índice simple | `Index Only Scan` con índice compuesto |
| Consulta por usuario y fecha, tiempo de una ejecución | 0.573 ms | 0.083 ms |
| Consulta por usuario y fecha, filas que cumplen ambos filtros | 4 | 4 |

Para el índice compuesto, el plan posterior mostró `Heap Fetches: 0`. La base de datos auxiliar terminó con `eventos_pkey`, `idx_eventos_usuario` e `idx_eventos_usuario_fecha`.

Los tiempos individuales, los buffers y las limitaciones figuran en `validation.txt`. Los dos planes históricos se conservan íntegros en `plan-before.txt` y `plan-after.txt`; **no son las cinco ejecuciones de esta sesión nueva**.

**Criterio de aceptación:** comparar la misma consulta sobre la misma carga, demostrar el cambio de plan tras los índices, documentar las medidas reales, comprobar los índices finales y separar lo histórico de la nueva ejecución.

## 7. Incidencias y limitaciones

- En la ejecución original de `perf_lab` no constan fecha, versión y host en los planes históricos.
- Cinco medidas por fase son una muestra pequeña; para la consulta del índice compuesto solo se tomó una medida por fase. Los resultados dependen de caché, carga del sistema, estadísticas y datos generados.
- Los buffers indicados por nodos padres e hijos no se suman como si fueran independientes.

## 8. Reversión y recuperación

**No se ejecutó `DROP INDEX`, `DROP TABLE` ni `DROP DATABASE`**. La base de datos original `perf_lab` se mantuvo sin cambios derivados de la nueva comparación; la auxiliar `perf_lab_bench` se conservó con ambos índices.

## 9. Seguridad

Práctica exclusiva de laboratorio con datos sintéticos. `EXPLAIN (ANALYZE, BUFFERS)` ejecuta la sentencia y puede consumir CPU y E/S. No aplicar automáticamente este procedimiento a bases de datos de producción ni publicar contraseñas, credenciales, dumps, WAL o datos reales.

## 10. Estado y evidencias

- **Estado: VALIDADO** para la nueva comparación de rendimiento realizada en `perf_lab_bench`.
- **Evidencia consolidada en el repositorio:** `validation.txt`, con cinco medidas sin índice, cinco con índice, comparación del índice compuesto, comprobación de índices y límites del ensayo.
- **Planes históricos conservados:** `plan-before.txt` y `plan-after.txt`, sin contexto temporal propio suficiente para atribuirles la versión o fecha de la nueva sesión.
