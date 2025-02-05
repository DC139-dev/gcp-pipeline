variable "gcs_bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
  default     = "my-unique-gcs-bucket-123"  # Replace with a unique name
}

variable "bigquery_dataset" {
  description = "The name of the BigQuery dataset"
  type        = string
  default     = "employee_dataset"  # Replace with your desired dataset name
}

variable "bigquery_table" {
  description = "The name of the BigQuery table"
  type        = string
  default     = "my_bigquery_table"  # Default name for the table
}

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP Region"
  type        = string
}

variable "dataproc_cluster" {
  description = "Dataproc cluster name"
  type        = string
}

variable "composer_env_name" {
  description = "Cloud Composer environment name"
  type        = string
}
