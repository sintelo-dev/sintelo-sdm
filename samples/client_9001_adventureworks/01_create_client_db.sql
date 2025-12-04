/*
------------------------------------------------------------
Sintelo SDM v1.0
Cliente Demo: 9001 - AdventureWorks
Archivo: 01_create_client_db.sql
Propósito:
  - Crear schemas institucionales para el cliente
  - Registrar metadata base
  - Asegurar estructura SDM
------------------------------------------------------------
*/

-- Crear schema RAW (ingesta directa)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'raw')
    EXEC('CREATE SCHEMA raw');
GO

-- Crear schema T1 (normalización)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sintelo_T1')
    EXEC('CREATE SCHEMA sintelo_T1');
GO

-- Crear schema T2 (modelo financiero PE-ready)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sintelo_T2')
    EXEC('CREATE SCHEMA sintelo_T2');
GO


------------------------------------------------------------
-- Metadata institucional del cliente
------------------------------------------------------------

IF OBJECT_ID('dbo.sintelo_client_registry') IS NULL
BEGIN
    CREATE TABLE dbo.sintelo_client_registry (
        ClientKey        INT          NOT NULL PRIMARY KEY,
        ClientName       NVARCHAR(200),
        SourceERP        NVARCHAR(200),
        IngestionDate    DATETIME2,
        Status           NVARCHAR(50)
    );
END
GO

-- Registrar cliente 9001 si no existe
IF NOT EXISTS (SELECT 1 FROM dbo.sintelo_client_registry WHERE ClientKey = 9001)
BEGIN
    INSERT INTO dbo.sintelo_client_registry (ClientKey, ClientName, SourceERP, IngestionDate, Status)
    VALUES (9001, 'AdventureWorks Demo', 'AdventureWorks CSV', SYSDATETIME(), 'ACTIVE');
END
GO

PRINT 'Schemas creados y cliente registrado correctamente (9001).';
