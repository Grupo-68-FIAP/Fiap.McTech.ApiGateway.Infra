locals {
  region  = "us-east-1"
}

# Configurações do AWS Provider
provider "aws" {
  region  = local.region
}

resource "aws_apigatewayv2_api" "main" {
  name          = "main"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "dev"
  auto_deploy = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = "172.31.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/MechTechApi"         = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = "172.31.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/MechTechApi"         = "owned"
  }
}

data "aws_security_group" "vpc_link" {
  filter {
    name   = "group-name"
    values = ["SG-MechTechApi"]  # Substitua pelo nome do seu security group
  }
}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "eks"
  security_group_ids = [data.aws_security_group.vpc_link.id]
  subnet_ids = [aws_subnet.private-us-east-1a.id, aws_subnet.private-us-east-1b.id]
}

resource "aws_apigatewayv2_integration" "eks" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = "arn:aws:elasticloadbalancing:us-east-1:194801747815:listener/net/adea164640b304dda93321394e5df33c/8ca757409d032511/4b8e3ae677948d88"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks.id
}

resource "aws_apigatewayv2_route" "get_products" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.eks.id}"
}

output "get_products_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/api/product"
}