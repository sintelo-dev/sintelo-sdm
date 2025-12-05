# Arquitectura de Datos Sintelo – Visión General

## Objetivo

Construir una plataforma de datos institucional que permita:
- Ingerir datos de múltiples ERPs de PYMEs.
- Normalizar y estandarizar información financiera y operativa.
- Calcular métricas PE de forma consistente.
- Alimentar dashboards y motores IA (Mini Tesis PE) con calidad de firma PE de élite.

## Capas de la arquitectura

1. **Sources (ERPs clientes)**  
   - ERPNext, Contpaq, AdminPAQ, Odoo, etc.  
   - Acceso vía API, conectores nativos o SQL.

2. **Ingestion / Extractors**  
   - Módulos por ERP/cliente bajo `data_platform/extractors/`.  
   - Demo actual: `extractors/adventureworks_lt` (Customer → raw_awlt.Customer).

3. **RAW (Bronze)**  
   - Esquemas tipo `raw_<cliente>` o `raw_<origen>`.  
   - Datos lo más cercanos posible al origen.  
   - Scripts en `data_platform/raw/schemas/`.

4. **Staging (Silver)**  
   - Limpieza y normalización de columnas, tipos y claves.  
   - Unificación entre distintos ERPs hacia el modelo Sintelo.  

5. **Clean / Business (Gold)**  
   - Modelo institucional de Sintelo:
     - Hechos: ventas, compras, inventarios, CF operativo, etc.
     - Dimensiones: clientes, productos, tiempo, región, etc.
   - Base para KPIs y scorecards PE.

6. **Analytics**  
   - Conjunto de vistas/modelos para consumo por Power BI / Fabric.  
   - Dashboards y reportes internos y externos.

7. **AI Layer (PE Reasoning Engine)**  
   - Consumo de métricas y KPIs limpios.  
   - Generación de Mini Tesis PE, diagnósticos y recomendaciones.  
   - Reglas y prompts institucionales documentados en `ai/`.

## Estado actual (AdventureWorksLT Demo)

- Azure SQL: `AdventureWorksLT2025_Sample` creado y operativo.
- Esquema RAW demo: `raw_awlt.Customer` definido vía `extractors/adventureworks_lt/sql/01_awlt_raw_schema.sql`.
- Blob Storage: `sintelodataeastus2sa/raw/*.csv` con tablas AdventureWorks OLTP.
- Extractor Python inicial: `extractors/adventureworks_lt/python/extract_customer.py`, pendiente de refinar para:
  - Cargar todos los campos correctamente.
  - Ajustar el mapeo de columnas.
  - Extender a más tablas relevantes (SalesOrderHeader, SalesOrderDetail, etc.).

Este documento debe evolucionar cada vez que:
- Se agregue un nuevo conector/ERP.
- Se cambie la arquitectura de ingestión.
- Se añadan nuevas tablas de negocio o KPIs PE.
