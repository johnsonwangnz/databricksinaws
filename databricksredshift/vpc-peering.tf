locals {
  # information from sp-southeast-1
  databricks_vpc_id         = "vpc-06b077c77fd546bac"

}

################################################################################
# aws vpc peering
################################################################################


resource "aws_vpc_peering_connection" "vpc_peering_databricks_to_redshift" {
  depends_on = []
  # accepter : redhsift
  peer_vpc_id   = local.default_vpc_id
  # requester: databricks
  vpc_id        = local.databricks_vpc_id
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC Peering between vpc-1 and vpc-2"
  }
}

################################################################################
# aws vpc peering rout tables
################################################################################

data "aws_vpc" "databricks_vpc" {
  id = local.databricks_vpc_id
}
data "aws_route_tables" "databricks_vpc_all" {
   vpc_id = local.databricks_vpc_id

  #filter {
  #  name   = "association.main"
  #  values = [true]
  #}
}


resource "aws_route" "requester_vpc_databricks_route" {
  depends_on = []
  count = length(data.aws_route_tables.databricks_vpc_all.ids)
  route_table_id = element(data.aws_route_tables.databricks_vpc_all.ids,count.index)
  destination_cidr_block = data.aws_vpc.redshift_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_databricks_to_redshift.id
}

resource "aws_route" "accepter_vpc_redshift_route" {
  depends_on = []
  count = length(data.aws_route_tables.route-tables-redshift-vpc.ids)
  route_table_id = element(data.aws_route_tables.route-tables-redshift-vpc.ids, count.index)
  destination_cidr_block = data.aws_vpc.databricks_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_databricks_to_redshift.id
}

data "aws_security_group" "databricks_vpc_security_group"{
  filter {
    name   = "vpc-id"
    values = [local.databricks_vpc_id]
  }

}

output "databricks_vpc" {
  value = data.aws_vpc.databricks_vpc
}

output "databricks_vpc_route_tabls" {
  value = data.aws_route_tables.databricks_vpc_all

}