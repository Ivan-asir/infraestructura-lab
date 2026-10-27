# Plantilla común para README de tecnologías

Las unidades del laboratorio usan exactamente las diez secciones, en este orden. Los directorios transversales (`docs/`, `scripts/`, `.github/workflows/`), agrupadores (`postgresql/`) y recursos comunes (`postgresql/sql/`, `jenkins/agent/`) no constituyen prácticas independientes ni requieren validaciones duplicadas.

```markdown
# NOMBRE DE LA PRÁCTICA

## 1. Objetivo y alcance
## 2. Entorno y requisitos
## 3. Estructura de archivos
## 4. Preparación
## 5. Procedimiento de ejecución
## 6. Comprobaciones y criterios de aceptación
## 7. Incidencias y limitaciones
## 8. Reversión y recuperación
## 9. Seguridad
## 10. Estado y evidencias
```

**Criterios:** conservar datos técnicos, rutas reales, nombres de servicio y decisiones. Las instrucciones deben señalar equipo, usuario, alcance y riesgo. `README.md` explica cómo repetir la práctica; `validation.txt` registra resultados reales; `troubleshooting.md` recoge las incidencias cuando existen.