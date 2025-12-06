"""
Extractor Bronze Institucional – Sintelo Data Platform
ERP OLTP → OneLake (Bronze Layer)
Cliente: 9001 (AdventureWorks Manufacturing)

Este extractor:
1. Se conecta a SQL Server OLTP (Docker).
2. Extrae tablas clave del ERP operativo.
3. Guarda cada tabla en Parquet particionado por fecha de extracción.
"""

import os
import pandas as pd
import pyodbc
from datetime import datetime
import pyarrow as pa
import pyarrow.parquet as pq

# ----------------------------------------------------
# 1. CONFIGURACIÓN GENERAL
# ----------------------------------------------------

SERVER = "localhost,1433"
DATABASE = "AdventureWorks2022"
USERNAME = "SA"
PASSWORD = "YourStrong!Passw0rd"  # puedes moverlo a env si quieres

BASE_OUTPUT = "one_lake/bronze/erp/9001_aw_manufacturing"

TABLES = [
    ("Sales", "SalesOrderHeader"),
    ("Sales", "SalesOrderDetail"),
    ("Sales", "Customer"),
    ("Sales", "SalesOrderHeaderSalesReason"),
    ("Sales", "SalesReason"),
    ("Person", "Person"),
    ("Person", "EmailAddress"),
    ("Production", "Product"),
    ("Production", "ProductCategory"),
    ("Production", "ProductSubcategory"),
    ("Production", "WorkOrder"),
    ("Purchasing", "PurchaseOrderHeader"),
    ("Purchasing", "PurchaseOrderDetail"),
    ("Production", "TransactionHistory"),
]

# ----------------------------------------------------
# 2. CONEXIÓN SQL SERVER
# ----------------------------------------------------

def get_connection():
    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID={USERNAME};"
        f"PWD={PASSWORD};"
        "Encrypt=no;"
        "TrustServerCertificate=yes;"
    )
    return conn


# ----------------------------------------------------
# 3. FUNCIONES UTILITARIAS
# ----------------------------------------------------

def ensure_dir(path: str):
    """Crea la carpeta si no existe."""
    os.makedirs(path, exist_ok=True)


def export_table_to_parquet(schema: str, table: str, cursor):
    """Extrae una tabla SQL → Parquet (OneLake Bronze)."""

    print(f"\n[EXTRACT] {schema}.{table}")

    # 1) Ejecutar SELECT * FROM schema.table
    query = f"SELECT * FROM {schema}.{table}"
    df = pd.read_sql(query, cursor.connection)

    print(f"[ROWS] {len(df):,} registros extraídos.")

    # 2) Convertir a Arrow Table
    table_arrow = pa.Table.from_pandas(df)

    # 3) Destino institucional
    today = datetime.now().strftime("%Y-%m-%d")
    output_dir = f"{BASE_OUTPUT}/{table.lower()}/{today}"
    ensure_dir(output_dir)

    file_path = f"{output_dir}/{table.lower()}.parquet"

    # 4) Guardar en Parquet
    pq.write_table(table_arrow, file_path)

    print(f"[PARQUET] Guardado en: {file_path}")


# ----------------------------------------------------
# 4. MAIN PIPELINE
# ----------------------------------------------------

if __name__ == "__main__":
    print("\n===== EXTRACTOR BRONZE – SINTÉTICO OLTP → ONELAKE =====")

    conn = get_connection()
    cursor = conn.cursor()

    for schema, table in TABLES:
        try:
            export_table_to_parquet(schema, table, cursor)
        except Exception as e:
            print(f"[ERROR] {schema}.{table} → {str(e)}")

    cursor.close()
    conn.close()

    print("\n[DONE] Extracción Bronze completada.\n")
