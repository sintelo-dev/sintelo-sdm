/*
------------------------------------------------------------
-- AdventureWorksLT2025 Sample Client
-- Carga RAW desde tabla fuente SalesLT.Customer
-- Archivo: 02_awlt_load_raw_customer_from_saleslt.sql
--
-- Objetivo:
--   Tomar la tabla operacional (SalesLT.Customer)
--   y poblar la tabla RAW institucional:
--     raw_awlt.Customer
------------------------------------------------------------
*/

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. Asegurar que el esquema raw_awlt existe
------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'raw_awlt')
    EXEC('CREATE SCHEMA raw_awlt');
GO

------------------------------------------------------------
-- 2. Asegurar que la tabla RAW existe (misma estructura que SalesLT.Customer)
------------------------------------------------------------

IF OBJECT_ID('raw_awlt.Customer', 'U') IS NULL
BEGIN
    CREATE TABLE raw_awlt.Customer (
        CustomerID      INT              NOT NULL,
        NameStyle       BIT              NULL,
        Title           NVARCHAR(8)      NULL,
        FirstName       NVARCHAR(50)     NOT NULL,
        MiddleName      NVARCHAR(50)     NULL,
        LastName        NVARCHAR(50)     NOT NULL,
        Suffix          NVARCHAR(10)     NULL,
        CompanyName     NVARCHAR(128)    NULL,
        SalesPerson     NVARCHAR(256)    NULL,
        EmailAddress    NVARCHAR(50)     NULL,
        Phone           NVARCHAR(25)     NULL,
        PasswordHash    NVARCHAR(128)    NOT NULL,
        PasswordSalt    NVARCHAR(10)     NOT NULL,
        rowguid         UNIQUEIDENTIFIER NOT NULL,
        ModifiedDate    DATETIME         NOT NULL
    );
END;
GO

------------------------------------------------------------
-- 3. Limpiar tabla RAW (idempotente para reruns)
------------------------------------------------------------

TRUNCATE TABLE raw_awlt.Customer;
GO

------------------------------------------------------------
-- 4. Cargar datos desde SalesLT.Customer
------------------------------------------------------------

INSERT INTO raw_awlt.Customer (
    CustomerID,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    CompanyName,
    SalesPerson,
    EmailAddress,
    Phone,
    PasswordHash,
    PasswordSalt,
    rowguid,
    ModifiedDate
)
SELECT
    CustomerID,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    CompanyName,
    SalesPerson,
    EmailAddress,
    Phone,
    PasswordHash,
    PasswordSalt,
    rowguid,
    ModifiedDate
FROM SalesLT.Customer;
GO

PRINT 'Carga completada: SalesLT.Customer → raw_awlt.Customer';
GO
