# Sintelo OneLake — Bronze Layer (ERP Source)
## Client 9001 — AW Manufacturing (AdventureWorks OLTP)

### Propósito del nivel Bronze
El nivel Bronze almacena **datos crudos, sin transformar, replicados 1:1 desde la fuente transaccional (OLTP)**.  
Este nivel sirve como *source of truth histórico* para auditoría, reprocesamiento y control de calidad.

### Características del Bronze institucional
- Estructura **por dominio funcional**.
- Cada tabla del ERP se almacena en su propio directorio.
- No existen transformaciones, joinings ni enriquecimientos.
- Se conservan **nombres, tipos y granularidad originales**.
- `_metadata/` contiene registros de control para auditoría y lineage.

### Convenciones
- `erp/` → Capas de origen de sistemas transaccionales.
- `9001_aw_manufacturing/` → Identificador institucional del cliente/demo.
- Subcarpetas → Una carpeta por tabla OLTP.

### Tablas incluidas
- Customer
- Person
- Product
- ProductCategory
- ProductSubcategory
- SalesOrderHeader
- SalesOrderDetail
- SalesOrderHeaderSalesReason
- SalesReason
- CreditCard
- TransactionHistory
- WorkOrder
- PurchaseOrderHeader
- PurchaseOrderDetail
- Inventory

### Próximos pasos (Pipeline)
1. **Ingesta OLTP → Bronze** (ADF / Python Extractor / Fabric Pipeline)
2. Validación estructural automática
3. Carga en formato delta/CSV comprimido
4. Registrar metadatos en `_metadata/`
5. Exponer datasets para Silver Layer

---

### Responsable
Oficina del CTO — Sintelo Data Backbone
