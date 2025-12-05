# Infraestructura Azure – Sintelo Data Platform

Este folder agrupa la definición de infraestructura como código (IaC) para la plataforma de datos de Sintelo en Azure.

Estructura propuesta:

- **bicep/**  
  Plantillas Bicep para:
  - Azure SQL (servidores y bases).
  - Storage Accounts (Blob).
  - Data Factory / Synapse / Fabric (en versiones futuras).
  - Identidades administradas y configuración de seguridad básica.

- **terraform/**  
  Opcional: versión equivalente de la infraestructura usando Terraform, si se decide estandarizar en esa herramienta.

Principios:
- Todo recurso en Azure debe ser declarable desde aquí.
- Los entornos (dev / stage / prod) deben derivarse de parámetros, no de cambios manuales en el portal.
