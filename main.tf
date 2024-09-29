# Configurações do AWS Provider
provider "aws" {
  region = var.aws_region
}

resource "aws_api_gateway_vpc_link" "mctechapi_vpc_link" {
  name        = "MCTech API VPC Link"
  target_arns = [var.nlb_arn]  # ARN do NLB

  # Use o ID da VPC
  description = "VPC Link to MCTech API NLB"
}


resource "aws_api_gateway_rest_api" "restapi" {
  name        = "rest-api"
  description = "API Gateway for MCTech API project"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id   = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part   = "{proxy+}"  # Capture todas as rotas dinâmicas
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"  # Aceita qualquer método (GET, POST, etc.)
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}/{proxy}"  # Use o DNS do NLB aqui
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.mctechapi_vpc_link.id

  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [
    aws_api_gateway_method.proxy_method
  ]
}

resource "aws_api_gateway_deployment" "mctechapi_deployment" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  stage_name  = "homolog"

  depends_on = [
    aws_api_gateway_integration.proxy_integration
  ]
}

