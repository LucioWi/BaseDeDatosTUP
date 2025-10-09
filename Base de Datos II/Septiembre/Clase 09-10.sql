--5.a. Mostrar los artículos cuyo precio sea mayor o igual que un valor que se
--envía por parámetro.create proc SP_Mayor_Precio@numIngresado decimal(10,2)asbeginSelect cod_articulo as 'ID Articulo', descripcion as 'Descripción',pre_unitario as 'Precio unitario', stock as 'Stock', stock_minimo as 'Stock minimo'from articulosWHERE pre_unitario >= @numIngresado
    ORDER BY pre_unitario DESC;endexec SP_Mayor_Precio @numIngresado = 5000--5.b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100.
--Informar un error caso contrario.GOCREATE PROCEDURE SP_Insertar_Articulo
    @cod_articulo INT,
    @descripcion VARCHAR(100),
    @stock_minimo INT,
    @stock INT,
    @pre_unitario DECIMAL(10,2),
    @observaciones VARCHAR(255)
AS
BEGIN
    IF @stock > 30 AND @stock < 100
    BEGIN
        INSERT INTO articulos (cod_articulo, descripcion, stock_minimo, stock, pre_unitario, observaciones)
        VALUES (@cod_articulo, @descripcion, @stock_minimo, @stock, @pre_unitario, @observaciones)

        PRINT 'Artículo insertado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'Error: El stock debe ser mayor a 30 y menor que 100.';
    END
END;

GO

--CREAR UNA FUNCION QUE RECIBA COMO PARAMETRO UNA FECHA Y DEVUELVA EL NOMBRE DEL MES

create function f_nombreMes
(@fecha datetime)
returns varchar(10)
as
begin
declare @nombre varchar(10)
set @nombre =
case MONTH(@fecha)
when 1 then 'Enero'
when 2 then 'Febrero'
when 3 then 'Marzo'
when 4 then 'Abril'
when 5 then 'Mayo'
when 6 then 'Junio'
when 7 then 'Julio'
when 8 then 'Agosto'
when 9 then 'Septiembre'
when 10 then 'Octubre'
when 11 then 'Noviembre'
when 12 then 'Diciembre'
end
return @nombre
end

go

select ape_vendedor + ' ' + nom_vendedor Vendedor, str(DAY(fec_nac))+ ' de '+dbo.f_nombreMes(fec_nac) as 'Fecha'
from vendedores