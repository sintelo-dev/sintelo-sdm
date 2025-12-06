# RAW Schema – AdventureWorks OLTP

Este documento describe las tablas que serán ingeridas en la zona RAW del Lakehouse.

## Tablas OLTP prioritarias

| Área | Tabla origen | Descripción |
|------|--------------|-------------|
| Clientes | Sales.Customer | Información de clientes |
| Productos | Production.Product | Catálogo de productos |
| Ventas | Sales.SalesOrderHeader | Cabecera de ventas |
| Ventas | Sales.SalesOrderDetail | Detalle de ventas |

## Naming convention institucional

Destino en OneLake:
/Tables/raw/customer
/Tables/raw/product
/Tables/raw/sales_order_header
/Tables/raw/sales_order_detail

Formato: **Delta Lake**  
Modo de carga: **Append + Incremental (ModifiedDate)**  
Clave incremental: `ModifiedDate`
