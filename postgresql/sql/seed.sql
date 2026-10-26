INSERT INTO clientes (nombre, email)
SELECT 'Cliente ' || n, 'cliente' || n || '@example.test'
FROM generate_series(1, 24) AS n;

INSERT INTO productos (nombre, precio)
SELECT 'Producto ' || n, (10 + n)::numeric(10,2)
FROM generate_series(1, 100) AS n;

INSERT INTO pedidos (cliente_id, fecha)
SELECT 1 + ((n - 1) % 20),
       date_trunc('month', now())
       - ((n - 1) % 12) * interval '1 month'
       + ((n - 1) % 28) * interval '1 day'
FROM generate_series(1, 200) AS n;

INSERT INTO pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
SELECT p.id, 1 + (p.id % 100), 1 + (p.id % 4), pr.precio
FROM pedidos p
JOIN productos pr ON pr.id = 1 + (p.id % 100);
