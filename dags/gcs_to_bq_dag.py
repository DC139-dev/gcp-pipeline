from airflow import DAG
from airflow.providers.google.cloud.operators.gcs import GCSObjectUpdatedSensor
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitJobOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.utils.dates import days_ago
from conf import CONFIG

dag = DAG(
    "gcs_to_bq_pipeline",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
)

gcs_sensor = GCSObjectUpdatedSensor(
    task_id="wait_for_gcs_file",
    bucket=CONFIG["GCS_BUCKET"],
    poke_interval=CONFIG["POKE_INTERVAL"],
    timeout=CONFIG["TIMEOUT"],
    dag=dag,
)

spark_job = {
    "reference": {"project_id": CONFIG["BIGQUERY_PROJECT_ID"]},
    "placement": {"cluster_name": CONFIG["DATAPROC_CLUSTER_NAME"]},
    "pyspark_job": {
        "main_python_file_uri": CONFIG["SPARK_SCRIPT_PATH"],
        "args": [CONFIG["INPUT_CSV_PATH"], CONFIG["OUTPUT_PARQUET_PATH"]],
    },
}

dataproc_operator = DataprocSubmitJobOperator(
    task_id="run_spark_job",
    job=spark_job,
    region=CONFIG["DATAPROC_REGION"],
    project_id=CONFIG["BIGQUERY_PROJECT_ID"],
    dag=dag,
)

load_bq_job = BigQueryInsertJobOperator(
    task_id="load_parquet_to_bq",
    configuration={
        "load": {
            "sourceUris": [CONFIG["OUTPUT_PARQUET_PATH"]],
            "destinationTable": {
                "projectId": CONFIG["BIGQUERY_PROJECT_ID"],
                "datasetId": CONFIG["BIGQUERY_DATASET"],
                "tableId": CONFIG["BIGQUERY_TABLE"],
            },
            "sourceFormat": "PARQUET",
        }
    },
    dag=dag,
)

gcs_sensor >> dataproc_operator >> load_bq_job
