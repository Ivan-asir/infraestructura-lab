\set ON_ERROR_STOP on
-- Solo para el fixture inicial de tienda, en una base de CI desechable.
-- No ejecutar sobre una tienda modificada por prácticas posteriores.
BEGIN;
DO $tests$
BEGIN
  IF (SELECT count(*) FROM public.clientes) <> 24
     OR (SELECT count(*) FROM public.productos) <> 100
     OR (SELECT count(*) FROM public.pedidos) <> 200
     OR (SELECT count(*) FROM public.pedido_items) <> 200 THEN
    RAISE EXCEPTION 'Fixture inicial: recuentos incorrectos';
  END IF;
  IF (SELECT count(*) FROM public.clientes c WHERE NOT EXISTS
      (SELECT 1 FROM public.pedidos p WHERE p.cliente_id = c.id)) <> 4 THEN
    RAISE EXCEPTION 'Se esperaban cuatro clientes sin pedidos';
  END IF;
  IF EXISTS (SELECT 1 FROM public.pedido_items i LEFT JOIN public.pedidos p
             ON p.id = i.pedido_id WHERE p.id IS NULL) THEN
    RAISE EXCEPTION 'Hay líneas sin pedido';
  END IF;
  IF EXISTS (SELECT 1 FROM public.pedido_items
             WHERE cantidad <= 0 OR precio_unitario <= 0) THEN
    RAISE EXCEPTION 'Valores económicos inválidos';
  END IF;
  -- Un error esperado debe ser exactamente la violación de CHECK.
  BEGIN
    UPDATE public.productos SET precio = 0 WHERE id = 1;
    RAISE EXCEPTION 'No se rechazó un precio cero';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO public.pedido_items
        (pedido_id, producto_id, cantidad, precio_unitario)
    VALUES (-1, 1, 1, 1);
    RAISE EXCEPTION 'No se rechazó una referencia inexistente';
  EXCEPTION WHEN foreign_key_violation THEN
    NULL;
  END;
END;
$tests$;
ROLLBACK;