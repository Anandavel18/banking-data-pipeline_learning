# provider "google" {
 #  project = var.project_id
  # region  = var.region
# }

# -----------------------------------
# Create GCP Project
# -----------------------------------
#resource "google_project" "project" {
 # project_id      = var.project_id
 # name            = var.project_name
  #billing_account = var.billing_account

  #labels = {
 #   environment = "dev"
  #  managed_by  = "terraform"
 # }
#}

# -----------------------------------
# Enable Required APIs
# -----------------------------------
#resource "google_project_service" "services" {
  #for_each = toset([
    #"bigquery.googleapis.com",
   # "storage.googleapis.com",
   # "iam.googleapis.com"
 # ])

 # project = google_project.project.project_id
 # service = each.key

 # disable_on_destroy = false
#}

# -----------------------------------
# BigQuery Dataset
# -----------------------------------
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  location   = var.region

  delete_contents_on_destroy = true

  labels = {
    env = "dev"
  }
}

# -----------------------------------
# Storage Bucket
# -----------------------------------
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    env = "dev"
  }
}

resource "google_bigquery_dataset" "arch_banking" {
  dataset_id = "arch_banking"
  location   = var.region
}

resource "google_bigquery_dataset" "cc_banking" {
  dataset_id = "cc_banking"
  location   = var.region
}

resource "google_bigquery_dataset" "tf_banking" {
  dataset_id = "tf_banking"
  location   = var.region
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "banking_analytics"
  location   = var.region
}

# -----------------------------------
# IAM Roles
# -----------------------------------

resource "google_project_iam_member" "bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "user:${var.user_email}"
}
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "user:${var.user_email}"
}