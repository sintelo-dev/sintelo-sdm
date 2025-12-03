/*
------------------------------------------------------------
-- Sintelo SDM v1.2
-- Security Model & Institutional Roles
-- Archivo: 03_security_users_roles.sql
------------------------------------------------------------
*/

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. Creación de ROLES institucionales
------------------------------------------------------------

-- Rol con permisos mínimos de solo lectura sobre vistas
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_readonly')
    CREATE ROLE sintelo_readonly;
GO

-- Rol para analistas internos de Sintelo (acceso a vistas + funciones)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_analyst')
    CREATE ROLE sintelo_analyst;
GO

-- Rol para Power BI (solo vistas T2)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sintelo_powerbi_role')
    CREATE ROLE sintelo_powerbi_role;
GO


------------------------------------------------------------
-- 2. Usuarios institucionales
------------------------------------------------------------

-- Usuario de servicio para Power BI DirectQuery
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'sintelo_powerbi')
BEGIN
    CREATE LOGIN sintelo_powerbi WITH PASSWORD = 'CambiaEstaContraseña123!';
END;
GO

CREATE USER sintelo_powerbi FOR LOGIN sintelo_powerbi;
GO


-- Usuario analista (cuando contrates a tu primer BI Lead)
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'sintelo_analyst')
BEGIN
    CREATE LOGIN sintelo_analyst WITH PASSWORD = 'CambiaEstaContraseña123!';
END;
GO

CREATE USER sintelo_analyst FOR LOGIN sintelo_analyst;
GO


------------------------------------------------------------
-- 3. Permisos por rol (mínimos necesarios)
------------------------------------------------------------

-- Tablas crudas: NADIE tiene permisos directos excepto admin
-- Se hace explícito el DENY por política institucional
REVOKE SELECT ON SCHEMA::dbo FROM PUBLIC;
DENY SELECT ON SCHEMA::dbo TO sintelo_powerbi_role;
DENY SELECT ON SCHEMA::dbo TO sintelo_readonly;
DENY SELECT ON SCHEMA::dbo TO sintelo_analyst;
GO

------------------------------------------------------------
-- 4. Asignación de permisos sobre VISTAS
------------------------------------------------------------

-- Vistas T1 (transformación cruda → limpia)
GRANT SELECT ON SCHEMA::dbo TO sintelo_analyst;
GRANT SELECT ON SCHEMA::dbo TO sintelo_readonly;

-- Power BI NO accede a vistas T1, solo T2
-- Así evitamos que reporte datos inconsistentes.
GO

-- Vistas T2 (modelo PE-ready: Revenue/COGS/OPEX/EBITDA)
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_powerbi_role;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_analyst;
GRANT SELECT ON dbo.v_Sintelo_PnL_T2 TO sintelo_readonly;
GO

-- Vistas GL (si deseas habilitar para analista)
GRANT SELECT ON dbo.v_Sintelo_GL_T1 TO sintelo_analyst;
GO


------------------------------------------------------------
-- 5. Asignación de usuarios a roles
------------------------------------------------------------

EXEC sp_addrolemember 'sintelo_powerbi_role', 'sintelo_powerbi';
EXEC sp_addrolemember 'sintelo_analyst',       'sintelo_analyst';
EXEC sp_addrolemember 'sintelo_readonly',      'sintelo_analyst';   -- analista hereda readonly
EXEC sp_addrolemember 'sintelo_readonly',      'sintelo_powerbi';   -- BI puede leer vistas permitidas
GO


------------------------------------------------------------
-- 6. Auditoría institucional Sintelo
------------------------------------------------------------

-- Se documenta explícitamente que solo sqladmin-sintelo puede tocar tablas base
-- Esto sirve para auditorías futuras y gobernanza PE.

PRINT 'Security model applied: Sintelo institutional roles created successfully.';
GO
