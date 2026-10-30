-- Consulta 1: medir antes y después del índice
SELECT *
FROM eventos
WHERE usuario_id = 1234;

-- Consulta 2: crear un índice para el filtro por usuario
CREATE INDEX idx_eventos_usuario ON eventos (usuario_id);
ANALYZE eventos;

-- Consulta 3: crear un índice compuesto y analizar el filtro por usuario y fecha de los últimos 30 días
CREATE INDEX idx_eventos_usuario_fecha
ON eventos (usuario_id, fecha);

ANALYZE eventos;

-- Consulta 4: devolver el número de eventos recientes para el usuario indicado
SELECT usuario_id, count(*)
FROM eventos
WHERE usuario_id = 1234
  AND fecha >= now() - interval '30 days'
GROUP BY usuario_id;