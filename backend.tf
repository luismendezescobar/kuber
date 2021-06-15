terraform {
    required_providers {
        google = {      
            version = ">= 3.23.0"
        }
    }
    backend "gcs" {
        bucket = "tf-state-07"
        prefix = "kuber"    
   }
}
