# Velero into AWS

![Tfsec](https://github.com/nlamirault/terraform-aws-velero/workflows/Tfsec/badge.svg)

## Usage

```hcl
module "velero" {
  source  = "nlamirault/velero/aws"
  version = "1.0.0"
  
  project = var.project

  namespace       = var.namespace
  service_account = var.service_accounttags = var.tags

  tags = var.tags
}
```

and variables :

```hcl
project = "foo-prod"

region = "europe-west1"

##############################################################################
# External DNS

namespace       = "dns"
service_account = "velero"
```

## Documentation

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.0 |
| aws | >= 3.26.0 |

### Providers

| Name | Version |
|------|---------|
| aws | >= 3.26.0 |

### Modules

No Modules.

### Resources

| Name |
|------|
| [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/data-sources/eks_cluster) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/iam_role_policy_attachment) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/kms_key) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/s3_bucket) |
| [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/data-sources/secretsmanager_secret) |
| [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/data-sources/secretsmanager_secret_version) |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the EKS cluster | `string` | n/a | yes |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days | `number` | `30` | no |
| namespace | The Kubernetes namespace | `string` | n/a | yes |
| service\_account | The Kubernetes service account | `string` | n/a | yes |
| tags | Tags for VPC | `map(string)` | <pre>{<br>  "made-by": "terraform"<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| kms\_arn | n/a |
| role\_arn | n/a |