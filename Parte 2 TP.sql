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