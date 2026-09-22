INSERT INTO productos (nombre, precio, stock, categoria)
SELECT 'Laptop Pro 15', 1200000.00, 10, 'Computacion'
WHERE NOT EXISTS (SELECT 1 FROM productos);
INSERT INTO productos (nombre, precio, stock, categoria)
SELECT 'Mouse Inalambrico', 25000.00, 50, 'Accesorios'
WHERE (SELECT COUNT(*) FROM productos) < 2;
