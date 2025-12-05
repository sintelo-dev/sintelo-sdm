# Sintelo Data Platform

Este folder define la arquitectura institucional de datos de Sintelo, independiente de clientes y casos específicos.

Capas principales:

1. **sources/**  
   Conectores a ERPs y sistemas origen (ERPNext, Contpaq, AdminPAQ, Odoo, etc).

2. **extractors/**  
   Lógica de extracción e ingestión (Python, ADF, Functions) que mueve datos desde los sources hacia la capa RAW.  
   - Hoy: el extractor de demo AdventureWorksLT vive en `extractors/adventureworks_lt/`.
   - Futuro: cada cliente/ERP tendrá su módulo aquí.

3. **raw/** (Bronze)  
   Datos crudos, lo más 1:1 posible al sistema origen.  
   - `raw/schemas/`: scripts SQL para crear esquemas/tablas RAW en Azure SQL / Fabric.  
   - `raw/tables/`: definición de tablas RAW por dominio (ventas, clientes, inventarios, etc).

4. **staging/** (Silver)  
   Normalización y estandarización de datos:
   - Tipos de datos consistentes.
   - Nombres de columnas alineados al modelo Sintelo.
   - Preparación para KPIs y lógicas PE.

5. **clean/** (Gold / Business)  
   Modelo de negocio Sintelo:
   - Tablas de hechos y dimensiones (FactVentas, DimClientes, DimProductos, etc).
   - Tablas de métricas financieras y KPIs PE.
   - Base para los scorecards y la Mini Tesis PE.

6. **analytics/**  
   Capas específicas para dashboards y reporting:
   - Modelos tabulares para Power BI / Fabric.
   - Vistas consumidas por reportes y paneles internos.

7. **ai/**  
   Capa de razonamiento PE asistida por IA:
   - Especificaciones de prompts.
   - Esquemas de entrada/salida para Mini Tesis PE.
   - Reglas de negocio y constraints institucionales para los modelos IA.

Este repositorio debe ser el *source of truth* para la arquitectura de datos de Sintelo:  
lo que está aquí es lo que se puede desplegar y operar en Azure.
