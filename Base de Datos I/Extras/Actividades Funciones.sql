use LIBRERIA_2025

--6. Cree las siguientes funciones:

--a. Hora: una función que les devuelva la hora del sistema en el formato
--HH:MM:SS (tipo carácter de 8).

create function dbo.Hora()
returns CHAR(8)
as
begin
    declare @HoraActual CHAR(8)
    set @HoraActual = CONVERT(CHAR(8), GETDATE(), 108)
    return @HoraActual
end;

GO

select dbo.Hora() as 'Hora actual';

--b. Fecha: una función que devuelva la fecha en el formato AAAMMDD (en
--carácter de 8), a partir de una fecha que le ingresa como parámetro
--(ingresa como tipo fecha).

create function dbo.Fecha(@Fecha DATE)
returns CHAR(8)
as
begin
    declare @FechaFormateada CHAR(8)
    set @FechaFormateada = CONVERT(CHAR(8), @Fecha, 112)
    return @FechaFormateada
end;

GO

select dbo.Fecha('2025-10-16') as 'Fecha formateada';


--c. Dia_Habil: función que devuelve si un día es o no hábil (considere como
--días no hábiles los sábados y domingos). Debe devolver 1 (hábil), 0 (no
--hábil)

create function dbo.Dia_Habil(@Fecha DATE)
returns BIT
as
begin
    declare @Resultado BIT;

    if DATEPART(WEEKDAY, @Fecha) IN (7, 1)
        set @Resultado = 0;
    ELSE
        set @Resultado = 1;

    return @Resultado;
end;

GO

select dbo.Dia_Habil('2025-10-13') as 'Lunes',   -- hábil
       dbo.Dia_Habil('2025-10-18') as 'Sábado',  -- no hábil
       dbo.Dia_Habil('2025-10-19') as 'Domingo'; -- no hábil


--10. Programar funciones que permitan realizar las siguientes tareas:

--a. Devolver una cadena de caracteres compuesto por los siguientes datos:
--Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, de un
--determinado cliente, que se puede informar por codigo de cliente o
--email.



--b. Devolver todos los artículos, se envía un parámetro que permite ordenar
--el resultado por el campo precio de manera ascendente (‘A’), o
--descendente (‘D’).

CREATE OR ALTER FUNCTION dbo.fn_articulos_con_orden
(
    @Orden CHAR(1)  -- 'A' = asc, 'D' = desc
)
returns TABLE
as
return
(
    select
        cod_articulo   as 'cod_articulo',
        descripcion    as 'descripcion',
        stock_minimo   as 'stock_minimo',
        stock          as 'stock',
        pre_unitario   as 'pre_unitario',
        observaciones  as 'observaciones',
        ROW_NUMBER() OVER (
            order by
                CasE WHEN @Orden = 'A' THEN pre_unitario end asC,
                CasE WHEN @Orden = 'D' THEN pre_unitario end DESC
        ) as 'orden'
    from dbo.articulos
);

GO

select *
from dbo.fn_articulos_con_orden('D')
order by orden;


--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.

create function dbo.fn_precio_con_aumento
(
    @CodigoArticulo INT,
    @Porcentaje DECIMAL(6,3)
)
returns DECIMAL(10,2)
as
begin
    declare @precio_actual DECIMAL(10,2);
    declare @precio_resultante DECIMAL(10,2);

    select @precio_actual = pre_unitario
    from dbo.articulos
    where cod_articulo = @CodigoArticulo;

    if @precio_actual IS NULL
        return NULL;
    if @Porcentaje IS NULL
        set @Porcentaje = 0;
    set @precio_resultante = ROUND(@precio_actual * (1.0 + @Porcentaje / 100), 2);

    return @precio_resultante;
end;

GO

select descripcion, pre_unitario
from articulos
where cod_articulo = 10

select dbo.fn_precio_con_aumento(10, 20) as 'Precio con aumento'
