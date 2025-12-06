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
