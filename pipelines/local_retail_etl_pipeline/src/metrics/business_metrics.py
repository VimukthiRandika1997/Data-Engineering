"""
Generate business intelligence from cleaned data.
"""

from pyspark.sql import DataFrame
from pyspark.sql.functions import sum, count, avg, desc, col, date_format


def compute_daily_revenue(df: DataFrame) -> DataFrame:
    """Total sales per day: This is for cash flow and trend analysis
    """

    return df.groupBy("sale_date") \
            .agg(sum("total_amount").alias("daily_revenue")) \
            .orderBy("sale_date")


def compute_top_products(df: DataFrame, top_n: int = 5) -> DataFrame:
    """Identify best-selling products: This is for inventory and marketing"""

    return df.groupBy("product") \
            .agg(
                sum("total_amount").alias("product_revenue"),
                sum("quantity").alias("total_units_sold")
            ) \
            .orderBy(desc("product_revenue")) \
            .limit(top_n)


def compute_store_performance(df: DataFrame) -> DataFrame:
    """Evaluate store efficiency: This is for operational decisions"""

    return df.groupBy("store_id", "city") \
            .agg(
                sum('total_amount').alias("revenue"),
                count("transaction_id").alias("transactions"),
                avg("total_amount").alias("avg_order_value")
            ) \
            .orderBy(desc("revenue"))


def compute_monthly_trends(df: DataFrame) -> DataFrame:
    """Monthly revenue trends: This is for forecasting and planning"""

    return df.withColumn("month", date_format(col("sale_date"), "yyyy-MM")) \
            .groupBy("month") \
            .agg(sum("total_amount").alias("monthly_revenue")) \
            .orderBy("month")