/*
------------------------------------------------------------
-- AdventureWorksLT2025 Sample Client
-- Raw schema for institutional ingestion (ERP → Sintelo)
-- Archivo: 01_awlt_raw_schema.sql
------------------------------------------------------------
*/

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. Crear esquema específico para este cliente demo
--    (Mantener separado de los clientes reales)
------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'raw_awlt')
    EXEC('CREATE SCHEMA raw_awlt');
GO

------------------------------------------------------------
-- 2. Tabla RAW para Customer (copia 1:1 de SalesLT.Customer)
------------------------------------------------------------

IF OBJECT_ID('raw_awlt.Customer', 'U') IS NULL
BEGIN
    CREATE TABLE raw_awlt.Customer (
        CustomerID      INT             NOT NULL,
        NameStyle       BIT             NULL,
        Title           NVARCHAR(8)     NULL,
        FirstName       NVARCHAR(50)    NOT NULL,
        MiddleName      NVARCHAR(50)    NULL,
        LastName        NVARCHAR(50)    NOT NULL,
        Suffix          NVARCHAR(10)    NULL,
        CompanyName     NVARCHAR(128)   NULL,
        SalesPerson     NVARCHAR(256)   NULL,
        EmailAddress    NVARCHAR(50)    NULL,
        Phone           NVARCHAR(25)    NULL,
        PasswordHash    NVARCHAR(128)   NOT NULL,
        PasswordSalt    NVARCHAR(10)    NOT NULL,
        rowguid         UNIQUEIDENTIFIER NOT NULL,
        ModifiedDate    DATETIME        NOT NULL
    );
END;
GO

------------------------------------------------------------
-- 3. Limpieza opcional (MVP dev)
--    Para reruns idempotentes del extractor.
------------------------------------------------------------

TRUNCATE TABLE raw_awlt.Customer;
GO

PRINT 'AdventureWorksLT RAW schema (raw_awlt.Customer) listo en sintelo-sdm-db.';
GO
