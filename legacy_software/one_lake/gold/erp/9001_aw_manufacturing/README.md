# Sintelo — GOLD Layer (v1.0)
Arquitectura Institucional PE-as-a-Service · Microsoft Fabric Style · ERPNext Semantic Model

---

## 🎯 Objetivos de GOLD
La capa GOLD contiene tablas analíticas derivadas de Silver. GOLD entrega decisiones, no datos.

1. Transformar Silver en métricas financieras calculadas.
2. Establecer ratios Harvard + McKinsey (ROIC, WACC, Spread, EP).
3. Preparar el feature store para IA financiera Sintelo.
4. Generar el scorecard institucional (Mini Tesis PE).
5. Servir como input para PCV y Valuación (Fase 2–3).

---

## 📦 Carpetas GOLD

### 1. `gold_operations_metrics/`
Contiene métricas operativas y financieras derivadas:
- profitability_ratios.csv
- efficiency_ratios.csv
- leverage_ratios.csv
- working_capital.csv
- cash_conversion_cycle.csv
- operations_kpis.csv
- roic_wacc_spread.csv
- ttms.csv

### 2. `gold_scorecard_sintelo/`
Scorecard oficial de Screening + Mini Tesis:
- traffic_lights.csv
- sintelo_score.csv
- investment_grade_flags.csv

### 3. `gold_ai_feature_store/`
Feature store de IA:
- roic_quartile.csv
- liquidity_risk_score.csv
- concentration_risk.csv
- margin_stability_score.csv
- wc_risk.csv
- volatility_score.csv

### 4. `_metadata/`
- gold_export_metadata.csv
- versioning.json
- lineage.json

---

## 🔗 Dependencias desde Silver
GOLD requiere:
- dim_item
- dim_customer
- fact_sales_invoice
- fact_stock_ledger
- fact_workorders

Y cuando existan:
- silver_balance_sheet
- silver_income_statement
- silver_ar, silver_ap, silver_inventory

---

## 📐 Cálculos principales

### Profitability
- Gross Margin  
- Operating Margin  
- Net Margin (ROS)

### Efficiency
- Asset Turnover  
- Working Capital Turnover  
- Cash Flow / Sales  

### Working Capital
- DSO  
- DPO  
- DIO  
- CCC  

### Leverage
- Debt-to-Equity  
- Interest Coverage  

### Value Creation (McKinsey)
- NOPAT  
- Invested Capital  
- ROIC  
- WACC  
- Spread  
- Economic Profit  
- Reinvestment Rate  
- Growth Rate g  

---

## 📜 Versionado
