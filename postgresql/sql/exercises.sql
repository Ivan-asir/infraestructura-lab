-- Consulta 1: clasificación de clientes por importe total de pedidos

SELECT c.id AS id_cliente, c.nombre AS nombre_cliente, SUM(pi.cantidad * pi.precio_unitario) AS total_factura
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
JOIN pedido_items pi ON p.id = pi.pedido_id
GROUP BY id_cliente, nombre_cliente
ORDER BY total_factura DESC, id_cliente;

-- Consulta 2: identificación de clientes sin pedidos

SELECT c.id, c.nombre
FROM clientes c
WHERE NOT EXISTS (
	SELECT 1
	FROM pedidos p
	WHERE c.id = p.cliente_id
);

-- Consulta 3: análisis de la facturación mensual

SELECT
	EXTRACT(MONTH FROM p.fecha) AS mes,
	EXTRACT(YEAR FROM p.fecha) AS anio,
	SUM(pi.cantidad * pi.precio_unitario) AS facturacion_por_mes
FROM pedidos p
JOIN pedido_items pi ON p.id = pi.pedido_id
GROUP BY mes, anio
ORDER BY anio, mes;

-- Consulta 4a: agregación por pedido mediante CTE

WITH facturacion_por_pedido AS (
	SELECT pi.pedido_id, SUM(pi.cantidad * pi.precio_unitario) AS total
	FROM pedido_items pi
	GROUP BY pi.pedido_id
)
SELECT p.cliente_id, SUM(fpp.total) AS facturacion_total_cliente
FROM pedidos p
JOIN facturacion_por_pedido fpp ON fpp.pedido_id = p.id
GROUP BY p.cliente_id
ORDER BY facturacion_total_cliente DESC, p.cliente_id;

-- Consulta 4b: agregación directa por cliente sin CTE

SELECT p.cliente_id, SUM(pi.cantidad * pi.precio_unitario) AS facturacion_total_cliente
FROM pedidos p
JOIN pedido_items pi ON pi.pedido_id = p.id
GROUP BY p.cliente_id
ORDER BY facturacion_total_cliente DESC, p.cliente_id;
