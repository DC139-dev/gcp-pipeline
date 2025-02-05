provider "google" {
  credentials = file("terraform-key.json")
  project = var.project_id
  region  = var.region
}

# Google Cloud Storage Bucket
resource "google_storage_bucket" "data_bucket" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = true  # Allows deletion of non-empty buckets (use with caution)
}

# Google BigQuery Dataset
resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id = var.bigquery_dataset
  project    = var.project_id
  location   = var.region
}

# Google BigQuery Table with Auto-Detect Schema
resource "google_bigquery_table" "bq_table" {
  dataset_id = google_bigquery_dataset.bq_dataset.dataset_id
  table_id   = var.bigquery_table
  project    = var.project_id

  # Leave the schema as null for auto-detection
  schema = null

  # Define the external data source (CSV from GCS)
  external_data_configuration {
    source_format = "CSV"
    source_uris   = [
      "gs://${google_storage_bucket.data_bucket.name}/path/to/your/file.csv"  # Dynamic reference to GCS bucket
    ]
    autodetect    = true
  }
}

# # Output GCS Bucket Name
# output "gcs_bucket" {
#   value = google_storage_bucket.data_bucket.name
# }

# # Output BigQuery Table ID
# output "bigquery_table" {
#   value = google_bigquery_table.bq_table.table_id
# }


# Create Dataproc Cluster
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = var.dataproc_cluster
  region = var.region

  cluster_config {
    staging_bucket = google_storage_bucket.gcs_bucket.name

    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 100
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 100
      }
    }

    software_config {
      image_version = "2.1-debian11"
      optional_components = ["JUPYTER"]
    }
  }

  labels = {
    environment = "production"
  }
}

# Create Cloud Composer Environment
resource "google_composer_environment" "composer_env" {
  name   = var.composer_env_name
  region = var.region

  config {
    software_config {
      image_version = "composer-2.1.3-airflow-2.5.1"
      env_variables = {
        GCS_BUCKET = google_storage_bucket.gcs_bucket.name
      }
    }
  }
}

# Extract DAG bucket from Composer
output "composer_dag_bucket" {
  value = google_composer_environment.composer_env.config[0].dag_gcs_prefix
}

# Upload DAG to Composer automatically
resource "null_resource" "upload_dag" {
  depends_on = [google_composer_environment.composer_env]

  provisioner "local-exec" {
    command = <<EOT
    BUCKET_NAME=$(gcloud composer environments describe ${var.composer_env_name} --location=${var.region} --format="value(config.dagGcsPrefix)")
    gsutil cp dags/gcs_to_bq_dag.py $BUCKET_NAME
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
