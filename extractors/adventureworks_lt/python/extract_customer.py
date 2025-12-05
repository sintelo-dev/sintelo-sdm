"""
Extractor Sintelo – AdventureWorksLT2025 (Demo Cliente)
Carga Customer desde Azure Blob → Azure SQL (raw_awlt.Customer)
"""

import os
import pandas as pd
import pyodbc
from azure.storage.blob import BlobServiceClient

# -------------------------
# 1. Configuración
# -------------------------

AZURE_STORAGE_CONNECTION_STRING = os.getenv("SINTEL0_STORAGE_CONNECTION")
CONTAINER = "raw"
FILE_NAME = "Customer.csv"

SQL_CONN = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=tcp:sintelodbserver.database.windows.net,1433;"
    "Database=AdventureWorksLT2025_Sample;"
    "Uid=sqladmin-sintelo;"
    f"Pwd={os.getenv('SINTEL0_SQL_ADMIN')};"
    "Encrypt=yes;TrustServerCertificate=no;"
)

TARGET_TABLE = "raw_awlt.Customer"

# -------------------------
# 2. Descargar CSV desde Blob
# -------------------------
def load_blob_csv():
    blob_client = BlobServiceClient.from_connection_string(
        AZURE_STORAGE_CONNECTION_STRING
    )
    blob = blob_client.get_blob_client(container=CONTAINER, blob=FILE_NAME)

    data = blob.download_blob().content_as_text()
    df = pd.read_csv(pd.compat.StringIO(data))

    print(f"[OK] Archivo {FILE_NAME} cargado desde Blob: {len(df)} filas")
    return df

# -------------------------
# 3. Cargar a SQL (truncate + insert)
# -------------------------
def load_to_sql(df):
    conn = pyodbc.connect(SQL_CONN)
    cursor = conn.cursor()

    cursor.execute(f"TRUNCATE TABLE {TARGET_TABLE}")

    insert_sql = f"""
    INSERT INTO {TARGET_TABLE} (
        CustomerID, NameStyle, Title, FirstName, MiddleName, LastName,
        Suffix, CompanyName, SalesPerson, EmailAddress, Phone,
        PasswordHash, PasswordSalt, rowguid, ModifiedDate
    )
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """

    for _, row in df.iterrows():
        cursor.execute(insert_sql, tuple(row))

    conn.commit()
    cursor.close()
    conn.close()

    print(f"[OK] Datos insertados en {TARGET_TABLE}: {len(df)} registros")


if __name__ == "__main__":
    df = load_blob_csv()
    load_to_sql(df)
    print("[DONE] Extractor ejecutado correctamente.")
