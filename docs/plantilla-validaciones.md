# Formato común de las evidencias de validación

Cada práctica activa mantiene README.md y validation.txt en su directorio. Los recursos compartidos no necesitan validaciones artificiales.

```text
VALIDACIÓN | ID - NOMBRE DE LA PRÁCTICA

1) CONTEXTO
- Entorno: <host/contenedor, usuario, versión y base/servicio/contexto>.
- Código probado: <commit y árbol limpio/modificado; NO REGISTRADO si no consta>.
- Alcance: <qué se comprueba>.
- Estado: <PENDIENTE | EN CURSO | VALIDADO | BLOQUEADO | NO APLICA>.

2) COMPROBACIONES Y RESULTADOS
- <comando/prueba identificable>: <resultado observado y código cuando proceda>.

3) INCIDENCIAS Y LIMITACIONES
- <incidencia, limitación de la evidencia o ausencia de incidencias registradas>.

4) ESTADO FINAL Y REVERSIÓN
- Estado observado: <resultado>.
- Reversión: <ejecutada y comprobada | prevista, no ejecutada | no aplica>.

5) CONCLUSIÓN
- <criterio acreditado y pruebas pendientes, sin ampliar el alcance observado>.
```

## Criterios

- Registrar resultados observados, no salidas hipotéticas ni valores OK predeterminados.
- Distinguir estados de práctica de respuestas de herramientas. Una prueba negativa esperada puede ser correcta aunque el comando devuelva error.
- Un commit no representa cambios locales: identificar si el árbol estaba modificado y conservar el diff revisado cuando sea necesario.
- No inventar fecha, versión, commit ni reversión. Conservar los metadatos de cada ejecución; si faltan, anotarlo.
- No cambiar una evidencia por el mero hecho de que el servicio esté detenido hoy.
- Separar ampliaciones y nuevas ejecuciones con fecha y alcance, sin atribuirlas a pruebas anteriores.
- Mantener el resumen breve: comando, resultado, interpretación y límites. Referenciar planes y evidencias auxiliares cuando aporten detalle necesario.
- Conservar los cinco epígrafes y distinguir la reversión prevista de la realmente ejecutada.
- No publicar contraseñas, tokens, claves, datos reales, PGDATA ni WAL.
