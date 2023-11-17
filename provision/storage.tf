# Main
terraform {
  required_version = "1.6.4"

  # Comment this out during the first run (it requires the bucket to be created first)
  backend "gcs" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.16.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

# Terraform random identifier
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

# Google Cloud Platform configuration
variable "google_project_id" {
  description = "Google Project ID"
  type        = string
  sensitive   = true
}

variable "google_region" {
  type = string
}

variable "google_zone" {
  type = string
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

#tfsec:ignore:google-storage-bucket-encryption-customer-key
resource "google_storage_bucket" "tfstate" {
  name          = "${random_id.bucket_prefix.hex}-backup-tfstate"
  force_destroy = false
  location      = var.google_region
  storage_class = "STANDARD"

  #checkov:skip=CKV_GCP_62:No need to log access to the logging bucket
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  #checkov:skip=CKV_GCP_78:Versioning is not required
  versioning {
    enabled = false
  }
}

#tfsec:ignore:google-storage-bucket-encryption-customer-key
resource "google_storage_bucket" "storage" {
  name          = "${random_id.bucket_prefix.hex}-backup"
  force_destroy = false
  location      = var.google_region
  storage_class = "ARCHIVE"

  #checkov:skip=CKV_GCP_62:No need to log access to the logging bucket
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  #checkov:skip=CKV_GCP_78:Versioning is not required
  versioning {
    enabled = false
  }
}
