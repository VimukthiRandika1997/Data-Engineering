"""
Main ETL orchestration script.
Executes the full pipeline: Extract → Transform → Load → Metrics.
"""
from utils.spark_utils import get_spark_session
from utils.file_utils import ensure_dir
from ingestion.data_loader import load_json_data
from transformation.data_cleaner import clean_sales_data
from metrics.business_metrics import *
from config.spark_config import SPARK_CONFIG
import logging


# Paths
RAW_PATH = "data/raw/"
PROCESSED_PATH = "data/processed/cleaned_sales"
METRICS_DIR = "data/metrics/"

def run_pipeline():
    spark, logger = get_spark_session("RetailSalesETL", SPARK_CONFIG)
    
    try:
        # 1. Extract: Load raw data
        logger.info("📦 Loading raw sales data...")
        raw_df = load_json_data(spark, RAW_PATH)
        raw_df.printSchema()

        # 2. Transform: Clean and validate
        logger.info("🧹 Cleaning and validating data...")
        cleaned_df = clean_sales_data(raw_df)
        cleaned_df.cache().count()  # Cache for reuse

        # 3. Load: Save cleaned data
        logger.info("💾 Saving cleaned data in Parquet...")
        ensure_dir(PROCESSED_PATH)
        cleaned_df.write.mode("overwrite").parquet(PROCESSED_PATH)

        # 4. Metrics: Compute KPIs
        logger.info("📊 Generating business intelligence...")
        metrics = {
            "daily_revenue": compute_daily_revenue(cleaned_df),
            "top_products": compute_top_products(cleaned_df),
            "store_performance": compute_store_performance(cleaned_df),
            "monthly_trends": compute_monthly_trends(cleaned_df)
        }

        # Save all metrics
        ensure_dir(METRICS_DIR)
        for name, df in metrics.items():
            path = f"{METRICS_DIR}/{name}"
            df.write.mode("overwrite").parquet(path)
            logger.info(f"📈 Saved metric: {name} → {path}")

        logger.info("🎉 ETL Pipeline completed successfully!")

    except Exception as e:
        logger.error(f"💥 Pipeline failed: {str(e)}")
        raise
    finally:
        spark.stop()
        logger.info("🔚 Spark session terminated.")

if __name__ == "__main__":
    run_pipeline()