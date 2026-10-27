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

- Registrar **resultados reales**, no escribir salidas hipotéticas.
- Indicar la máquina y, cuando importe, base de datos, usuario y servicio.
- Usar `VALIDADO` únicamente para el alcance probado; diferenciar **PENDIENTE**, **NO DETERMINADO** y **NO APLICA**.
- Resumir comandos y resultados sin copiar líneas de logs. Las comprobaciones negativas deliberadas, como un permiso denegado esperado, se interpretan expresamente.
- Conservar datos y referencias ya acreditados; no reescribir históricos en función del estado actual.
- Cuando se trate de un cambio de alto impacto, anotar también la **reversión realmente ejecutada**, no solo la prevista.
- No publicar contraseñas, tokens, claves privadas, volcados WAL/PGDATA ni datos personales.

## Convención única en todo el repositorio

- Un **bloque de práctica** activo tiene `README.md` y `validation.txt` en la misma carpeta.
- La primera línea es `VALIDACIÓN | <ID> - <TÍTULO>`; siguen los **cinco epígrafes** del modelo anterior en el mismo orden.
- Cada comprobación debe enlazarse a su comando, resultado y entorno cuando sea relevante.
- Un resultado histórico no prueba que el servicio siga operativo hoy. No cambiar una evidencia ya publicada solo por normalizar su presentación.
- Si falta una prueba, anotar `PENDIENTE` y **cómo obtenerla**; no usar `OK` como valor predeterminado.
- El apartado 4 separa el estado final verificado de la reversión prevista y de la realmente ejecutada.
- Un archivo de evidencias puede referenciar documentos históricos más extensos en `docs/` sin duplicarlos ni eliminarlos.
