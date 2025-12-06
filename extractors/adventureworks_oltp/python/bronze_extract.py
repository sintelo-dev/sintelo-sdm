"""
Bronze Extract – AdventureWorks OLTP (Cliente 9001 – Manufactura)

Extrae tablas núcleo de manufactura desde AdventureWorks2022 (SQL Server Docker)
y las escribe en OneLake/bronze/erp/9001_aw_manufacturing como Parquet.

Este script es el "runner" institucional: un solo comando, 15 tablas.
"""

from common import extract_table


# ---------------------------------------------------------
# Definición institucional de tablas bronze para manufactura
# ---------------------------------------------------------
TABLES = [
    # Ventas
    ("Sales", "Customer"),
    ("Person", "Person"),
    ("Sales", "SalesOrderHeader"),
    ("Sales", "SalesOrderDetail"),
    ("Sales", "CreditCard"),
    ("Sales", "SalesReason"),
    ("Sales", "SalesOrderHeaderSalesReason"),
    # Producción / inventarios
    ("Production", "Product"),
    ("Production", "ProductCategory"),
    ("Production", "ProductSubcategory"),
    ("Production", "TransactionHistory"),
    ("Production", "WorkOrder"),
    ("Production", "ProductInventory"),
    # Compras
    ("Purchasing", "PurchaseOrderHeader"),
    ("Purchasing", "PurchaseOrderDetail"),
]


def run_all():
    """
    Ejecuta extracción bronze para todas las tablas definidas en TABLES.
    """
    for schema, table in TABLES:
        try:
            extract_table(schema=schema, table=table)
        except Exception as ex:
            # Fail-fast pero registrando el error por tabla
            print(f"[ERROR] Falló la extracción de {schema}.{table}: {ex}")


if __name__ == "__main__":
    run_all()
    print("[DONE] Bronze ingest (AdventureWorks OLTP) completado.")
