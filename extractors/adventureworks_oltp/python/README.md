# Extractor Python – AdventureWorksLT (POC)

Este módulo contiene el extractor **experimental** que lee `Customer.csv` desde
Azure Blob Storage y lo carga en `raw_awlt.Customer` dentro de la base
`AdventureWorksLT2025_Sample`.

> ⚠️ **Estado:** Prototipo (POC).  
> Esta no es la arquitectura institucional.  
> Será reemplazado por pipelines orquestados con Azure Data Factory u otro servicio
> oficial de ingesta Sintelo.

## Objetivo del POC

1. Validar que:
   - Podemos conectarnos al Storage Account desde Python.
   - Podemos leer archivos CSV desde el contenedor `raw`.
   - Podemos conectarnos a Azure SQL vía ODBC.
   - Podemos insertar datos en una tabla RAW creada por nosotros.

2. Definir un patrón de trabajo:
## Archivos incluidos

### `extract_customer.py`
- Descarga `Customer.csv` desde:
- `sintelodataeastus2sa` / contenedor `raw`
- Mapea columnas hacia la tabla:
- `raw_awlt.Customer`
- Realiza:
- `TRUNCATE TABLE raw_awlt.Customer`
- `INSERT INTO raw_awlt.Customer (...) VALUES (...)`

## Limitaciones actuales
- Solo soporta **Customer**; no otras tablas de AWLT.
- No valida esquema vs CSV → (por eso surgieron errores de columnas).
- No usa **staging** ni **mapas de transformación**.
- No corre bajo un **orquestador** (ADF / Synapse).
- No maneja credenciales gestionadas (usa variables de entorno).

## Próximos pasos (cuando el POC se consolide)
1. Crear pipelines de ingesta RAW en Azure Data Factory:
- Origen: Azure SQL (SalesLT.*)
- Destino: Azure Storage (raw → staging)
- Mapeo automático de esquema.

2. Crear tablas RAW institucionales en un SQL dedicado a Sintelo.

3. Sustituir el extractor Python por:
- Pipelines ADF,
- o Synapse Mapping Data Flows,
- o Synapse Pipelines si se requiere transformación ligera.

4. Integrar con el **Sintelo Data Model (SDM)**.

---

Este archivo es meramente descriptivo y sirve para documentar el estado actual.
