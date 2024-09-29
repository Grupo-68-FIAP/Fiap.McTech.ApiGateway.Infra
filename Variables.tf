variable "aws_region" {
  description = "The AWS region to deploy the resources"
  default     = "us-east-1"
  type        = string
}

variable "project_name" {
  type        = string
  default     = "MechTechApi"
  description = "Especifica o nome do projeto"
}

variable "nlb_dns_name" {
    type = string
    default = "a96f50e2ee4ae494c950bcf0b84f2d36-ebd7b74a48d85424.elb.us-east-1.amazonaws.com:8080/api"
    description = "Endereço DNS do Network Load Balancer do EKS"
}

variable "nlb_arn" {
    type = string
    default = "arn:aws:elasticloadbalancing:us-east-1:194801747815:loadbalancer/net/a96f50e2ee4ae494c950bcf0b84f2d36/ebd7b74a48d85424"
    description = "Endereço DNS do Network Load Balancer do EKS"
}