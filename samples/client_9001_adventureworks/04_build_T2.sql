/*
------------------------------------------------------------
Sintelo SDM v1.0
Cliente: 9001 - AdventureWorks
Archivo: 04_build_T2.sql
Propósito:
  - Modelo PE-ready (T2)
  - Revenue, COGS, Margen, etc.
  - Base para Scorecard Sintelo & Mini Tesis
------------------------------------------------------------
*/

------------------------------------------------------------
-- Revenue Table
------------------------------------------------------------
IF OBJECT_ID('sintelo_T2.Revenue') IS NOT NULL DROP TABLE sintelo_T2.Revenue;
SELECT
    H.SalesOrderKey,
    H.OrderDate,
    H.CustomerKey,
    D.ProductKey,
    D.OrderQty,
    D.UnitPrice,
    D.LineTotal AS Revenue
INTO sintelo_T2.Revenue
FROM sintelo_T1.SalesOrderHeader H
JOIN sintelo_T1.SalesOrderDetail D
  ON H.SalesOrderKey = D.SalesOrderKey;


------------------------------------------------------------
-- COGS Table (usamos StandardCost como proxy)
------------------------------------------------------------
IF OBJECT_ID('sintelo_T2.COGS') IS NOT NULL DROP TABLE sintelo_T2.COGS;
SELECT
    R.SalesOrderKey,
    R.ProductKey,
    R.OrderQty,
    P.StandardCost * R.OrderQty AS COGS
INTO sintelo_T2.COGS
FROM sintelo_T2.Revenue R
JOIN sintelo_T1.Product P
  ON R.ProductKey = P.ProductKey;


------------------------------------------------------------
-- Income Statement Consolidated (EBITDA Modelo Sintelo)
------------------------------------------------------------
IF OBJECT_ID('sintelo_T2.PnL') IS NOT NULL DROP TABLE sintelo_T2.PnL;
SELECT
    R.SalesOrderKey,
    R.OrderDate,
    SUM(R.Revenue) AS Revenue,
    SUM(C.COGS) AS COGS,
    SUM(R.Revenue) - SUM(C.COGS) AS GrossProfit,
    -- AdventureWorks no tiene OPEX → marcamos 0
    0 AS OPEX,
    (SUM(R.Revenue) - SUM(C.COGS)) AS EBITDA
INTO sintelo_T2.PnL
FROM sintelo_T2.Revenue R
JOIN sintelo_T2.COGS C
  ON R.SalesOrderKey = C.SalesOrderKey
GROUP BY R.SalesOrderKey, R.OrderDate;

PRINT 'T2 completo. Listo para Power BI.';
