# Client 9001 – AdventureWorks (Demo Sintelo SDM)

Este directorio contiene el pipeline completo SDM para el cliente demo 9001:

## Estructura
- **01_create_client_db.sql** — Crea la base de datos y los esquemas institucionales.
- **02_ingest_T0_from_source.sql** — Carga los CSV fuente hacia el esquema `raw`.
- **03_build_T1.sql** — Normaliza y limpia datos crudos.
- **04_build_T2.sql** — Crea el modelo financiero PE-ready.

## Propósito
Este demo permite validar:
- Integración multi-ERP a través del SDM.
- Conexión Power BI → Sintelo T2.
- Pipeline institucional completo de ingestión → normalización → output financiero.

## Próximos pasos
- Ajustar ingestiones según CSV disponibles.
- Completar transformaciones T1 y T2.
- Conectar Power BI para validar modelo.
