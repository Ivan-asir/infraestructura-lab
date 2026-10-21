#!/bin/bash

echo "Validando repositorio..."

# Comprobar que estás dentro de un repositorio Git
git rev-parse --is-inside-work-tree > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: no estás dentro de un repositorio Git."
    exit 1
fi

echo
echo "Estado del repositorio:"
git status --short

echo
echo "Comprobando espacios y formato..."
git diff --check

if [ $? -ne 0 ]; then
    echo "ERROR: se han encontrado problemas en los cambios."
    exit 1
fi

git diff --cached --check

if [ $? -ne 0 ]; then
    echo "ERROR: se han encontrado problemas en los cambios preparados."
    exit 1
fi

echo
echo "Comprobando archivos que no deberían subirse..."
git ls-files \
    | grep -Ev '(^|/)\.env\.example$' \
    | grep -E '(^|/)(\.env(\.[^/]*)?|[^/]*\.env|\.pgpass|\.vault_pass|vault-password\.txt|vault\.yml|id_(rsa|ed25519)[^/]*|pg_lab_ed25519[^/]*|[^/]*\.(pem|ppk|key|p12|pfx|dump|backup|bak|sql\.gz))$|(^|/)\.ssh/'


if [ $? -eq 0 ]; then
    echo "ERROR: hay archivos sensibles versionados."
    exit 1
fi

echo
echo "Comprobando sintaxis de scripts Bash..."

for archivo in scripts/*.sh; do
    [ -f "$archivo" ] || continue
    bash -n "$archivo"

    if [ $? -ne 0 ]; then
        echo "ERROR de sintaxis en $archivo"
        exit 1
    fi
done

echo
echo "Validación completada correctamente."
exit 0
