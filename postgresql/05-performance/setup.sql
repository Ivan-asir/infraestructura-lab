CREATE TABLE eventos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    fecha TIMESTAMPTZ NOT NULL,
    tipo TEXT NOT NULL,
    payload TEXT
);

INSERT INTO eventos (usuario_id, fecha, tipo, payload)
SELECT (random() * 10000)::int,
    now() - random() * interval '365 days',
    CASE WHEN random() < 0.5 THEN 'lectura' ELSE 'escritura' END,
    repeat('x', 80)
FROM generate_series(1, 200000);

ANALYZE eventos;