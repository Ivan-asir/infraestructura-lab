-- Objetos iniciales del laboratorio.

-- La contraseña de app_user se configura de forma interactiva
-- mediante \password app_user y no se muestra en este fichero.

CREATE ROLE app_user LOGIN;

CREATE DATABASE appdb OWNER app_user;

\connect appdb

CREATE SCHEMA app AUTHORIZATION app_user;
