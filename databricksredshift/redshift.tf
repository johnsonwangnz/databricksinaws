
locals {
 # information from sp-southeast-1
  default_vpc_id         = "vpc-ac07eac9"

}

data "aws_vpc" "redshift_vpc" {
  id = local.default_vpc_id
}

data "aws_subnets" "subnets-redshift-vpc" {
  filter {
    name   = "vpc-id"
    values = [local.default_vpc_id]
  }
}

data "aws_route_tables" "route-tables-redshift-vpc" {
  vpc_id = local.default_vpc_id
  filter {
    name   = "association.main"
    values = [true]
  }
}

################################################################################
# Redshift custom cluster
################################################################################

# consumer cluster for the data sharing exercise
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "${var.prefix}-cluster"

  master_username    = "admin"
  master_password    = "Admin1234!"
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  number_of_nodes    = 2
  port = 5439

  cluster_subnet_group_name  = aws_redshift_subnet_group.redshiftclustersubnetgroup.name

  vpc_security_group_ids = [aws_security_group.redshift_sg_sg.id]

  iam_roles = [aws_iam_role.redshift-instance-role.arn]

  default_iam_role_arn = aws_iam_role.redshift-instance-role.arn
  publicly_accessible = true
  encrypted = true
  skip_final_snapshot = true

}

resource "aws_redshift_subnet_group" "redshiftclustersubnetgroup" {
  name       = "redshiftlustersubnetgroup-jw"
  subnet_ids = data.aws_subnets.subnets-redshift-vpc.ids

  tags = {
    environment = "dev"
  }
}



resource "aws_security_group" "redshift_sg_sg" {
  name = "redshift_sg"
  vpc_id      = local.default_vpc_id
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# allow local

resource "aws_security_group_rule" "redshift_sg_allow_local" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = aws_security_group.redshift_sg_sg.id
  security_group_id = aws_security_group.redshift_sg_sg.id
}

/**
resource "aws_security_group_rule" "redshift_sg_allow_https_s3" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  security_group_id = aws_security_group.redshift_sg_sg.id
}
**/


# allow databricks access pub

resource "aws_security_group_rule" "redshift_sg_allow_databricks" {
  type        = "ingress"
  from_port   = 5439
  to_port     = 5439
  protocol    = "tcp"
  source_security_group_id = data.aws_security_group.databricks_vpc_security_group.id
  security_group_id = aws_security_group.redshift_sg_sg.id
}


output "subnets" {
  value = data.aws_subnets.subnets-redshift-vpc
}

output "route-tables" {
  value = data.aws_route_tables.route-tables-redshift-vpc
}

output "redshift-url" {
  value = aws_redshift_cluster.redshift_cluster.endpoint
}