"""
Data cleaning and validation layer: ensures data quality before analytics
"""

from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when, current_timestamp
from pyspark.sql.types import *

SCHEMA = StructType([
    StructField("transaction_id", IntegerType(), True),
    StructField("product", StringType(), True),
    StructField("category", StringType(), True),
    StructField("quantity", IntegerType(), True),
    StructField("price_per_unit", DoubleType(), True),
    StructField("total_amount", DoubleType(), True),
    StructField("store_id", StringType(), True),
    StructField("city", StringType(), True),
    StructField("sale_date", StringType(), True),
    StructField("sales_rep", StringType(), True),
])


def clean_sales_data(df: DataFrame) -> DataFrame:
    """
    Apply data quality rules:
        - Schema enforcement 
        - Null handling
        - Duplicate removal
        - Business logic validation
    """

    log = __import__("logging").getLogger(__name__)

    # Schema enforcement
    df = df.select([col(f.name).cast(f.dataType) for f in SCHEMA])

    # Convert string date to DataType
    df = df.withColumn("sale_date", col("sale_date").cast("date"))

    # Fill missing values with defaults
    df = df.fillna({
        "quantity": 1,
        "price_per_unit": 0.0,
        "total_amount": 0.0,
        "product": "Unknown",
        "store_id": "Unknown",
        "city": "Unknown"
    })

    # Fixing inconsistencies
    expected_total = col("quantity") * col("price_per_unit")
    df = df.withColumn(
        "total_amount",
        when(col("total_amount") != expected_total, expected_total)
        .otherwise(col("total_amount"))
    )

    # Remove duplicates
    initial = df.count()
    df = df.dropDuplicates(["transaction_id"])
    final = df.count()
    log.info(f"🧹 Removed {initial - final} duplicate transactions.")

    # Add audit trail
    df = df.withColumn("ingested_at", current_timestamp())

    log.info(f"✅ Cleaned dataset contains {final} valid records.")
    return df