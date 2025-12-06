# OLTP → OneLake Pipeline Specification

## Fuente
Azure SQL Database:
- server: `sintelodbserver.database.windows.net`
- db: `AdventureWorks2025_OLTP`

## Destino
Microsoft Fabric Lakehouse:
- workspace: Sintelo Data Platform
- lakehouse: sintelo_core_lh
- folder: `/Tables/raw/`

## Método
Usaremos Microsoft Fabric Data Pipeline:
- Actividad: Copy Data
- Mapping automático de columnas
- Incremental basado en `ModifiedDate`
- Salida: Delta Lake format

## Consideraciones institucionales
- Todos los pipelines deben escribir logs (start/end/error).
- Se debe incluir una tabla `raw._load_manifest` para auditoría.
- Cada carga debe registrar:
  - fecha
  - tabla
  - filas extraídas
  - filas escritas
  - modo: full/incremental
