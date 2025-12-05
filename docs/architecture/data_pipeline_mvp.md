# Sintelo SDM – Data Pipeline MVP (estado actual)

Este documento describe el estado ACTUAL (MVP) del pipeline de datos Sintelo usando servicios de Microsoft.

## 1. Componentes que ya existen

- **Azure SQL Server**
  - Servidor: `sintelodbserver`
  - Base de datos sample: `AdventureWorksLT2025_Sample`
  - Esquemas:
    - `SalesLT` (origen de AdventureWorks)
    - `raw_awlt` (esquema RAW de Sintelo para AWLT demo)

- **Storage Account (Data Lake inicial)**
  - `sintelodataeastus2sa` (eastus2)
  - Contenedor: `raw`
  - Archivos: `*.csv` de AdventureWorks OLTP (Customer, SalesOrderHeader, etc.)

- **Código en GitHub (repo sintelo-sdm)**
  - `extractors/adventureworks_lt/sql/01_awlt_raw_schema.sql`
    - Crea esquema `raw_awlt`
    - Crea tabla `raw_awlt.Customer`
    - Limpia la tabla para reruns (`TRUNCATE`)
  - `extractors/adventureworks_lt/python/extract_customer.py`
    - Descarga `Customer.csv` desde Blob Storage
    - Intenta cargar los datos a `raw_awlt.Customer` vía pyodbc

## 2. Flujo actual simplificado (MVP)

1. **Fuente de datos**
   - `AdventureWorksLT2025_Sample.SalesLT.Customer` (dentro de Azure SQL)

2. **Data Lake (Blob Storage)**
   - CSVs de AdventureWorks cargados al contenedor `raw` de `sintelodataeastus2sa`.

3. **Extractor Python (POC)**
   - Lee `Customer.csv` desde el contenedor `raw`.
   - Intenta mapear las columnas del CSV hacia la tabla `raw_awlt.Customer`.

4. **Destino RAW en SQL**
   - Tabla `raw_awlt.Customer` en `AdventureWorksLT2025_Sample` para tener una copia "cruda" del cliente demo (AWLT).

## 3. Decisiones institucionales (MVP)

- Este flujo es un **prototipo de laboratorio**:
  - Demuestra que podemos conectar Blob → Python → Azure SQL.
- La ruta institucional a futuro será:
  - Usar **Azure Data Factory** para orquestar la ingesta.
  - Tratar Blob Storage como **data lake** (`raw`, `staging`, `curated`).
  - Poblar un **Sintelo Data Model (SDM)** en un SQL dedicado (T1/T2).

Este archivo solo documenta el estado actual, no el diseño final.
