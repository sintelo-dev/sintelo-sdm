# AdventureWorks OLTP – Institutional Ingestion Pipeline (MVP 0.2)

Este módulo define el pipeline institucional moderno de Sintelo para ingestar datos
desde un sistema OLTP hacia el OneLake / Lakehouse en Microsoft Fabric.

## Objetivos

1. Ingesta incremental desde Azure SQL Database.
2. Cargar tablas RAW en formato Delta Lake.
3. Establecer el patrón institucional RAW → Bronze → Silver → Gold.
4. Garantizar trazabilidad, calidad y auditoría.
5. Construir un pipeline que escale a múltiples clientes de Sintelo.

## Componentes

### 1. Conector OLTP → OneLake
- Fuente: Azure SQL Database (AdventureWorks OLTP).
- Destino: Lakehouse (OneLake) en carpeta `/Tables/raw/`.

### 2. Zonas del Data Lake institucional
- **raw/** – copias 1:1 del OLTP sin transformación.
- **bronze/** – normalización mínima (tipos, nulls, columnas de sistema).
- **silver/** – modelos analíticos con joins consistentes.
- **gold/** – métricas PE, KPIs e inputs para IA financiera.

### 3. Lineage y gobernanza
Fabric almacena automáticamente:
- Datasets
- Pipelines
- Relaciones entre artefactos
- Versionamiento de Delta Lake

### 4. Seguridad
- AAD + Purview
- Roles por zona (raw/bronze/silver/gold)
- Enmascaramiento para datos sensibles

## Avance actual del MVP 0.2
- [x] Estructura del módulo
- [ ] Documentación del esquema RAW
- [ ] Especificación del pipeline incremental
- [ ] Creación del pipeline en Fabric
- [ ] Validación de carga en OneLake
- [ ] Documentación de QA / logs / auditoría

## Próximos pasos
1. Definir tablas origen (Sales.Customer, Sales.SalesOrder, etc.).
2. Configurar el pipeline OLTP → OneLake.
3. Crear tablas RAW Delta en Lakehouse.
4. Construir transformaciones Bronze.
5. Conectar Power BI / Fabric Warehouse.
