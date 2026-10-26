CREATE ROLE tienda_readonly NOLOGIN;
CREATE ROLE tienda_readwrite NOLOGIN;

GRANT CONNECT ON DATABASE tienda TO tienda_readonly, tienda_readwrite;
GRANT USAGE ON SCHEMA public TO tienda_readonly, tienda_readwrite;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO tienda_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO tienda_readwrite;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO tienda_readwrite;
