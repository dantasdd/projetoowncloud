#Script responsavel por gerenciar as credenciais com o GCP

provider "google" {
  credentials = "${file ("/root/google_cloud/terraform-key.json")}"
  project = "my-project"
  region = "us-east1"
}
