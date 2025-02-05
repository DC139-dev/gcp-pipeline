output "gcs_bucket" {
  value = google_storage_bucket.data_bucket.name
}

output "dataproc_cluster" {
  value = google_dataproc_cluster.dataproc_cluster.name
}

output "composer_env" {
  value = google_composer_environment.composer_env.name
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.bq_dataset.dataset_id
}

output "bigquery_table" {
  value = google_bigquery_table.bq_table.table_id
}
