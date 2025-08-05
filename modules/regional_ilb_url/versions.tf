terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "prj-dd-p-net"
  region  = "us-central1"
}

provider "google-beta" {
  project = "prj-dd-p-net"
  region  = "us-central1"
}
