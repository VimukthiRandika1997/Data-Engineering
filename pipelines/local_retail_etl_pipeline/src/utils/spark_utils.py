"""
Initialize Spark session with logging and error handling.
"""

from pyspark.sql import SparkSession
import logging


def get_spark_session(app_name="RetailETL", config=None):
    """
    Create a Spark session with best practices.

    Args:
        app_name: application for monitoring
        config: dictionary of Spark  configurations
    Return:
        SparkSession, logger
    """

    builder = SparkSession.builder.appName(app_name)
    
    if config:
        for key, value in config.items():
            builder.config(key, value)
    
    spark = builder.getOrCreate()
    spark.sparkContext.setLogLevel("WARN")  # Avoid verbose logs
    
    # Setup logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(levelname)s] %(message)s',
        handlers=[logging.StreamHandler()]
    )
    logger = logging.getLogger(__name__)
    logger.info(f"🚀 Spark session initialized: {app_name}")

    return spark, logger