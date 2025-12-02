# Sintelo SDM – Sintelo Data Model (v0.1)

Institutional SQL & BI foundation for Sintelo’s Private Equity analytical engine.
This repository contains the canonical data model used across Azure SQL, Power BI,
and internal financial workflows.

## Structure

- `/sql` – Database creation scripts
- `/docs` – Data dictionary & governance
- `/infrastructure` – Templates for Azure SQL deployment
- `/samples` – Example data for development & testing

## Requirements

- Azure SQL Database (v12+)
- Azure CLI or PowerShell
- Power BI Desktop (Windows)
- SQL Server Management Studio (SSMS) or Azure Data Studio

## Roadmap

- v0.1 — Base schemas, dim and fact tables
- v0.2 — Views & semantic model
- v0.3 — Automated CI/CD deploy to Azure
- v1.0 — Production-ready PE analytics layer

---

For internal use by Sintelo.  
© Sintelo, 2025. All rights reserved.
