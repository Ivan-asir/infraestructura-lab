#!/usr/bin/env bash

# Finalizar ante errores (-e), variables no definidas (-u) o fallos dentro de tuberías (pipefail)
set -euo pipefail
umask 077  # Los nuevos backups contienen datos y deben ser privados

# Base de datos de laboratorio que se va a respaldar
BD="tienda"

# Directorio donde PostgreSQL guardará los backups
DIRECTORIO_BACKUP="/var/lib/pgsql/backups"

# Generar una marca temporal para que cada ejecución cree un nombre diferente
FECHA="$(date +%d-%m-%Y_%H:%M:%S)"
SALIDA="$DIRECTORIO_BACKUP/${BD}_${FECHA}.dump"

# Verificar que el directorio de destino existe
test -d "$DIRECTORIO_BACKUP"

# Comprobar de forma silenciosa (-q) que PostgreSQL está aceptando conexiones
pg_isready -q

# Crear un backup lógico en formato custom (-Fc)
pg_dump -Fc "$BD" -f "$SALIDA"

# Comprobar que el fichero se ha creado y que su tamaño es mayor que cero
test -s "$SALIDA"

# Leer el catálogo interno del dump sin restaurarlo, de modo que si el archivo
# está dañado o no es reconocible por pg_restore, el comando falla y el script se detiene
pg_restore --list "$SALIDA" >/dev/null

# Mensaje de validación si todo lo anterior ha terminado correctamente
printf 'Backup validado: %s\n' "$SALIDA"
