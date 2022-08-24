
# Adding Backend as S3 for Remote State Storage
terraform {
  backend "s3" {
    bucket  = "myawsbuckets3-data"
    key     = "dev/"
    region  = "us-east-2"
    profile = "silver"
  }
}

# terraform {
#   backend "s3" {
#     encrypt = true
#     bucket  = "myawsbuckets3-emra"
#     region  = "ap-southeast-1"
#     key     = "dev/prime-cluster/terraform.tfstate"
#     profile = "silver"
#   }
# }