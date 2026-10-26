# Formato común de las evidencias de validación

La estructura de los archivos de validación/evidencia siempre será la detallada a continuación.

```text
VALIDACIÓN | NN - NOMBRE DE LA PRÁCTICA
=======================================

1) CONTEXTO
- Entorno: <máquina o contenedor y versión real>
- Alcance: <operación validada>
- Estado: <VALIDADO | PARCIAL | PENDIENTE>

2) COMPROBACIONES Y RESULTADOS
- <prueba y comando identificable>: <resultado observado, no esperado>
- <otra prueba>: <valor real>

3) INCIDENCIAS Y LIMITACIONES
- <incidencia interpretada o "Sin incidencias registradas">
- <qué no demuestra la evidencia, si aplica>

4) ESTADO FINAL Y REVERSIÓN
- <estado posterior verificado>
- <ROLLBACK/restauración validada o "PENDIENTE / no aplica">

5) CONCLUSIÓN
- <criterio de aceptación y resultado concreto>
```

## Criterios de redacción

- Registrar **resultados reales**, no escribir salidas hipotéticas como si fueran observadas.
- Indicar la máquina y, cuando importe, base de datos, usuario y servicio. La fecha es la de la captura de evidencia, no necesariamente la de creación de un archivo.
- Usar `VALIDADO` únicamente para el alcance probado; diferenciar **PENDIENTE**, **NO DETERMINADO** y **NO APLICA**.
- Resumir comandos y resultados sin copiar cientos de líneas de logs. Las comprobaciones negativas deliberadas, como un permiso denegado esperado, se interpretan expresamente.
- Conservar datos y referencias ya acreditados; no reescribir históricos en función del estado actual.
- Cuando se trate de un cambio de alto impacto, anotar también la **reversión realmente ejecutada**, no solo la prevista.
- No publicar contraseñas, tokens, claves privadas, volcados WAL/PGDATA ni datos personales.
