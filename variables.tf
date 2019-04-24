variable "cluster_id" {
  description = "Unique ID of the cluster. Useful when running multiple clusters in the same AWS account."
  default = "openshift-cluster-us-east"
}

variable "cluster_name" {
  description = "Name of the cluster, e.g: 'openshift-cluster'. Useful when running multiple clusters in the same AWS account."
  default = "openshift-cluster"
}

variable "openshift_default_subdomain" {
  description = "Default subdomain for openshuft cluster"
  default = "awspaas.demos.saggov.com"
}

variable "openshift_public_hostname" {
  description = "Public DNS for the web console"
  default = "console.awspaas.demos.saggov.com"
}

variable "openshift_bastion_key_name" {
  description = "My ssh key name"
  default = "OPENSHIFT_BASTION"
}

variable "openshift_bastion_key_path" {
  description = "My public ssh key"
  default = "./helper_scripts/id_rsa_bastion.pub"
}

variable "openshift_nodes_key_name" {
  description = "My public ssh key name"
   default = "OPENSHIFT_NODES"
}

variable "openshift_nodes_key_path" {
  description = "My public ssh key"
   default = "./helper_scripts/id_rsa.pub"
}

variable "amisize" {
  description = "The size of the cluster nodes, e.g: t2.large. Note that OpenShift will not run on anything smaller than t2.large"
  default = "t2.large"
}

//22 --> 1024 addresses (mask: 255.255.252.0)
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default = "10.20.0.0/22"
}

//possible 4 subnets of 254 addresses... 10.20.0.0/24, 10.20.1.0/24, 10.20.2.0/24, 10.20.3.0/24
variable "subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default = "10.20.0.0/24"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "azs" {
  default     = "us-east-1a"
}

variable "default_ami" {
  default = "ami-034b65115d858cd6d"
}

variable "default_linuxuser" {
  default = "ec2-user"
}

variable "htpasswd" {
  default = "httpddefault"
}