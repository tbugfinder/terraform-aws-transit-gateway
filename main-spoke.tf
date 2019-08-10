data "aws_caller_identity" "spoke" {
  provider = "aws.spoke"
}

resource "aws_vpc" "spoke-vpc-1" {
  provider             = "aws.spoke"
  cidr_block           = "10.100.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = "${var.scenario}-spoke-vpc1-dev"
    scenario = "${var.scenario}"
    env      = "dev"
  }
}

resource "aws_subnet" "spoke-vpc-1-sub-a" {
  provider          = "aws.spoke"
  vpc_id            = "${aws_vpc.spoke-vpc-1.id}"
  cidr_block        = "10.100.1.0/24"
  availability_zone = "${var.az1}"

  tags = {
    Name = "${aws_vpc.spoke-vpc-1.tags.Name}-sub-a"
  }
}

resource "aws_subnet" "spoke-vpc-1-sub-b" {
  provider          = "aws.spoke"
  vpc_id            = "${aws_vpc.spoke-vpc-1.id}"
  cidr_block        = "10.100.2.0/24"
  availability_zone = "${var.az2}"

  tags = {
    Name = "${aws_vpc.spoke-vpc-1.tags.Name}-sub-b"
  }
}

# VPC Endpoints for SSM
resource "aws_vpc_endpoint" "spoke-ssm1" {
  provider          = "aws.spoke"
  vpc_id            = "${aws_vpc.spoke-vpc-1.id}"
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.spoke-vpc-1-sub-a.id}", "${aws_subnet.spoke-vpc-1-sub-b.id}"]

  security_group_ids = [
    "${aws_security_group.sec-group-spoke-vpc-1-endpoint.id}",
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke-ssmmessages1" {
  provider          = "aws.spoke"
  vpc_id            = "${aws_vpc.spoke-vpc-1.id}"
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.spoke-vpc-1-sub-a.id}", "${aws_subnet.spoke-vpc-1-sub-b.id}"]

  security_group_ids = [
    "${aws_security_group.sec-group-spoke-vpc-1-endpoint.id}",
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke-ec2messages1" {
  provider          = "aws.spoke"
  vpc_id            = "${aws_vpc.spoke-vpc-1.id}"
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.spoke-vpc-1-sub-a.id}", "${aws_subnet.spoke-vpc-1-sub-b.id}"]

  security_group_ids = [
    "${aws_security_group.sec-group-spoke-vpc-1-endpoint.id}",
  ]

  private_dns_enabled = true
}

# Security Groups
## for Endpoints
resource "aws_security_group" "sec-group-spoke-vpc-1-endpoint" {
  provider    = "aws.spoke"
  name        = "sec-group-spoke-vpc-1-endpoint"
  description = "test-tgw: any traffic to endpoint"
  vpc_id      = "${aws_vpc.spoke-vpc-1.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "sec-group-spoke-vpc-1-endpoint"
    scenario = "${var.scenario}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa-spoke" {
  provider           = "aws.spoke"
  subnet_ids         = ["${aws_subnet.spoke-vpc-1-sub-a.id}", "${aws_subnet.spoke-vpc-1-sub-b.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  vpc_id             = "${aws_vpc.spoke-vpc-1.id}"
  tags               = "${local.tags}"
}

# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-spoke-rt" {
  provider           = "aws.spoke"
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"

  tags = {
    Name     = "tgw-spoke-rt"
    scenario = "${var.scenario}"
  }

  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-spoke-to-vpc-1" {
  provider                       = "aws.spoke"
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgwa-spoke.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-spoke-rt.id}"
}
