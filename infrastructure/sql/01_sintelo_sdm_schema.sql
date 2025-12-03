------------------------------------------------------------
-- Sintelo SDM v1.2 – Canonical Schema
-- Creación de Dimensiones, Hechos y Relaciones
------------------------------------------------------------

-----------------------------
-- DIMENSIONES
-----------------------------

-- Company
CREATE TABLE Company (
    name VARCHAR(255) PRIMARY KEY,
    company_name VARCHAR(255),
    abbr VARCHAR(50),
    country VARCHAR(100),
    default_currency VARCHAR(10)
);

-- Account
CREATE TABLE Account (
    name VARCHAR(255) PRIMARY KEY,
    account_name VARCHAR(255),
    account_number VARCHAR(255),
    is_group INT,
    company VARCHAR(255),
    root_type VARCHAR(50),
    report_type VARCHAR(50),
    account_currency VARCHAR(50),
    parent_account VARCHAR(255)
);

-- Customer
CREATE TABLE Customer (
    name VARCHAR(255) PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_group VARCHAR(255),
    default_currency VARCHAR(10),
    tax_id VARCHAR(100)
);

-- Supplier
CREATE TABLE Supplier (
    name VARCHAR(255) PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_group VARCHAR(255),
    default_currency VARCHAR(10),
    tax_id VARCHAR(100)
);

-- Item
CREATE TABLE Item (
    name VARCHAR(255) PRIMARY KEY,
    item_code VARCHAR(255),
    item_name VARCHAR(255),
    item_group VARCHAR(255),
    stock_uom VARCHAR(50),
    is_stock_item INT,
    is_purchase_item INT,
    is_sales_item INT,
    brand VARCHAR(255)
);

-- Warehouse
CREATE TABLE Warehouse (
    name VARCHAR(255) PRIMARY KEY,
    warehouse_name VARCHAR(255),
    parent_warehouse VARCHAR(255),
    company VARCHAR(255)
);

-----------------------------
-- DIMENSIÓN CALENDARIO
-----------------------------

CREATE TABLE DimDate (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    month_name VARCHAR(50),
    quarter INT,
    quarter_name VARCHAR(50),
    year INT,
    week_of_year INT,
    day_of_week INT,
    day_name VARCHAR(50),
    is_month_end BIT,
    is_quarter_end BIT,
    is_year_end BIT
);

-----------------------------
-- TABLAS DE HECHOS
-----------------------------

-- General Ledger Entry
CREATE TABLE GLEntry (
    name VARCHAR(255) PRIMARY KEY,
    posting_date DATE,
    account VARCHAR(255),
    party_type VARCHAR(255),
    party VARCHAR(255),
    cost_center VARCHAR(255),
    debit DECIMAL(18,2),
    credit DECIMAL(18,2),
    voucher_type VARCHAR(255),
    voucher_no VARCHAR(255),
    company VARCHAR(255)
);

-- SalesInvoice
CREATE TABLE SalesInvoice (
    name VARCHAR(255) PRIMARY KEY,
    customer VARCHAR(255),
    posting_date DATE,
    due_date DATE,
    company VARCHAR(255),
    currency VARCHAR(10),
    grand_total DECIMAL(18,2),
    outstanding_amount DECIMAL(18,2),
    status VARCHAR(50)
);

-- SalesInvoiceItem
CREATE TABLE SalesInvoiceItem (
    name VARCHAR(255) PRIMARY KEY,
    parent VARCHAR(255),
    item_code VARCHAR(255),
    qty DECIMAL(18,2),
    rate DECIMAL(18,2),
    amount DECIMAL(18,2),
    warehouse VARCHAR(255),
    cost_center VARCHAR(255)
);

-- PurchaseInvoice
CREATE TABLE PurchaseInvoice (
    name VARCHAR(255) PRIMARY KEY,
    supplier VARCHAR(255),
    posting_date DATE,
    due_date DATE,
    company VARCHAR(255),
    currency VARCHAR(10),
    grand_total DECIMAL(18,2),
    outstanding_amount DECIMAL(18,2),
    status VARCHAR(50)
);

-- PurchaseInvoiceItem
CREATE TABLE PurchaseInvoiceItem (
    name VARCHAR(255) PRIMARY KEY,
    parent VARCHAR(255),
    item_code VARCHAR(255),
    qty DECIMAL(18,2),
    rate DECIMAL(18,2),
    amount DECIMAL(18,2),
    warehouse VARCHAR(255),
    cost_center VARCHAR(255)
);

-- StockLedgerEntry
CREATE TABLE StockLedgerEntry (
    name VARCHAR(255) PRIMARY KEY,
    item_code VARCHAR(255),
    warehouse VARCHAR(255),
    posting_date DATE,
    voucher_type VARCHAR(255),
    voucher_no VARCHAR(255),
    actual_qty DECIMAL(18,2),
    qty_after_transaction DECIMAL(18,2),
    valuation_rate DECIMAL(18,6),
    stock_value DECIMAL(18,2),
    company VARCHAR(255)
);

----------------------------------------------------
-- No creamos foreign keys porque:
-- 1. Azure SQL revienta imports si no hay datos aún
-- 2. Dejamos las constraints para la Fase 3 (hardening)
----------------------------------------------------
