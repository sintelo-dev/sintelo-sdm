"""
Common utilities for Sintelo Bronze Ingestion (AdventureWorks OLTP)

- Conexión institucional a SQL Server (Docker local)
- Escritura a OneLake (bronze) en formato Parquet
"""

import os
from datetime import date
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

# -------------------------------------------------------------------
# 1. Configuración institucional (overrideable por variables de entorno)
# -------------------------------------------------------------------

SQL_SERVER = os.getenv("SINTEL0_SQL_HOST", "localhost,1433")
SQL_DB = os.getenv("SINTEL0_SQL_DB", "AdventureWorks2022")
SQL_USER = os.getenv("SINTEL0_SQL_USER", "SA")
SQL_PWD = os.getenv("SINTEL0_SQL_PWD", "YourStrong!Passw0rd")
SQL_DRIVER = os.getenv("SINTEL0_SQL_DRIVER", "ODBC Driver 18 for SQL Server")

# Raíz institucional del cliente demo en OneLake (bronze)
BRONZE_ROOT = Path("one_lake/bronze/erp/9001_aw_manufacturing")


def make_engine():
    """
    Crea un engine SQLAlchemy hacia SQL Server (Docker local)
    usando el driver ODBC 18 y cifrado (TrustServerCertificate para dev).
    """
    driver_enc = SQL_DRIVER.replace(" ", "+")
    conn_str = (
        f"mssql+pyodbc://{SQL_USER}:{SQL_PWD}@{SQL_SERVER}/{SQL_DB}"
        f"?driver={driver_enc}&Encrypt=yes&TrustServerCertificate=yes"
    )
    print(f"[INFO] Conectando a SQL Server: {SQL_SERVER} / DB={SQL_DB}")
    return create_engine(conn_str, fast_executemany=True)


def save_to_parquet(df: pd.DataFrame, table_name: str):
    """
    Guarda el DataFrame en OneLake/bronze en formato Parquet,
    particionado por fecha de extracción (YYYY-MM-DD).
    """
    today = date.today().isoformat()  # e.g. 2025-12-06
    table_dir = BRONZE_ROOT / table_name.lower() / today
    table_dir.mkdir(parents=True, exist_ok=True)

    out_path = table_dir / f"{table_name.lower()}.parquet"
    df.to_parquet(out_path, index=False)

    print(f"[OK] {table_name}: {len(df)} filas -> {out_path}")


def extract_table(schema: str, table: str, where_clause: str | None = None):
    """
    Extrae una tabla completa (o con filtro opcional) desde SQL Server
    y la escribe en OneLake/bronze como Parquet.

    :param schema: Esquema (ej. 'Sales', 'Production', 'Person', 'Purchasing')
    :param table:  Nombre de tabla (ej. 'Customer', 'SalesOrderHeader')
    :param where_clause: SQL opcional, SIN la palabra WHERE (ej. 'OrderDate >= ...')
    """
    full_name = f"{schema}.{table}"

    engine = make_engine()
    sql = f"SELECT * FROM {full_name}"
    if where_clause:
        sql += f" WHERE {where_clause}"

    print(f"[RUN] Extrayendo {full_name} ...")
    with engine.connect() as conn:
        df = pd.read_sql(text(sql), conn)

    print(f"[OK] {full_name}: {len(df)} filas extraídas")
    save_to_parquet(df, table)
