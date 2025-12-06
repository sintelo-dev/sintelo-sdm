"""
Extractor Sintelo – OLTP → OneLake Bronze
Tabla: Sales.Customer (AdventureWorks OLTP)
Cliente: 9001 – AW Manufacturing Demo

Este extractor lee directamente del SQL OLTP y deposita el resultado crudo
en el OneLake institucional, estructura Bronze.
"""

import os
import pandas as pd
import pyodbc
import json
from datetime import datetime

# ============================================================
# CONFIGURACIÓN INSTITUCIONAL
# ============================================================

# Conexión SQL OLTP
SQL_SERVER = "sintelodbserver.database.windows.net"
SQL_DB = "AdventureWorks2022"   # OLTP real
SQL_USER = "sqladmin-sintelo"
SQL_PASSWORD = os.getenv("SINTEL0_SQL_ADMIN")  # exportado en tu shell

# Tabla fuente OLTP
SOURCE_TABLE = "Sales.Customer"

# Path Bronze institucional
BRONZE_BASE = "one_lake/bronze/erp/9001_aw_manufacturing/customer/"

# Metadata path
METADATA_BASE = "one_lake/bronze/erp/9001_aw_manufacturing/_metadata/"

# Timestamp institucional
ts = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")


# ============================================================
# 1. Conectar a SQL OLTP
# ============================================================
def get_sql_connection():
    conn_str = (
        f"Driver={{ODBC Driver 18 for SQL Server}};"
        f"Server=tcp:{SQL_SERVER},1433;"
        f"Database={SQL_DB};"
        f"UID={SQL_USER};"
        f"PWD={SQL_PASSWORD};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )
    return pyodbc.connect(conn_str)


# ============================================================
# 2. Leer datos desde OLTP
# ============================================================
def extract_customer_from_oltp():
    query = f"SELECT * FROM {SOURCE_TABLE};"
    print(f"[EXTRACT] Ejecutando query OLTP → {SOURCE_TABLE}")

    conn = get_sql_connection()
    df = pd.read_sql(query, conn)
    conn.close()

    print(f"[EXTRACT] Filas extraídas: {len(df)}")
    return df


# ============================================================
# 3. Escribir en BRONZE como CSV crudo
# ============================================================
def write_to_bronze(df):
    os.makedirs(BRONZE_BASE, exist_ok=True)

    output_file = f"{BRONZE_BASE}{ts}.csv"
    df.to_csv(output_file, index=False)

    print(f"[BRONZE] Archivo generado: {output_file}")
    return output_file


# ============================================================
# 4. Escribir metadata institucional
# ============================================================
def write_metadata(row_count, file_path):
    os.makedirs(METADATA_BASE, exist_ok=True)

    metadata = {
        "table": SOURCE_TABLE,
        "rows": row_count,
        "file": file_path,
        "timestamp_utc": ts,
        "source": "AdventureWorks OLTP",
        "layer": "bronze",
        "ingested_by": "Sintelo Data Platform"
    }

    meta_file = f"{METADATA_BASE}customer_{ts}.json"

    with open(meta_file, "w") as f:
        json.dump(metadata, f, indent=4)

    print(f"[METADATA] Metadata escrita: {meta_file}")


# ============================================================
# MAIN PIPELINE
# ============================================================
if __name__ == "__main__":
    df = extract_customer_from_oltp()
    file_path = write_to_bronze(df)
    write_metadata(len(df), file_path)

    print("\n[SUCCESS] ETL OLTP → BRONZE completado para Sales.Customer.")
