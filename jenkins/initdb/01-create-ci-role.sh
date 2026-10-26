#!/usr/bin/env bash

# Solo se ejecuta al crear por primera vez un volumen de PostgreSQL vacio.

set -euo pipefail

: "${CI_PASSWORD:?Falta CI_PASSWORD en jenkins_postgres_ci}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
  -v ci_password="$CI_PASSWORD" <<'SQL'
SELECT format('CREATE ROLE jenkins_ci LOGIN CREATEDB PASSWORD %L', :'ci_password') \gexec
SQL