# Script Responsavel por gerar a imagem do owncloud no kubernetes

provider "kubernetes" {
  host = ""

  username = ""
  password = ""
    cluster_ca_certificate = file("cluster-ca.pem")
}


resource "kubernetes_pod" "teste" {
  metadata {
    name = "terraform-example"
  }

  spec {
    container {
      image = "owncloud"
      name = "owncloud-geofusion"

      env {
        name  = "environment"
        value = "production"

      }

    }

    dns_config {
      nameservers = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
      searches    = ["example.com"]

      option {
        name  = "ndots"
        value = 1
      }

      option {
        name = "use-vc"
      }
    }

    dns_policy = "None"
  }
}
