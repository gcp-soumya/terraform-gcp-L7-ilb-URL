

# Configure the Google provider with your project ID and region
# These values will be passed to the module.
provider "google" {
  project = "your-gcp-project-id" # <<<<<<< IMPORTANT: Replace with your actual GCP Project ID
  region  = "europe-west1"
}

provider "google-beta" {
  project = "your-gcp-project-id" # <<<<<<< IMPORTANT: Replace with your actual GCP Project ID
  region  = "europe-west1"
}

module "l7_internal_lb" {
  source = "../../modules/regional_ilb_url" # Path to your module directory

  project_id = "your-gcp-project-id" # <<<<<<< IMPORTANT: Replace with your actual GCP Project ID
  region     = "europe-west1"

  # You can override any default variables here if needed:
  # network_name               = "my-custom-l7-network"
  # mig_target_size            = 3
  # create_test_instance       = false
  # test_instance_zone         = "europe-west1-c"
  # instance_template_assign_external_ip = true # Only if instances absolutely need outbound internet access
}

