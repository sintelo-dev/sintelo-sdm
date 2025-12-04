/*
------------------------------------------------------------
Sintelo SDM v1.0
Cliente: 9001 - AdventureWorks
Archivo: 02_ingest_T0_from_source.sql
Propósito:
  - Crear tablas RAW basadas en CSVs
  - Ingesta T0 (sin limpieza)
------------------------------------------------------------
*/

-- Address
IF OBJECT_ID('raw.Address') IS NOT NULL DROP TABLE raw.Address;
CREATE TABLE raw.Address (
    AddressID INT,
    AddressLine1 NVARCHAR(200),
    AddressLine2 NVARCHAR(200),
    City NVARCHAR(100),
    StateProvince NVARCHAR(100),
    PostalCode NVARCHAR(20)
);

-- Customer
IF OBJECT_ID('raw.Customer') IS NOT NULL DROP TABLE raw.Customer;
CREATE TABLE raw.Customer (
    CustomerID INT,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    EmailAddress NVARCHAR(200)
);

-- Product
IF OBJECT_ID('raw.Product') IS NOT NULL DROP TABLE raw.Product;
CREATE TABLE raw.Product (
    ProductID INT,
    Name NVARCHAR(200),
    ProductNumber NVARCHAR(50),
    Color NVARCHAR(50),
    StandardCost DECIMAL(18,2),
    ListPrice DECIMAL(18,2)
);

-- SalesOrderHeader
IF OBJECT_ID('raw.SalesOrderHeader') IS NOT NULL DROP TABLE raw.SalesOrderHeader;
CREATE TABLE raw.SalesOrderHeader (
    SalesOrderID INT,
    OrderDate DATE,
    CustomerID INT,
    SubTotal DECIMAL(18,2),
    TaxAmt DECIMAL(18,2),
    Freight DECIMAL(18,2)
);

-- SalesOrderDetail
IF OBJECT_ID('raw.SalesOrderDetail') IS NOT NULL DROP TABLE raw.SalesOrderDetail;
CREATE TABLE raw.SalesOrderDetail (
    SalesOrderID INT,
    SalesOrderDetailID INT,
    ProductID INT,
    OrderQty INT,
    UnitPrice DECIMAL(18,2),
    LineTotal DECIMAL(18,2)
);

PRINT 'Tablas RAW creadas. Importar archivos CSV ahora.';
