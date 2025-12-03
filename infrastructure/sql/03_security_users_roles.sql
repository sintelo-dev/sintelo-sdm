/*
------------------------------------------------------------
-- Sintelo SDM v1.2
-- Institutional Security Model (v1.1)
-- Roles, Permissions & Governance
-- Archivo: 03_security_users_roles.sql
------------------------------------------------------------
*/

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. CREACIÓN DE ROLES INSTITUCIONALES
------------------------------------------------------------

-- Lectura mínima (para auditores, socios, observadores)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_readonly')
    CREATE ROLE sintelo_readonly;
GO

-- Analista de datos interno (T1 + T2)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_analyst')
    CREATE ROLE sintelo_analyst;
GO

-- Operador PE Sintelo (acceso a T1, T2, vistas operativas internas)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_operator')
    CREATE ROLE sintelo_operator;
GO

-- Administrador de datos institucional (NO DBA — control semántico)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_data_admin')
    CREATE ROLE sintelo_data_admin;
GO


------------------------------------------------------------
-- 2. GOBERNANZA SOBRE TABLAS CRUDAS (schema dbo)
------------------------------------------------------------

-- Ningún rol institucional puede leer tablas base crudas
REVOKE SELECT ON SCHEMA::dbo FROM PUBLIC;
GO

-- Solo el admin SQL puede leer/modificar tablas crudas
DENY SELECT ON SCHEMA::dbo TO sintelo_readonly;
DENY SELECT ON SCHEMA::dbo TO sintelo_analyst;
DENY SELECT ON SCHEMA::dbo TO sintelo_operator;
GO

-- Data Admin puede leer tablas crudas para validación estructural
GRANT SELECT ON SCHEMA::dbo TO sintelo_data_admin;
GO


------------------------------------------------------------
-- 3. PERMISOS SOBRE VISTAS T1 (Transformación Cruda → Limpia)
------------------------------------------------------------

-- Analista yes
GRANT SELECT ON SCHEMA::dbo TO sintelo_analyst;

-- Operator yes
GRANT SELECT ON SCHEMA::dbo TO sintelo_operator;

-- Readonly NO (solo vistas finales)
DENY SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_readonly;
GO


------------------------------------------------------------
-- 4. PERMISOS SOBRE VISTAS T2 (Modelo PE-Ready: Revenue, COGS, OPEX, EBITDA)
------------------------------------------------------------

-- Estos son los datos que van a Power BI en el futuro

GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_readonly;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_analyst;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_operator;
GO


------------------------------------------------------------
-- 5. PERMISOS PARA FUTUROS USUARIOS (cuando existan)
------------------------------------------------------------

-- Sintelo Operator
-- EXEC sp_addrolemember 'sintelo_operator', 'user_x';

-- Sintelo Analyst
-- EXEC sp_addrolemember 'sintelo_analyst', 'user_y';

-- Sintelo Readonly
-- EXEC sp_addrolemember 'sintelo_readonly', 'external_auditor';

-- Sintelo Data Admin
-- EXEC sp_addrolemember 'sintelo_data_admin', 'your_future_data_admin';
GO


------------------------------------------------------------
-- 6. AUDITORÍA INSTITUCIONAL SINTelo (gobernanza PE-first)
------------------------------------------------------------

PRINT 'Sintelo Security Model v1.1 aplicado correctamente.';
PRINT 'Roles creados: readonly, analyst, operator, data_admin.';
PRINT 'Tablas crudas protegidas. Vistas T1/T2 habilitadas.';
GO
