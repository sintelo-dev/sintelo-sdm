"""
Sintelo – Silver Transform (AdventureWorks2019 Demo, Cliente 9001)

Lee tablas Bronze (CSV) desde:
  one_lake/bronze/erp/9001_aw_manufacturing/<tabla>/data.csv

y escribe tablas Silver en:
  one_lake/silver/erp/9001_aw_manufacturing/<tabla>/data.csv

Tablas Silver v0.1:
  - dim_customer
  - dim_product
  - dim_date
  - fact_sales_orders
  - fact_inventory_movements
  - fact_workorders
"""

import os
from pathlib import Path
import pandas as pd

# -------------------------
# 1. Rutas base
# -------------------------

BASE_DIR = Path(__file__).resolve().parents[3]  # raíz del repo
BRONZE_ROOT = BASE_DIR / "one_lake" / "bronze" / "erp" / "9001_aw_manufacturing"
SILVER_ROOT = BASE_DIR / "one_lake" / "silver" / "erp" / "9001_aw_manufacturing"

SILVER_ROOT.mkdir(parents=True, exist_ok=True)
(SILVER_ROOT / "_metadata").mkdir(parents=True, exist_ok=True)

def bronze_path(table: str) -> Path:
    return BRONZE_ROOT / table / "data.csv"

def silver_path(table: str) -> Path:
    folder = SILVER_ROOT / table
    folder.mkdir(parents=True, exist_ok=True)
    return folder / "data.csv"

# -------------------------
# 2. Utilidades
# -------------------------

def load_bronze(table: str) -> pd.DataFrame:
    path = bronze_path(table)
    if not path.exists():
        raise FileNotFoundError(f"[Bronze] No existe {path}")
    df = pd.read_csv(path)
    print(f"[LOAD] {table}: {len(df)} filas desde {path}")
    return df

def write_silver(df: pd.DataFrame, table: str) -> None:
    path = silver_path(table)
    df.to_csv(path, index=False)
    print(f"[SAVE] {table}: {len(df)} filas → {path}")

def make_date_key(series: pd.Series) -> pd.Series:
    """
    Convierte una serie de fechas a clave entera YYYYMMDD.
    """
    s = pd.to_datetime(series).dt.date
    return s.apply(lambda d: d.year * 10000 + d.month * 100 + d.day)

# -------------------------
# 3. dim_product
# -------------------------

def build_dim_product() -> pd.DataFrame:
    product = load_bronze("product")
    subcat = load_bronze("productsubcategory")
    cat = load_bronze("productcategory")

    # Join product → subcategory → category
    dim = (
        product
        .merge(
            subcat[["ProductSubcategoryID", "Name", "ProductCategoryID"]],
            how="left",
            on="ProductSubcategoryID",
            suffixes=("", "_Subcategory")
        )
        .merge(
            cat[["ProductCategoryID", "Name"]],
            how="left",
            on="ProductCategoryID",
            suffixes=("", "_Category")
        )
    )

    dim_product = pd.DataFrame({
        "product_key": dim["ProductID"],
        "product_id": dim["ProductID"],
        "product_name": dim["Name"],
        "product_number": dim["ProductNumber"],
        "product_color": dim["Color"],
        "standard_cost": dim["StandardCost"],
        "list_price": dim["ListPrice"],
        "subcategory_id": dim["ProductSubcategoryID"],
        "subcategory_name": dim["Name_Subcategory"],
        "category_id": dim["ProductCategoryID"],
        "category_name": dim["Name_Category"],
    })

    return dim_product

# -------------------------
# 4. dim_customer
# -------------------------

def build_dim_customer() -> pd.DataFrame:
    customer = load_bronze("customer")
    person = load_bronze("person")

    # AdventureWorks: Customer.PersonID ↔ Person.BusinessEntityID (a veces null)
    dim = customer.merge(
        person,
        how="left",
        left_on="PersonID",
        right_on="BusinessEntityID",
        suffixes=("", "_Person")
    )

    full_name = (
        dim["FirstName"].fillna("")
        + " "
        + dim["LastName"].fillna("")
    ).str.strip()

    dim_customer = pd.DataFrame({
        "customer_key": dim["CustomerID"],
        "customer_id": dim["CustomerID"],
        "account_number": dim["AccountNumber"],
        "person_id": dim["PersonID"],
        "full_name": full_name,
        "first_name": dim["FirstName"],
        "last_name": dim["LastName"],
        "email_promotion": dim.get("EmailPromotion", pd.Series([None] * len(dim))),
    })

    return dim_customer

# -------------------------
# 5. dim_date
# -------------------------

def build_dim_date(sales_header: pd.DataFrame,
                   workorder: pd.DataFrame,
                   transactionhistory: pd.DataFrame) -> pd.DataFrame:
    dates = []

    for col in ["OrderDate", "DueDate", "ShipDate"]:
        if col in sales_header.columns:
            dates.append(pd.to_datetime(sales_header[col], errors="coerce"))

    if "StartDate" in workorder.columns:
        dates.append(pd.to_datetime(workorder["StartDate"], errors="coerce"))
    if "EndDate" in workorder.columns:
        dates.append(pd.to_datetime(workorder["EndDate"], errors="coerce"))

    if "TransactionDate" in transactionhistory.columns:
        dates.append(pd.to_datetime(transactionhistory["TransactionDate"], errors="coerce"))

    all_dates = pd.concat(dates).dropna().drop_duplicates().dt.date

    dim_date = pd.DataFrame({"date": sorted(all_dates)})
    dim_date["date_key"] = (
        dim_date["date"].apply(lambda d: d.year * 10000 + d.month * 100 + d.day)
    )
    dim_date["year"] = dim_date["date"].apply(lambda d: d.year)
    dim_date["month"] = dim_date["date"].apply(lambda d: d.month)
    dim_date["day"] = dim_date["date"].apply(lambda d: d.day)
    dim_date["month_name"] = dim_date["date"].apply(lambda d: d.strftime("%B"))
    dim_date["quarter"] = dim_date["date"].apply(lambda d: (d.month - 1) // 3 + 1)

    return dim_date

# -------------------------
# 6. fact_sales_orders
# -------------------------

def build_fact_sales_orders(sales_header: pd.DataFrame,
                            sales_detail: pd.DataFrame) -> pd.DataFrame:
    fact = sales_detail.merge(
        sales_header,
        how="left",
        on="SalesOrderID",
        suffixes=("_Detail", "_Header")
    )

    fact_sales = pd.DataFrame({
        "sales_order_id": fact["SalesOrderID"],
        "sales_order_detail_id": fact["SalesOrderDetailID"],
        "order_date": pd.to_datetime(fact["OrderDate"], errors="coerce"),
        "order_date_key": make_date_key(fact["OrderDate"]),
        "customer_key": fact["CustomerID"],
        "product_key": fact["ProductID"],
        "order_qty": fact["OrderQty"],
        "unit_price": fact["UnitPrice"],
        "unit_price_discount": fact.get("UnitPriceDiscount", 0),
        "line_total": fact.get("LineTotal", fact["OrderQty"] * fact["UnitPrice"]),
        "ship_date": pd.to_datetime(fact.get("ShipDate"), errors="coerce"),
        "due_date": pd.to_datetime(fact.get("DueDate"), errors="coerce"),
        "status": fact.get("Status"),
        "online_order_flag": fact.get("OnlineOrderFlag"),
    })

    return fact_sales

# -------------------------
# 7. fact_inventory_movements
# -------------------------

def build_fact_inventory_movements(transactionhistory: pd.DataFrame) -> pd.DataFrame:
    fact_inv = pd.DataFrame({
        "transaction_id": transactionhistory["TransactionID"],
        "product_key": transactionhistory["ProductID"],
        "transaction_date": pd.to_datetime(transactionhistory["TransactionDate"],
                                           errors="coerce"),
        "transaction_date_key": make_date_key(transactionhistory["TransactionDate"]),
        "quantity": transactionhistory["Quantity"],
        "actual_cost": transactionhistory["ActualCost"],
        "transaction_type": transactionhistory["TransactionType"],
    })

    return fact_inv

# -------------------------
# 8. fact_workorders
# -------------------------

def build_fact_workorders(workorder: pd.DataFrame) -> pd.DataFrame:
    fact_wo = pd.DataFrame({
        "workorder_id": workorder["WorkOrderID"],
        "product_key": workorder["ProductID"],
        "order_qty": workorder["OrderQty"],
        "stocked_qty": workorder.get("StockedQty", workorder["OrderQty"]),
        "scrapped_qty": workorder["ScrappedQty"],
        "start_date": pd.to_datetime(workorder["StartDate"], errors="coerce"),
        "start_date_key": make_date_key(workorder["StartDate"]),
        "end_date": pd.to_datetime(workorder.get("EndDate"), errors="coerce"),
        "due_date": pd.to_datetime(workorder.get("DueDate"), errors="coerce"),
        "scrap_reason_id": workorder.get("ScrapReasonID"),
    })

    return fact_wo

# -------------------------
# 9. Metadata de Silver
# -------------------------

def write_metadata(metadata_rows):
    meta_path = SILVER_ROOT / "_metadata" / "silver_export_metadata.csv"
    df_meta = pd.DataFrame(metadata_rows)
    df_meta.to_csv(meta_path, index=False)
    print(f"[META] Metadata escrita en {meta_path}")

# -------------------------
# 10. Main
# -------------------------

def main():
    print("→ Construyendo tablas Silver (AdventureWorks2019, Cliente 9001)...")

    # Cargar fuentes Bronze necesarias
    sales_header = load_bronze("salesorderheader")
    sales_detail = load_bronze("salesorderdetail")
    customer = load_bronze("customer")
    product = load_bronze("product")
    productcategory = load_bronze("productcategory")
    productsubcategory = load_bronze("productsubcategory")
    person = load_bronze("person")
    transactionhistory = load_bronze("transactionhistory")
    workorder = load_bronze("workorder")

    # Construir dimensiones
    dim_product = build_dim_product()
    write_silver(dim_product, "dim_product")

    dim_customer = build_dim_customer()
    write_silver(dim_customer, "dim_customer")

    dim_date = build_dim_date(sales_header, workorder, transactionhistory)
    write_silver(dim_date, "dim_date")

    # Construir hechos
    fact_sales = build_fact_sales_orders(sales_header, sales_detail)
    write_silver(fact_sales, "fact_sales_orders")

    fact_inv = build_fact_inventory_movements(transactionhistory)
    write_silver(fact_inv, "fact_inventory_movements")

    fact_wo = build_fact_workorders(workorder)
    write_silver(fact_wo, "fact_workorders")

    # Metadata
    meta_rows = [
        {"table": "dim_product", "rows": len(dim_product)},
        {"table": "dim_customer", "rows": len(dim_customer)},
        {"table": "dim_date", "rows": len(dim_date)},
        {"table": "fact_sales_orders", "rows": len(fact_sales)},
        {"table": "fact_inventory_movements", "rows": len(fact_inv)},
        {"table": "fact_workorders", "rows": len(fact_wo)},
    ]
    write_metadata(meta_rows)

    print("\n[DONE] Silver transform finalizado correctamente.")

if __name__ == "__main__":
    main()
