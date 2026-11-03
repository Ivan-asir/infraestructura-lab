#!/bin/bash

set -u
set -o pipefail

echo "1. Validación del repositorio"

# Comprobar que estás dentro de un repositorio Git
git rev-parse --is-inside-work-tree > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: la ubicación no contiene un repositorio Git."
    exit 1
else
    echo "Repositorio Git detectado."
fi

RAIZ="$(git rev-parse --show-toplevel)" || exit 1
cd "$RAIZ" || exit 1

echo
echo "2. Estado del repositorio:"

git status --short

echo
echo "3. Comprobación de espacios y formato de cambios"

git diff --check

if [ $? -ne 0 ]; then
    echo "ERROR: se han encontrado problemas en los cambios."
    exit 1
else
    echo "No se han encontrado problemas en los cambios."
fi

git diff --cached --check

if [ $? -ne 0 ]; then
    echo "ERROR: se han encontrado problemas en los cambios preparados."
    exit 1
else
    echo "No se han encontrado problemas en los cambios preparados."
fi

echo
echo "4. Comprobación de espacios finales"

git grep -I -n -e '[[:blank:]]$' -- .
resultado=$?

if [ "$resultado" -eq 0 ]; then
    echo ""
    echo "ERROR: Se encontraron espacios finales en los archivos listados."
    echo "Por favor, elimina los espacios al final de esas líneas antes de continuar."
    exit 1
elif [ "$resultado" -ne 1 ]; then
    echo "ERROR: no se pudo completar la comprobación de formato."
    exit 1
else
    echo "No se han encontrado problemas de espacios finales en los archivos."
fi

echo
echo "5. Comprobación de archivos que no deberían subirse al repositorio (archivos sensibles)"

git ls-files \
    | grep -Ev '(^|/)\.env\.example$' \
    | grep -E '(^|/)(\.env(\.[^/]*)?|[^/]*\.env|\.pgpass|\.vault_pass|vault-password\.txt|vault\.yml|id_(rsa|ed25519)[^/]*|pg_lab_ed25519[^/]*|[^/]*\.(pem|ppk|key|p12|pfx|dump|backup|bak|sql\.gz))$|(^|/)\.ssh/'

resultado=$?
if [ "$resultado" -eq 0 ]; then
    echo "ERROR: hay archivos sensibles versionados."
    exit 1
elif [ "$resultado" -ne 1 ]; then
    echo "ERROR: no se pudo completar la comprobación de nombres sensibles."
    exit 1
else
    echo "No se han encontrado archivos sensibles versionados."
fi

echo
echo "6. Comprobación de sintaxis de scripts Bash"

# Lista NUL: admite espacios en nombres y comprueba el error de Git
LISTA="$(mktemp)" || exit 1
trap 'rm -f -- "$LISTA"' EXIT
git ls-files -z -- '*.sh' > "$LISTA" || exit 1

error_encontrado=0

while IFS= read -r -d '' archivo; do
    [ -f "$archivo" ] || continue
    if ! bash -n "$archivo"; then
        echo "ERROR de sintaxis en: $archivo"
        error_encontrado=1
    fi
done < "$LISTA"

if [ "$error_encontrado" -eq 0 ]; then
    echo "No se encontraron errores de sintaxis en los scripts analizados."
fi

echo
echo "7. Comprobación de validación completada correctamente."
exit 0
