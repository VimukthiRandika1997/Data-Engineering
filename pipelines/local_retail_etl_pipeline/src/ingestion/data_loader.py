"""
Load raw JSON data from file system.
Handles malformed records gracefully.
"""

from pyspark.sql import DataFrame, SparkSession
from utils.file_utils import list_files
import logging

def load_json_data(spark: SparkSession, input_path: str) -> DataFrame:
    """
    Read JSON files with schema inference and error tolerance.
    Args:
        spark: active spark session 
        input_path: path to raw data
    Returns:
        DataFrame
    """

    try:
        df = spark.read \
            .option("mode", "DROPMALFORMED") \
            .option("columnNameOfCorruptRecord", "_corrupt_record") \
            .json(input_path)
        
        raw_count = df.count()
        logging.info(f"📥 Successfully loaded {raw_count} records from {input_path}")
        return df
    except Exception as e:
        logging.error(f"❌ Failed to read data from {input_path}: {str(e)}")
        raise

# DROPMALFORMED ensures pipeline resilience