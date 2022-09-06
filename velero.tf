# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "aws_iam_policy_document" "backup" {
  statement {
    sid = "ec2"

    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
    ]

    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*", ]
  }

  statement {
    sid = "s3list"

    actions = [
      "s3:ListBucket",
    ]

    resources = [module.velero.s3_bucket_arn, ]
  }

  statement {
    sid = "s3backup"

    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = [
      module.velero.s3_bucket_arn,
      "${module.velero.s3_bucket_arn}/*"
    ]
  }

  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "kms:Encrypt",
  #     "kms:Decrypt",
  #     "kms:GenerateDataKey*",
  #   ]

  #   resources = [
  #     module.velero.s3_bucket_arn,
  #   ]
  # }
}

data "aws_iam_policy_document" "kms" {
  count = var.enable_kms ? 1 : 0

  statement {
    effect = "Allow"

    #tfsec:ignore:aws-iam-no-policy-wildcards
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = [
      aws_kms_key.velero[0].arn
    ]
  }
}

resource "aws_iam_policy" "backup" {
  name        = local.service_name
  path        = "/"
  description = "Permissions for Velero"
  policy      = data.aws_iam_policy_document.backup.json
  tags = merge(
    { "Name" = format("%s-bucket", local.service_name) },
    local.tags
  )
}

resource "aws_iam_policy" "kms" {
  count = var.enable_kms ? 1 : 0

  name        = local.service_name
  path        = "/"
  description = "Permissions for Velero"
  policy      = data.aws_iam_policy_document.kms[0].json
  tags = merge(
    { "Name" = format("%s-kms", local.service_name) },
    local.tags
  )
}

module "velero_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.3.3"

  create_role      = true
  role_description = "Role for Velero"
  role_name        = local.role_name
  provider_url     = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  role_policy_arns = var.enable_kms ? [
    aws_iam_policy.backup.arn,
    aws_iam_policy.kms[0].arn,
    ] : [
    aws_iam_policy.backup.arn,
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
  tags = merge(
    { "Name" = local.role_name },
    local.tags
  )
}
