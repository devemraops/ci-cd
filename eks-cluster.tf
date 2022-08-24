data "aws_vpc" "qa-vpc" {
  filter {
    name= "tag:Name"
    values=["qa"]

  }
}

data "aws_internet_gateway" "qa-gw" {
  filter {
    name= "tag:Name"
    values=["qa"]

  }
}

data "aws_subnets" "all_subnets" {
   
    filter {
    name= "vpc-id"
    values=[data.aws_vpc.qa-vpc.id]

  } 
   
}

data "aws_subnets" "private_subnets" {

  filter {
    name= "tag:Name"
    values=["private-us-east-2*"]

  }

}


resource "aws_iam_role" "eks-role" {
  name = "eks-cluster"

  # The policy that grants an entity permission to assume the role.
  # Used to access AWS resources that you might not normally have access to.
  # The role that Amazon EKS will use to create AWS resources for kubernetes clusters.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "yellow-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "yellow-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}

# Creation of EKS cluster

resource "aws_eks_cluster" "eks" {
  name = "prime-eks"

  # The Amazon Resource Name (ARN) of the IAM role that provides permissions for the
  # kubernetes control plane to make calls to AWS API operations on your behalf.
  role_arn = aws_iam_role.eks-role.arn

  # Desired Kubernetes master version.
  version = "1.21"
  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled (Bastion host, VPN)
    endpoint_private_access = false
    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true
    subnet_ids = data.aws_subnets.all_subnets.ids
  }

  # Enable EKS cluster Control Plane Logging

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.yellow-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.yellow-AmazonEKSVPCResourceController,
  ]
}

