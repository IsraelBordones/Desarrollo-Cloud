INSERT INTO pedidos (cliente_id, productos, estado, total, fecha)
SELECT 1, 'Laptop x1, Mouse x2', 'PENDIENTE', 1250000.00, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM pedidos);
INSERT INTO pedidos (cliente_id, productos, estado, total, fecha)
SELECT 2, 'Teclado x1', 'ENVIADO', 45000.00, CURRENT_TIMESTAMP
WHERE (SELECT COUNT(*) FROM pedidos) < 2;
