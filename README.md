Deploy da imagem Owncloud no GKE utilizando ferramentas Ansible e terraform 

Projeto foi elaborado com o proposito de demonstra práticas DevOps em provisionamento de infraestrutura como codigo, propondo formas de se trabalhar com ambiente de Microservicos.

Foram utilizados nesse eco-sistema: 
2 servidores centos-7 On-primeses VMware Workstation e um provedor de servicos em nuvem "GCP".

. Servidor1-Ansible: Responsavel por provisionar a instalação do produto Terraform e criar diretorios,repositorios de
conexao com o GCP no servidor2-terraform.
 
. Servidor2-Terraform: Responsavel por provisionar a instalação do SDK-GCP, instanciar um GKE-'PAAS', criar a imagem (Owncloud) em cluster utilizando a orquestração do kubernetes.

(Estrutura Servidor Ansible)

Executando os playbooks arquivo .YML para provisionar máquina local Terraform.

# Criando diretorio/repositorio do GCP no servidor terraform

- name: 1 - Configurando diretorio google
  hosts: terraform

  tasks:
  - name: criando diretorio para o google
    file:
     path: google_cloud
     state: directory

  - name: copy key file to a remote server
    copy:
     src:  /root/devops-geofusion/terraform-key.json
     dest:  /root/google_cloud
     backup: yes

  - name: atualiza repositorio
    copy:
     src: /root/devops-geofusion/google-cloud-sdk.repo
     dest: /etc/yum.repos.d/google-cloud-sdk.repo

  - name: google SDK
    package: name=google-cloud-sdk state=latest

# Adicionando Repositorio SDK 

[google-cloud-sdk]
name=Google Cloud SDK
baseurl=
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=


# Instalando produto Terraform no Server2 

- name: 1 - Configurando Terraform
  hosts: terraform

  tasks:
  - name: Download file
    get_url:
      url: https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
      dest: /root

  - name: Instalacao Unzip
    package: name=unzip state=latest

  - name: Descompactar o pacote
    shell: /usr/bin/unzip /root/terraform_0.12.5_linux_amd64.zip

  - name: Copy Terraform
    shell: /usr/bin/mv /root/terraform /usr/bin/


(Estrutura Servidor Terraform)

Executando os arquivo .tf para provisionar o GCP, instanciando uma imagem do owncloud em cluster no Kubernetes. 

# Script Responsavel pelo deploy da instancia (PAAS) GKE no GCP

resource "google_container_cluster" "primary" {
  name               = "projetodevops-geofusion"
  location           = "us-central1-a"
  initial_node_count = 3

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}



# Script Responsavel pelo deploy da imagem do owncloud no kubernetes via terraform

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


# Script responsavel por gerenciar as credenciais com o GCP

provider "google" {
  credentials = "${file ("/root/google_cloud/terraform-key.json")}"
  project = "my-project"
  region = "us-east1"
}


























