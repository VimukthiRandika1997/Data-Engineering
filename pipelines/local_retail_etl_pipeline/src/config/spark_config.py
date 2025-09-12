"""
Centralized Spark configuration for performance tuning.
Optimized for batch processing on local or cluster mode.
"""

SPARK_CONFIG = {
    "spark.app.name": "RetailSalesETLPipeline",
    "spark.sql.adaptive.enabled": "true",                               # Auto-optimize query plans
    "spark.sql.adaptive.coalescePartitions.enabled": "true",            # Reduce small files
    "spark.sql.parquet.compression.codec": "snappy",                    # Efficient storage
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer",   # Faster serialization
    "spark.sql.sources.partitionOverwriteMode": "dynamic"               # Safe overwrite in partitioned writes
}