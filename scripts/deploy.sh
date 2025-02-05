#!/bin/bash

# Load configurations
GCS_BUCKET="emp_data11"

# Upload DAG to Cloud Composer DAGs bucket
gsutil cp dags/gcs_to_bq_dag.py gs://$GCS_BUCKET/dags/

# Upload Spark script to GCS
gsutil cp spark_jobs/spark_csv_to_parquet.py gs://$GCS_BUCKET/spark_jobs/

echo "Deployment completed!"
