/*
------------------------------------------------------------
Sintelo SDM v1.0
Cliente: 9001 - AdventureWorks
Archivo: 03_build_T1.sql
Propósito:
  - Limpieza básica
  - Tipificación
  - Tablas normalizadas T1
------------------------------------------------------------
*/

------------------------------------------------------------
-- T1: Customer
------------------------------------------------------------
IF OBJECT_ID('sintelo_T1.Customer') IS NOT NULL DROP TABLE sintelo_T1.Customer;
SELECT
    CustomerID AS CustomerKey,
    FirstName,
    LastName,
    EmailAddress
INTO sintelo_T1.Customer
FROM raw.Customer;


------------------------------------------------------------
-- T1: Product
------------------------------------------------------------
IF OBJECT_ID('sintelo_T1.Product') IS NOT NULL DROP TABLE sintelo_T1.Product;
SELECT
    ProductID AS ProductKey,
    Name AS ProductName,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice
INTO sintelo_T1.Product
FROM raw.Product;


------------------------------------------------------------
-- T1: Sales Header
------------------------------------------------------------
IF OBJECT_ID('sintelo_T1.SalesOrderHeader') IS NOT NULL DROP TABLE sintelo_T1.SalesOrderHeader;
SELECT
    SalesOrderID AS SalesOrderKey,
    OrderDate,
    CustomerID AS CustomerKey,
    SubTotal,
    TaxAmt,
    Freight
INTO sintelo_T1.SalesOrderHeader
FROM raw.SalesOrderHeader;


------------------------------------------------------------
-- T1: Sales Detail
------------------------------------------------------------
IF OBJECT_ID('sintelo_T1.SalesOrderDetail') IS NOT NULL DROP TABLE sintelo_T1.SalesOrderDetail;
SELECT
    SalesOrderID AS SalesOrderKey,
    SalesOrderDetailID,
    ProductID AS ProductKey,
    OrderQty,
    UnitPrice,
    LineTotal
INTO sintelo_T1.SalesOrderDetail
FROM raw.SalesOrderDetail;


PRINT 'T1 completado.';
