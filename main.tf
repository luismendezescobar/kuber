/*
lab files for linux academy
https://github.com/ACloudGuru-Resources/Course_GKE_Beginner_To_Pro

Instructions to use with github acctions
1.create a sandbox in linux academy
2.enable kubernetes api and Cloud Resource Manager API 
gcloud services list
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

3.create the bucket for the terraform state and folder with the below codes in cloud shell
gsutil mb -c standard -l us-west1 gs://tf-state-008
skip step 3
3.create a service account with the following specs:
name:sa_kuber
permissions: Kubernetes Engine Admin, Storage Admin, compute network user

gcloud projects add-iam-policy-binding playground-s-11-87dc96ca \
--member=serviceAccount:sa-kuber@playground-s-11-87dc96ca.iam.gserviceaccount.com --role=roles/container.admin

gcloud projects add-iam-policy-binding playground-s-11-87dc96ca \
--member=serviceAccount:sa-kuber@playground-s-11-87dc96ca.iam.gserviceaccount.com --role=rroles/storage.admin

gcloud projects add-iam-policy-binding playground-s-11-87dc96ca \
--member=serviceAccount:sa-kuber@playground-s-11-87dc96ca.iam.gserviceaccount.com --role=roles/compute.networkUser

gcloud projects add-iam-policy-binding playground-s-11-87dc96ca \
--member=serviceAccount:sa-kuber@playground-s-11-87dc96ca.iam.gserviceaccount.com --role=roles/iam.serviceAccountCreator


gcloud iam service-accounts get-iam-policy 526650703616-compute@developer.gserviceaccount.com \
--format=json > policy.json

then edit the policy.json file like this
{
  "bindings": [
    {
      "role": "roles/iam.serviceAccounts.create",       
      "members": [
        "serviceAccount:sa-kuber@playground-s-11-87dc96ca.iam.gserviceaccount.com"
      ]
    },
  ],
  "etag": "ACAB",
  "version": 1
}

the run this command:
gcloud iam service-accounts set-iam-policy 526650703616-compute@developer.gserviceaccount.com ./policy.json

4.create a service account (manually) with the following specs:
gcloud iam service-accounts create sa-kuber \
    --description="account for kubernetes" \
    --display-name="sa-kuber"

name:sa_kuber
permissions: owner
gcloud projects add-iam-policy-binding playground-s-11-1b4c6e04 \
--member=serviceAccount:sa-kuber@playground-s-11-1b4c6e04.iam.gserviceaccount.com --role=roles/owner


5. create new key for the same:
gcloud iam service-accounts keys create key.json \
--iam-account=sa-kuber@playground-s-11-1b4c6e04.iam.gserviceaccount.com

6. update the secrets on git hub (settings area) as follows:
GCP_SA_EMAIL
GOOGLE_APPLICATION_CREDENTIALS
GCP_PROJECT
7. update the project id in the below code line 77
8 update the service account on line 103
9.upload the code to develop and then to master
10.the job should get started automatically and deploy the cluster automatically

*/


module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "playground-s-11-1b4c6e04"
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
  remove_default_node_pool   = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"
      min_count          = 1
      max_count          = 5
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "sa-kuber@playground-s-11-1b4c6e04.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 3               #you can modify this part
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