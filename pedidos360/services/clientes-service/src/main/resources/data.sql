INSERT INTO clientes (nombre, email, telefono, direccion)
SELECT 'Juan Perez', 'juan.perez@example.com', '+56911111111', 'Av. Siempre Viva 123'
WHERE NOT EXISTS (SELECT 1 FROM clientes);
INSERT INTO clientes (nombre, email, telefono, direccion)
SELECT 'Maria Gonzalez', 'maria.gonzalez@example.com', '+56922222222', 'Calle Falsa 456'
WHERE (SELECT COUNT(*) FROM clientes) < 2;
