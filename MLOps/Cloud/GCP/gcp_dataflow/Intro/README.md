# Introduction to DataFlow

## What is Dataflow

It's a fully managed, serverless service on GCP for executing data processing pipelines. This is based on **Apache Beam** which is a programming model for defining and executing bothe batch and streaming data processing pipelines.

## What is BigQuery

A **Serverless**, fully-managed **data warehouse** for analytics and business intelligence

Key features:

- Process petabytes of data with ease
- Supports SQL and integrates with GCP services
- Scalable with real-time data analytics
- Pay-as-you-go pricing based on queries and storage

Usage:

- Data lake analysis
- Marketing analystics and customer insights
- Business intelligence and reporting

### BigQuery Partitioning

It divides a large table into smaller, managble parts based on a column, improving query performance and reducing costs

Types of partitioning:

- **Time-based Partitioning** - Uses DATE, TIMESTAMP, or DATETIME columns
- **Integer Range Partitioning** - Divides data based on an integer column
- **Ingestion-time Partitioning** - Automatically partitions data based on the its arrival time

Benefits:

- Faster queries: scans only relevant partitions
- Lower costs: reduces data processed per query
- Efficient Data Management: simplifies handling large datasets

Best Practice: Always filter by partition column to optimize performance


### BigQuery Clustering

It organizes data within partitions based on specific columns' values, improving query performance and reducing costs.

How clustering works:

- Data is automatically sorted within each partition based on the clustered columns
- Queries that **filter**, **group_by**, or **aggregate** clustered columns run faster since BigQuery scans fewer blocks

Best Use Case:

- Use clustering when queries frequently **filter**, **group**, or **order by** certain columns

Benefits:

- Faster queries: scans only relevant partitions
- Lower costs: reduces data processed per query
- Efficient Data Management: simplifies handling large datasets

Best Practice: Combine Partitioning + Clustering for maximum efficiency


### BigQuery Federated Queries

- Federated queries let you send a query statement to **AllyDB, Spanner, or Cloud SQL** databases and get the result back as a temporary table

- It uses the BigQuery Connection API to establish a connection with **AllyDB, Spanner, or Cloud SQL** 