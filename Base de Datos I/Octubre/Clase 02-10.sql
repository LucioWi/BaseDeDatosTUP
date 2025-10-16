use LIBRERIA_2025_Definitiva

declare @ultimo_nro int;
select @ultimo_nro=max(nro_factura)
 from facturas;

 select f.nro_factura, f.fecha, d.cantidad,
 mensaje=
case
when cantidad < 10 then 'Minorista'
when pre_unitario >= 100 and pre_unitario < 5000 then '5% dto'
else '15% dto.'
 end
from facturas f join detalle_facturas d
 on f.nro_factura = d.nro_factura where YEAR(fecha) = YEAR(GETDATE()) order by mensaje, cantidad, fecha --1. Declarar 3 variables que se llamen codigo, stock y stockMinimo
--respectivamente. A la variable codigo setearle un valor. Las variables stock y
--stockMinimo almacenarán el resultado de las columnas de la tabla artículos
--stock y stockMinimo respectivamente filtradas por el código que se
--corresponda con la variable codigo.

declare @codigo int , @stock int, @stockmin int, @desc varchar(50)
set @codigo = 5
select @stock = stock, @stockmin = stock_minimo, @desc = descripcion
from articulos
where cod_articulo = @codigo
select @desc as 'Descripción', @stock as 'Stock', @stockmin as 'Stock minimo'


create procedure pa_articulos_sumaypromedio5
 @descripcion varchar(100)='%',
 @suma decimal(10,2) output,
 @promedio decimal(8,2) output
 as
 select descripcion,pre_unitario,observaciones
 from articulos
 where descripcion like @descripcion
 select @suma=sum(pre_unitario)
 from articulos
 where descripcion like @descripcion
 select @promedio=avg(pre_unitario)
 from articulos
 where descripcion like @descripcion; GO declare @s decimal(10,2), @p decimal(8,2)
execute pa_articulos_sumaypromedio5 'lápiz%', @s output, @p output
select @s as total, @p as promedio;create proc pa_promedios--@año int = 2025,@promS decimal(10,2) output,@promP decimal (10,2) outputasbegin	Select @promS = AVG(pre_unitario)	from articulos	Select @promP = sum(pre_unitario*cantidad)/SUM(cantidad)	from detalle_facturasendGOdeclare @ps decimal (10,2), @pp decimal (10,2)execute pa_promedios @ps output, @pp outputselect @ps, @pp