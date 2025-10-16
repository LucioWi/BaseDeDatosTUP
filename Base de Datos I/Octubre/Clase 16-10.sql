use LIBRERIA_2025_Definitiva
GO
--Triggers

--a. Restar stock DESPUES de INSERTAR una VENTA

CREATE TRIGGER tr_RestarStock_AfterInsertDetalleFactura
ON detalle_facturas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE a
    SET a.stock = a.stock - df.cantidad
    FROM articulos a
    INNER JOIN inserted df ON a.cod_articulo = df.cod_articulo;
END;

GO

--b. Para no poder modificar el nombre de alg�n art�culo

CREATE TRIGGER tr_BloquearCambioDescripcionArticulo
ON articulos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.cod_articulo = d.cod_articulo
        WHERE i.descripcion <> d.descripcion
    )
    BEGIN
        RAISERROR('No est� permitido modificar la descripci�n del art�culo.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

GO
--d. Bloquear al vendedor con c�digo 4 para que no pueda registrar ventas
--en el sistema.

CREATE TRIGGER tr_BloquearVendedor4
ON facturas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE cod_vendedor = 4
    )
    BEGIN
        RAISERROR('El vendedor con c�digo 4 no est� autorizado para registrar ventas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

GO

INSERT INTO facturas (fecha, cod_cliente, cod_vendedor)
VALUES (GETDATE(), 1, 4);

GO