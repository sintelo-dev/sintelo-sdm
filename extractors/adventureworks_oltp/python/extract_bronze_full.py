"""
Extractor Bronze Sintelo – AdventureWorks OLTP (Demo Cliente 9001)

Objetivo:
- Leer tablas clave de AdventureWorks2019 (OLTP) en SQL Server local
- Escribir cada tabla como CSV en el "One Lake" local:
  one_lake/bronze/erp/9001_aw_manufacturing/<tabla>/data.csv

Requisitos:
- Contenedor Docker con SQL Server levantado y AdventureWorks2019 restaurado
- Variable de entorno: SINTEL0_SQL_LOCAL_CONN
  Ejemplo:
  Driver={ODBC Driver 18 for SQL Server};Server=localhost,1433;Database=AdventureWorks2019;Uid=SA;Pwd=YourStrong!Passw0rd;TrustServerCertificate=yes;
"""

import os
import datetime as dt
import pandas as pd
import pyodbc

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ONE_LAKE_ROOT = os.path.join(BASE_DIR, "one_lake", "bronze", "erp", "9001_aw_manufacturing")

SQL_CONN = os.getenv("SINTEL0_SQL_LOCAL_CONN")

TABLES = {
    # Ventas
    "Sales.SalesOrderHeader": "salesorderheader",
    "Sales.SalesOrderDetail": "salesorderdetail",
    "Sales.Customer": "customer",
    "Sales.SalesOrderHeaderSalesReason": "salesorderheadersalesreason",
    "Sales.SalesReason": "salesreason",
    "Sales.CreditCard": "creditcard",

    # Producto
    "Production.Product": "product",
    "Production.ProductCategory": "productcategory",
    "Production.ProductSubcategory": "productsubcategory",
    "Production.TransactionHistory": "transactionhistory",
    "Production.WorkOrder": "workorder",
    "Production.ProductInventory": "inventory",

    # Compras
    "Purchasing.PurchaseOrderHeader": "purchaseorderheader",
    "Purchasing.PurchaseOrderDetail": "purchaseorderdetail",

    # Personas
    "Person.Person": "person",
}


def log(msg: str) -> None:
    ts = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{ts}] {msg}")


def ensure_directories() -> None:
    os.makedirs(ONE_LAKE_ROOT, exist_ok=True)
    os.makedirs(os.path.join(ONE_LAKE_ROOT, "_metadata"), exist_ok=True)
    for folder in set(TABLES.values()):
        os.makedirs(os.path.join(ONE_LAKE_ROOT, folder), exist_ok=True)


def export_table_to_csv(cursor, full_table_name: str, folder_name: str) -> dict:
    """
    Exporta una tabla completa a CSV en su carpeta correspondiente.
    Retorna un dict con metadatos (tabla, filas, ruta).
    """
    schema, table = full_table_name.split(".")
    target_dir = os.path.join(ONE_LAKE_ROOT, folder_name)
    target_path = os.path.join(target_dir, "data.csv")

    log(f"→ Extrayendo {full_table_name} ...")
    df = pd.read_sql(f"SELECT * FROM {full_table_name}", cursor.connection)

    row_count = len(df)
    log(f"   {full_table_name}: {row_count} filas")

    # Escribir CSV
    df.to_csv(target_path, index=False)
    log(f"   Escrito: {target_path}")

    return {
        "schema": schema,
        "table": table,
        "full_table_name": full_table_name,
        "target_folder": folder_name,
        "file_path": target_path,
        "rows": row_count,
        "export_timestamp": dt.datetime.now().isoformat(),
    }


def write_metadata(metadata_rows):
    meta_df = pd.DataFrame(metadata_rows)
    meta_path = os.path.join(ONE_LAKE_ROOT, "_metadata", "bronze_export_metadata.csv")
    meta_df.to_csv(meta_path, index=False)
    log(f"[OK] Metadatos escritos en {meta_path}")


def main():
    if not SQL_CONN:
        raise RuntimeError(
            "La variable de entorno SINTEL0_SQL_LOCAL_CONN no está definida. "
            "Configúrala con la cadena de conexión ODBC a AdventureWorks2019."
        )

    log("Iniciando extracción Bronze AdventureWorks2019 → One Lake local")
    log(f"ONE_LAKE_ROOT = {ONE_LAKE_ROOT}")

    ensure_directories()

    conn = pyodbc.connect(SQL_CONN)
    cursor = conn.cursor()

    metadata_rows = []

    for full_table, folder in TABLES.items():
        try:
            meta = export_table_to_csv(cursor, full_table, folder)
            metadata_rows.append(meta)
        except Exception as e:
            log(f"[ERROR] Falló la extracción de {full_table}: {e}")

    cursor.close()
    conn.close()

    if metadata_rows:
        write_metadata(metadata_rows)
        total_rows = sum(m["rows"] for m in metadata_rows)
        log(f"[DONE] Extracción Bronze completada. Tablas: {len(metadata_rows)}, Filas totales: {total_rows}")
    else:
        log("[WARN] No se exportó ninguna tabla. Revisa logs anteriores.")


if __name__ == "__main__":
    main()
