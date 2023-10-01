data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "passrole_for_uc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}-uc-access"]
    }
  }
}


resource "aws_iam_role" "external_data_access" {
  name                = "${var.prefix}-external-access"
  assume_role_policy  = data.aws_iam_policy_document.passrole_for_uc.json
  # policies defined this way will be overwritten by aws_iam_role_policy_attachment
  #managed_policy_arns = [aws_iam_policy.external_data_access.arn]
  tags = merge(var.tags, {
    Name = "${var.prefix}-unity-catalog external access IAM role"
  })
}


# attach log access to external access role
resource "aws_iam_role_policy_attachment" "external_data_policies" {
  for_each =  {
    policy1 = aws_iam_policy.external_data_access.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.external_data_access.name
  policy_arn = each.value
}


resource "databricks_storage_credential" "external" {
  provider = databricks.ws1
  name = aws_iam_role.external_data_access.name
  aws_iam_role {
    role_arn = aws_iam_role.external_data_access.arn
  }
  comment = "Managed by TF"
}

/**
resource "databricks_grants" "credential_grants" {
  provider = databricks.ws1

  storage_credential = databricks_storage_credential.external.id
  grant {
    principal  =  var.unity_admin_group
    privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
  }
}
**/

resource "databricks_external_location" "external_location" {
  depends_on = []
  provider = databricks.ws1
  name            = "external"
  url             = "s3://${aws_s3_bucket.external.id}/catalog1"
  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
  force_destroy  = true
}

/**
resource "databricks_grants" "external_location_grant" {
  provider = databricks.ws1
  external_location = databricks_external_location.external_location.id
  grant {
    principal  =  var.unity_admin_group
    privileges = ["CREATE_TABLE", "READ_FILES"]
  }
}
**/