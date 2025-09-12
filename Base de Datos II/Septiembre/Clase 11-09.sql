use LIBRERIA_2025_Definitiva

select cod_cliente, ape_cliente+' '+nom_cliente as 'Nombre clientes'
from clientes as c
where exists 
(
select cod_cliente
from facturas as f
where c.cod_cliente = f.cod_cliente
and YEAR(fecha) = YEAR(GETDATE())
)

--Listar los clientes que alguna vez compraron un producto menor a $100

select cod_cliente as Codigo, ape_cliente+' '+nom_cliente as 'Nombre cliente'
from clientes as c
where 100>any
(
	select pre_unitario
	from detalle_facturas as df join facturas as f on df.nro_factura = f.nro_factura
	where cod_cliente = c.cod_cliente
)

--Listar los clientes que todos los productos que compró costaron menos de $100 en 2010

select cod_cliente as Codigo, ape_cliente+' '+nom_cliente as 'Nombre cliente'
from clientes as c
where 100>all
(
	select pre_unitario
	from detalle_facturas as df join facturas as f on df.nro_factura = f.nro_factura
	where cod_cliente = c.cod_cliente
		and YEAR(fecha) = 2010
)


--Genere un reporte con los clientes que vinieron mas de 2 veces el año pasado

select cod_cliente, ape_cliente+' '+nom_cliente as 'Nombre cliente'
from clientes as c
where 2<
(
select COUNT(*) 
from facturas
where c.cod_cliente = cod_cliente and
YEAR(fecha)=YEAR(GETDATE())-1
)

--Listar los datos de las facturas de los clientes
--que solo vienen a comprar en febrero es decir 
--que todas las veces que vienen a comprar haya 
--sido en el mes de febrero y no otro mes.

select nro_factura, fecha, cod_cliente
from facturas
where 2=all
(
select MONTH(fecha)
from facturas as f join clientes as c on f.cod_cliente = c.cod_cliente
)

--Mostrar los datos de las facturas para los casos en que se hayan
--hecho menos de 9 facturas ese año

select *
from facturas as f
where 9>
(
	select COUNT(*)
	from facturas
	where YEAR(fecha) = YEAR(f.fecha)
)

--Emitir un reporte con las facturas cuyo importe 
--haya sido superior a 1500 (incluir en el reporte 
--los datos de los articulos y los importes)

select f.nro_factura, fecha, cod_articulo, cantidad*pre_unitario as Importe
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
where 1500<
(
	select SUM(cantidad*pre_unitario)
	from detalle_facturas d1 
	where f.nro_factura = d1.nro_factura
)
order by Importe asc

--Se quiere saber cuando realizó su primer venta cada vendedor y cuanto fue 
--el importe total de las ventas que ha realizado. Mostrar estos datos en un
--listado solo para los casos en que su importe promedio de vendido sea
--superior al importe promedio general (importe promedio de todas las facturas)

select v.cod_vendedor, ape_vendedor,
MIN(fecha) 'Primer venta', SUM(cantidad*pre_unitario) Monto
from facturas as f join vendedores as v on f.cod_vendedor = v.cod_vendedor
join detalle_facturas as df on df.nro_factura = f.nro_factura
group by v.cod_vendedor, ape_vendedor
having avg(cantidad*pre_unitario)>
									(
										select AVG(cantidad*pre_unitario)
										from detalle_facturas
									)

--Realice un informe que muestre cuanto fue el total anual facturado 
--por cada vendedor, para los casos en que el nombre del vendedor 
--comience con B ni con M, que los numeros de facturas oscilen entre 5
--y 25 y que el promedio del monto facturado sea inferior al promedio 
--de ese año.

select v.cod_vendedor, ape_vendedor, YEAR(fecha) as Año,
SUM(cantidad*pre_unitario) Total
from facturas as f join vendedores as v on f.cod_vendedor = v.cod_vendedor
join detalle_facturas as df on df.nro_factura = f.nro_factura
where nom_vendedor not like '[B,M]%' 
	and f.nro_factura between 5 and 25
group by v.cod_vendedor, ape_vendedor, YEAR(fecha)
having AVG(cantidad*pre_unitario)<
									(
										select AVG(cantidad*pre_unitario)
										from detalle_facturas as df1 join
										facturas as f1 on df1.nro_factura =f1.nro_factura
										where YEAR(fecha) = YEAR(f.fecha)
									)
order by 1, Año asc
