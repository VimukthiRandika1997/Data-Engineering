# Local Retail ETL Pipeline

A production-grade ETL pipeline using Apache Spark (PySpark) is shown here. The pipelien has the following features:

- Ingest raw retail sales data
- Cleans and validates data
- Compute key business KPIs
- Stores final findings in query-optimized format

## Use-case:

- Let's say a retail company wants to analyze daily sales trends across product categories to improve marketing strategies and inventory planning.

- Problem Statement: Turn raw data into business value

- Business Needs:

    - The data arrives from stores are inconsistent, containes duplicates and lacks a structure. The business needs reliable set of metrics from these raw data:

        - Daily Revenue
        - Top Selling Products
        - Montly Sales Trends 

- Technical Goals

    - Let's build a modular, reusable and scalable ETL pipeline:
        1. Ingests raw data
        2. Cleans and validates data quality
        3. Transform into a structured format
        4. Compute business KPIs
        5. Store output in columnar format(Parquet) for fast querying

## Project Structure:

This is a production-grade architecture to ensure maintainability and scalability.

```markdown
etl-pipeline/
│
|
├── data/                 → Input/output (raw, processed, metrics)
├── src/
|   |__ config/           → Spark configurations
│   ├── utils/            → Reusable functions (logging, file ops)
│   ├── ingestion/        → Load raw data
│   ├── transformation/   → Clean and validate
│   ├── metrics/          → Compute KPIs
│   └── main.py           → Orchestrate pipeline
├── tests/                → Unit & integration tests
├── requirements.txt      → Dependencies
└── README.md             → Documentation
```