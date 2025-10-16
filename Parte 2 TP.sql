--Mostrar los 5 generos más populares por cada tipo de cliente, con la
--cantidad de peliculas que tiene dicho genero, la cantidad de ventas
--generadas, el monto total de ventas y el promedio de personas que asisten 
--a cada pelicula del genero. Todo esto tomando en cuenta los datos del
--año actual.

SELECT
    a1.t_cliente as 'Tipo de cliente',
    a1.genero as 'Género',
    a1.peliculas_count as 'Cantidad de peliculas en el año',
    a1.total_tickets as 'Cantidad de ventas',
    a1.total_ventas 'Monto total de ventas',
    ROUND(a1.avg_asistencia, 2) AS 'Promedio de asistencia por pelicula'
FROM
(
    SELECT
        tk.id_t_cliente,
        dg.id_genero,
        tc.t_cliente,
        gp.genero,
        COUNT(DISTINCT tk.cod_pelicula) AS peliculas_count,
        SUM(dt.cantidad_ticket) AS total_tickets,
        SUM(dt.subtotal) AS total_ventas,
        CAST(SUM(dt.cantidad_ticket) AS FLOAT)
            / NULLIF(COUNT(DISTINCT tk.cod_pelicula), 0) AS avg_asistencia
    FROM detalle_tickets dt
    JOIN tickets tk          ON dt.cod_ticket = tk.cod_ticket
    JOIN comprobante c       ON dt.cod_comprobante = c.cod_comprobante
    JOIN peliculas p         ON tk.cod_pelicula = p.cod_pelicula
    JOIN detalles_generos dg ON p.cod_pelicula = dg.cod_pelicula
    JOIN tipos_clientes tc   ON tk.id_t_cliente = tc.id_t_cliente
    JOIN generos_peliculas gp ON dg.id_genero = gp.id_genero
    WHERE YEAR(c.fecha) = YEAR(GETDATE())  -- sólo año actual
    GROUP BY tk.id_t_cliente, dg.id_genero, tc.t_cliente, gp.genero
) a1
LEFT JOIN
(
    SELECT
        tk.id_t_cliente,
        dg.id_genero,
        tc.t_cliente,
        gp.genero,
        COUNT(DISTINCT tk.cod_pelicula) AS peliculas_count,
        SUM(dt.cantidad_ticket) AS total_tickets,
        SUM(dt.subtotal) AS total_ventas,
        CAST(SUM(dt.cantidad_ticket) AS FLOAT)
            / NULLIF(COUNT(DISTINCT tk.cod_pelicula), 0) AS avg_asistencia
    FROM detalle_tickets dt
    JOIN tickets tk          ON dt.cod_ticket = tk.cod_ticket
    JOIN comprobante c       ON dt.cod_comprobante = c.cod_comprobante
    JOIN peliculas p         ON tk.cod_pelicula = p.cod_pelicula
    JOIN detalles_generos dg ON p.cod_pelicula = dg.cod_pelicula
    JOIN tipos_clientes tc   ON tk.id_t_cliente = tc.id_t_cliente
    JOIN generos_peliculas gp ON dg.id_genero = gp.id_genero
    WHERE YEAR(c.fecha) = YEAR(GETDATE())
    GROUP BY tk.id_t_cliente, dg.id_genero, tc.t_cliente, gp.genero
) a2
    ON a2.id_t_cliente = a1.id_t_cliente
       AND (
           a2.total_tickets > a1.total_tickets
           OR (a2.total_tickets = a1.total_tickets AND a2.total_ventas > a1.total_ventas)
           OR (a2.total_tickets = a1.total_tickets AND a2.total_ventas = a1.total_ventas AND a2.id_genero < a1.id_genero)
       )
GROUP BY
    a1.t_cliente,
    a1.genero,
    a1.peliculas_count,
    a1.total_tickets,
    a1.total_ventas,
    a1.avg_asistencia
HAVING
    COUNT(a2.id_genero) < 5 
ORDER BY
    a1.t_cliente,
    a1.total_tickets DESC,
    a1.total_ventas DESC,
    a1.genero;

GO

-- --------------------------
-- 1) Películas (IDs explícitos para pruebas)
-- --------------------------
SET IDENTITY_INSERT peliculas ON;
INSERT INTO peliculas (cod_pelicula, titulo, id_formato, duracion_min, id_pais, id_clasif)
VALUES
(100, 'Accion One', NULL, 120, NULL, NULL),   -- género 1
(101, 'Risas Nonstop', NULL, 95,  NULL, NULL), -- género 2
(102, 'Drama Profundo', NULL, 110, NULL, NULL),-- género 3
(103, 'Noche de Terror', NULL, 100, NULL, NULL),-- género 4
(104, 'Aventura Epica', NULL, 130, NULL, NULL),-- género 5
(105, 'Animacion Kids', NULL, 85,  NULL, NULL), -- género 6
(106, 'SciFi Future', NULL, 125, NULL, NULL),   -- género 7
(107, 'Romance Clasico', NULL, 105, NULL, NULL);-- género 8
SET IDENTITY_INSERT peliculas OFF;

-- --------------------------
-- 2) Mapeo película -> género
-- --------------------------
INSERT INTO detalles_generos (id_genero, cod_pelicula) VALUES
(1, 100), -- Acción
(2, 101), -- Comedia
(3, 102), -- Drama
(4, 103), -- Terror
(5, 104), -- Aventura
(6, 105), -- Animación
(7, 106), -- Ciencia Ficción
(8, 107); -- Romance

-- --------------------------
-- 3) Clientes (para vincular comprobantes)
-- --------------------------
SET IDENTITY_INSERT clientes ON;
INSERT INTO clientes (id_cliente, fecha_registro, nombre_cliente, apellido_cliente)
VALUES
(10, '2025-01-01', 'Juan', 'Pérez'),
(11, '2025-02-14', 'María', 'Gómez'),
(12, '2025-03-03', 'Carlos', 'López');
SET IDENTITY_INSERT clientes OFF;

-- --------------------------
-- 4) Comprobantes (fechas en 2025, año actual)
-- --------------------------
SET IDENTITY_INSERT comprobante ON;
INSERT INTO comprobante (cod_comprobante, id_cliente, id_empleado, id_fcompra, id_fpago, confirm_pago, fecha)
VALUES
(200, 10, NULL, 1, 1, 1, '2025-10-10 12:00:00'),
(201, 11, NULL, 2, 2, 1, '2025-10-11 15:00:00'),
(202, 12, NULL, 1, 1, 1, '2025-10-12 19:00:00'),
(203, 10, NULL, 2, 1, 1, '2025-10-13 20:00:00'),
(204, 11, NULL, 1, 2, 1, '2025-10-14 21:30:00'),
(205, 12, NULL, 2, 1, 1, '2025-10-14 22:00:00');
SET IDENTITY_INSERT comprobante OFF;

-- --------------------------
-- 5) Tickets (IDs explícitos) - varios tipos de cliente
-- --------------------------
SET IDENTITY_INSERT tickets ON;
INSERT INTO tickets (cod_ticket, id_funcion, id_sala, cod_pelicula, nro_butaca, fecha_funcion, horario_funcion, id_t_cliente)
VALUES
(300, NULL, NULL, 100, 1, '2025-10-10', '12:00:00', 1), -- Regular -> Acción
(301, NULL, NULL, 101, 2, '2025-10-10', '12:00:00', 1), -- Regular -> Comedia
(302, NULL, NULL, 101, 3, '2025-10-11', '15:00:00', 2), -- Estudiante -> Comedia
(303, NULL, NULL, 102, 4, '2025-10-11', '15:00:00', 2), -- Estudiante -> Drama
(304, NULL, NULL, 103, 5, '2025-10-12', '19:00:00', 3), -- Jubilado -> Terror
(305, NULL, NULL, 104, 6, '2025-10-13', '20:00:00', 4), -- VIP -> Aventura
(306, NULL, NULL, 100, 7, '2025-10-13', '20:00:00', 4), -- VIP -> Acción
(307, NULL, NULL, 105, 8, '2025-10-14', '21:30:00', 5), -- Corporativo -> Animación
(308, NULL, NULL, 106, 9, '2025-10-14', '22:00:00', 1), -- Regular -> SciFi
(309, NULL, NULL, 107,10, '2025-10-14', '22:00:00', 2); -- Estudiante -> Romance
SET IDENTITY_INSERT tickets OFF;

-- --------------------------
-- 6) Detalle_tickets (vinculan comprobante + ticket)
--    cantidad_ticket y subtotal preparados para producir distintos totales
-- --------------------------
INSERT INTO detalle_tickets (cod_comprobante, cod_ticket, cantidad_ticket, subtotal) VALUES
-- comprobante 200 (Regular) compra 3 tickets acción + 2 tickets comedia
(200, 300, 3, 3 * 500.00),  -- 3 entradas acción a $500 => $1500
(200, 301, 2, 2 * 400.00),  -- 2 entradas comedia a $400 => $800

-- comprobante 201 (Estudiante)
(201, 302, 5, 5 * 200.00),  -- 5 entradas comedia a $200 (promo estudiante)
(201, 303, 2, 2 * 300.00),  -- 2 entradas drama a $300

-- comprobante 202 (Jubilado)
(202, 304, 4, 4 * 150.00),  -- 4 entradas terror a $150 (descuento)
(202, 305, 1, 1 * 700.00),  -- 1 entrada aventura a $700

-- comprobante 203 (VIP)
(203, 306, 6, 6 * 450.00),  -- 6 entradas acción a $450
(203, 305, 2, 2 * 700.00),  -- 2 entradas aventura a $700

-- comprobante 204 (Corporativo)
(204, 307, 10, 10 * 250.00), -- 10 entradas animación a $250

-- comprobante 205 (mix)
(205, 308, 4, 4 * 600.00),  -- 4 entradas scifi a $600
(205, 309, 3, 3 * 350.00);  -- 3 entradas romance a $350
