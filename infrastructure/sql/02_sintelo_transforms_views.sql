-- 02_sintelo_transforms_views.sql
-- Transformaciones T1/T2 y vistas institucionales Sintelo

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. Tabla auxiliar: clasificación institucional de cuentas
------------------------------------------------------------

IF OBJECT_ID('dbo.AccountClassification','U') IS NULL
BEGIN
  CREATE TABLE dbo.AccountClassification (
    CompanyKey     nvarchar(140) NOT NULL,
    AccountKey     nvarchar(140) NOT NULL,
    Category       nvarchar(50)  NOT NULL, -- REVENUE, COGS, OPEX, ADJUSTMENT, NON_OPERATING, BALANCE_SHEET
    Subcategory    nvarchar(100) NULL,     -- opcional (G&A, SELLING, etc.)
    Notes          nvarchar(255) NULL,
    CONSTRAINT PK_AccountClassification PRIMARY KEY (CompanyKey, AccountKey)
  );
END
GO

------------------------------------------------------------
-- 2. Vista T1: GL limpio y enriquecido
------------------------------------------------------------

IF OBJECT_ID('dbo.v_Sintelo_GL_T1','V') IS NOT NULL
  DROP VIEW dbo.v_Sintelo_GL_T1;
GO

CREATE VIEW dbo.v_Sintelo_GL_T1 AS
SELECT
  gl.name                 AS GLEntryKey,
  gl.company              AS CompanyKey,
  gl.account              AS AccountKey,
  cls.Category            AS AccountCategory,
  cls.Subcategory         AS AccountSubcategory,
  gl.posting_date         AS PostingDate,
  d.date_id               AS DateKey,
  d.year                  AS [Year],
  d.month                 AS [Month],
  CONCAT(d.year, '-', RIGHT('0' + CAST(d.month AS varchar(2)), 2)) AS YearMonth,
  gl.party_type,
  gl.party,
  gl.cost_center,
  gl.voucher_type,
  gl.voucher_no,
  gl.debit,
  gl.credit,
  CAST(gl.debit - gl.credit AS decimal(18,2)) AS AmountSigned,
  acc.root_type,
  acc.report_type
FROM GLEntry gl
LEFT JOIN DimDate d
  ON d.date_id = gl.posting_date
LEFT JOIN Account acc
  ON acc.name = gl.account
LEFT JOIN AccountClassification cls
  ON cls.CompanyKey = gl.company
 AND cls.AccountKey = gl.account;
GO

------------------------------------------------------------
-- 3. Vista T2: P&L Sintelo por mes
------------------------------------------------------------

IF OBJECT_ID('dbo.v_Sintelo_PnL_T2','V') IS NOT NULL
  DROP VIEW dbo.v_Sintelo_PnL_T2;
GO

CREATE VIEW dbo.v_Sintelo_PnL_T2 AS
WITH base AS (
  SELECT
    CompanyKey,
    [Year],
    [Month],
    YearMonth,
    ISNULL(AccountCategory, 'UNCLASSIFIED') AS AccountCategory,
    AmountSigned
  FROM v_Sintelo_GL_T1
)
SELECT
  CompanyKey,
  [Year],
  [Month],
  YearMonth,

  -- Bloque de ingresos y costos
  SUM(CASE WHEN AccountCategory = 'REVENUE'
           THEN AmountSigned ELSE 0 END) AS Revenue_Operativo,

  SUM(CASE WHEN AccountCategory = 'COGS'
           THEN AmountSigned ELSE 0 END) AS COGS,

  SUM(CASE WHEN AccountCategory = 'OPEX'
           THEN AmountSigned ELSE 0 END) AS OPEX,

  -- Ajustes y no operativos
  SUM(CASE WHEN AccountCategory = 'ADJUSTMENT'
           THEN AmountSigned ELSE 0 END) AS Ajustes_Normalizados_Sintelo,

  SUM(CASE WHEN AccountCategory = 'NON_OPERATING'
           THEN AmountSigned ELSE 0 END) AS Otros_No_Operativos,

  -- Métricas derivadas Sintelo
  SUM(CASE WHEN AccountCategory = 'REVENUE'
           THEN AmountSigned ELSE 0 END)
  - SUM(CASE WHEN AccountCategory = 'COGS'
           THEN AmountSigned ELSE 0 END) AS GrossProfit,

  SUM(CASE WHEN AccountCategory = 'REVENUE'
           THEN AmountSigned ELSE 0 END)
  - SUM(CASE WHEN AccountCategory = 'COGS'
           THEN AmountSigned ELSE 0 END)
  - SUM(CASE WHEN AccountCategory = 'OPEX'
           THEN AmountSigned ELSE 0 END) AS EBITDA_Reportado,

  ( SUM(CASE WHEN AccountCategory = 'REVENUE'
             THEN AmountSigned ELSE 0 END)
    - SUM(CASE WHEN AccountCategory = 'COGS'
             THEN AmountSigned ELSE 0 END)
    - SUM(CASE WHEN AccountCategory = 'OPEX'
             THEN AmountSigned ELSE 0 END)
  )
  + SUM(CASE WHEN AccountCategory = 'ADJUSTMENT'
             THEN AmountSigned ELSE 0 END) AS EBITDA_Normalizado_Sintelo

FROM base
GROUP BY
  CompanyKey,
  [Year],
  [Month],
  YearMonth;
GO
