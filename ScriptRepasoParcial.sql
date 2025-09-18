-- Creación de la base de datos
CREATE DATABASE ParcialRepaso;
GO

USE ParcialRepaso;
GO

-- Tabla Tipos
CREATE TABLE Tipos (
    id_tipo INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(100) NOT NULL
);
GO

-- Tabla Secciones
CREATE TABLE Secciones (
    id_seccion INT PRIMARY KEY IDENTITY(1,1),
    seccion VARCHAR(100) NOT NULL
);
GO

-- Tabla Productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(255) NOT NULL,
    id_tipo INT,
    precio_venta DECIMAL(10, 2),
    FOREIGN KEY (id_tipo) REFERENCES Tipos(id_tipo)
);
GO

-- Tabla Turnos
CREATE TABLE Turnos (
    id_turno INT PRIMARY KEY IDENTITY(1,1),
    turno VARCHAR(100) NOT NULL
);
GO

-- Tabla Responsables
CREATE TABLE Responsables (
    id_responsable INT PRIMARY KEY IDENTITY(1,1),
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(50),
    fec_ingreso DATE
);
GO

-- Tabla Órdenes
CREATE TABLE Ordenes (
    id_orden INT PRIMARY KEY IDENTITY(1,1),
    id_producto INT,
    id_responsable INT,
    id_seccion INT,
    id_turno INT,
    cantidad INT NOT NULL,
    costo_total DECIMAL(10, 2),
    fecha_fab DATE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    FOREIGN KEY (id_responsable) REFERENCES Responsables(id_responsable),
    FOREIGN KEY (id_seccion) REFERENCES Secciones(id_seccion),
    FOREIGN KEY (id_turno) REFERENCES Turnos(id_turno)
);
GO
-- Insertar registros en Tipos
INSERT INTO Tipos (tipo)
VALUES 
    ('Electrónica'),
    ('Muebles'),
    ('Ropa'),
    ('Alimentos'),
    ('Juguetes');
GO

-- Insertar registros en Secciones
INSERT INTO Secciones (seccion)
VALUES 
    ('Sección A'),
    ('Sección B'),
    ('Sección C'),
    ('Sección D'),
    ('Sección E');
GO

-- Insertar registros en Productos
INSERT INTO Productos (descripcion, id_tipo, precio_venta)
VALUES
    ('Televisor LCD', 1, 250.00),
    ('Silla de oficina', 2, 80.00),
    ('Camiseta de algodón', 3, 15.50),
    ('Sopa instantánea', 4, 1.20),
    ('Muñeca de plástico', 5, 5.99);
GO

-- Insertar registros en Turnos
INSERT INTO Turnos (turno)
VALUES 
    ('Mañana'),
    ('Tarde'),
    ('Noche');
GO

-- Insertar registros en Responsables
INSERT INTO Responsables (apellido, nombre, direccion, telefono, fec_ingreso)
VALUES 
    ('Gómez', 'Juan', 'Calle Ficticia 123', '555-1234', '2023-01-01'),
    ('López', 'Ana', 'Avenida Principal 456', '555-5678', '2023-02-15');
GO

-- Insertar registros en Órdenes
INSERT INTO Ordenes (id_producto, id_responsable, id_seccion, id_turno, cantidad, costo_total, fecha_fab)
VALUES
    (1, 1, 1, 1, 10, 2500.00, '2025-09-01'),
    (2, 2, 2, 2, 15, 1200.00, '2025-09-02'),
    (3, 1, 3, 3, 30, 465.00, '2025-09-03'),
    (4, 2, 4, 1, 50, 60.00, '2025-09-04'),
    (5, 1, 5, 2, 20, 119.80, '2025-09-05');
GO
