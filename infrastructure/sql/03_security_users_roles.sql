/*
------------------------------------------------------------
-- Sintelo SDM v1.2
-- Institutional Security Model (v1.2)
-- Roles, Users, Permissions & Governance
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

-- Rol técnico para conexiones de Power BI (DirectQuery / servicio)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_powerbi_role')
    CREATE ROLE sintelo_powerbi_role;
GO


------------------------------------------------------------
-- 2. LOGINS DE SERVIDOR (MVP DEV ONLY)
--    TODO v2: mover a Azure AD / secretos gestionados
------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'sintelo_powerbi')
BEGIN
    CREATE LOGIN sintelo_powerbi 
        WITH PASSWORD = 'S1nt3l0-PBI!2025#';
END;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'sintelo_analyst')
BEGIN
    CREATE LOGIN sintelo_analyst 
        WITH PASSWORD = 'S1nt3l0-Analyst!2025#';
END;
GO


------------------------------------------------------------
-- 3. USERS EN LA BASE DE DATOS (MAPPED A LOS LOGINS)
------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_powerbi')
    CREATE USER sintelo_powerbi FOR LOGIN sintelo_powerbi;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_analyst')
    CREATE USER sintelo_analyst FOR LOGIN sintelo_analyst;
GO


------------------------------------------------------------
-- 4. GOBERNANZA SOBRE SCHEMA dbo (TABLAS CRUDAS)
------------------------------------------------------------

-- Limpieza: quitar cualquier permiso previo explícito en dbo para evitar drift
REVOKE SELECT ON SCHEMA::dbo FROM PUBLIC;
REVOKE SELECT ON SCHEMA::dbo FROM sintelo_readonly;
REVOKE SELECT ON SCHEMA::dbo FROM sintelo_analyst;
REVOKE SELECT ON SCHEMA::dbo FROM sintelo_operator;
REVOKE SELECT ON SCHEMA::dbo FROM sintelo_powerbi_role;
REVOKE SELECT ON SCHEMA::dbo FROM sintelo_data_admin;
GO

-- Solo sintelo_data_admin puede leer TODO el schema dbo (tablas + vistas)
GRANT SELECT ON SCHEMA::dbo TO sintelo_data_admin;
GO


------------------------------------------------------------
-- 5. PERMISOS SOBRE VISTAS T1 (GL LIMPIO)
--    Detalle contable – solo para operación interna
------------------------------------------------------------

-- GL limpio: solo analista, operador y data_admin
GRANT SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_analyst;
GRANT SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_operator;
GRANT SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_data_admin;

-- Readonly y Power BI NO ven el GL a este nivel de detalle
DENY  SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_readonly;
DENY  SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_powerbi_role;
GO


------------------------------------------------------------
-- 6. PERMISOS SOBRE VISTAS T2 (PE-READY: P&L NORMALIZADO)
------------------------------------------------------------

-- v_Sintelo_PnL_T2 es la vista institucional PE-ready
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_readonly;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_analyst;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_operator;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_data_admin;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_powerbi_role;
GO


------------------------------------------------------------
-- 7. ASIGNACIÓN DE USUARIOS A ROLES (IDEMPOTENTE)
------------------------------------------------------------

-- Helper genérico para no romper si ya existe la membresía
-- (patrón: solo agregar si no existe)

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
    JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE rp.name = 'sintelo_powerbi_role'
      AND dp.name = 'sintelo_powerbi'
)
BEGIN
    EXEC sp_addrolemember 'sintelo_powerbi_role', 'sintelo_powerbi';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
    JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE rp.name = 'sintelo_analyst'
      AND dp.name = 'sintelo_analyst'
)
BEGIN
    EXEC sp_addrolemember 'sintelo_analyst', 'sintelo_analyst';
END;
GO

-- El analista hereda readonly para vistas finales
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
    JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    WHERE rp.name = 'sintelo_readonly'
      AND dp.name = 'sintelo_analyst'
)
BEGIN
    EXEC sp_addrolemember 'sintelo_readonly', 'sintelo_analyst';
END;
GO


------------------------------------------------------------
-- 8. AUDITORÍA INSTITUCIONAL SINTelo (gobernanza PE-first)
------------------------------------------------------------

PRINT 'Sintelo Security Model v1.2 aplicado correctamente.';
PRINT 'Roles: readonly, analyst, operator, data_admin, powerbi_role.';
PRINT 'Logins: sintelo_powerbi, sintelo_analyst (MVP dev).';
PRINT 'Tablas crudas protegidas. Vistas T1/T2 gobernadas por rol.';
GO
