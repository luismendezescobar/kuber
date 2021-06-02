/*
Instructions to use with github acctions
1.create a sandbox in linux academy
2.create the bucket for the terraform state and folder with the below codes in cloud shell
gsutil mb -c STANDARD -l us-west1 on gs://tf-state-007
3.create a service account with the following specs:
name:sa_kuber
permissions: Kubernetes Engine Admin, Storage Admin
4. create new key for the same.
5. update the secrets on git hub (settings area) as follows:
GCP_SA_EMAIL
GOOGLE_APPLICATION_CREDENTIALS
GCP_PROJECT
6. update the project id in the below code line 19
7.upload the code to develop and then to master
8.the job should get started automatically and deploy the cluster automatically

*/


module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "playground-s-11-87dc96ca"
  name                       = "gke-test-1"
  region                     = "us-west1"
  #zones                      = ["us-west1-a", "us-west1-b", "us-west1-c"]
  zones                      = ["us-west1-a"]
  network                    = "default"
  subnetwork                 = "default"
  ip_range_pods              = ""
  ip_range_services          = ""
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      #service_account    = "project-service-account@production-host-project-274122.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}