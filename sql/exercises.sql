-- Facturación por cliente
SELECT c.id, c.nombre, sum(i.cantidad * i.precio_unitario) AS total
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.id
JOIN pedido_items i ON i.pedido_id = p.id
GROUP BY c.id, c.nombre
ORDER BY total DESC, c.id;

-- Clientes sin pedidos
SELECT c.id, c.nombre
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id
WHERE p.id IS NULL;

-- Total por mes
SELECT date_trunc('month', p.fecha) AS mes,
       sum(i.cantidad * i.precio_unitario) AS total
FROM pedidos p
JOIN pedido_items i ON i.pedido_id = p.id
GROUP BY mes
ORDER BY mes;

-- Ranking de clientes
WITH ventas AS (
  SELECT c.id, c.nombre,
         sum(i.cantidad * i.precio_unitario) AS total
  FROM clientes c
  JOIN pedidos p ON p.cliente_id = c.id
  JOIN pedido_items i ON i.pedido_id = p.id
  GROUP BY c.id, c.nombre
)
SELECT nombre, total, dense_rank() OVER (ORDER BY total DESC) AS ranking
FROM ventas;
