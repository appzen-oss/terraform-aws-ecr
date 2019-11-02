/*
    terraform-aws-ecr
*/

// refs to look at for ideas
// https://github.com/doingcloudright/terraform-aws-ecr-lifecycle-policy-rule/blob/master/main.tf
// https://github.com/tmknom/terraform-aws-ecr/blob/master/main.tf
// https://github.com/telia-oss/terraform-aws-ecr/blob/master/main.tf
// https://github.com/lynnlin827/terraform-aws-tagged-ecr/blob/master/files/rule_tagged_latest.tpl

// TODO future
//    principals = full arns. In addition to current account support

locals {
  accounts_ro_non_empty = "${signum(length(var.accounts_ro))}"
  accounts_rw_non_empty = "${signum(length(var.accounts_rw))}"
  accounts_ro_arns      = "${formatlist("arn:aws:iam::%s:root", var.accounts_ro)}"
  accounts_rw_arns      = "${formatlist("arn:aws:iam::%s:root", var.accounts_rw)}"
  ecr_need_policy       = "${signum(length(var.accounts_ro) + length(var.accounts_rw))}"

  rule_keep_latest = <<LATEST
    {
      "rulePriority": 1,
      "description": "No expire latest tag",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest"],
        "countType": "imageCountMoreThan",
        "countNumber": 99999
      },
      "action": {
        "type": "expire"
      }
    }
LATEST

  rule_untagged = <<UNTAGGED
    {
      "rulePriority": 10,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
UNTAGGED

  rule_max_images = <<MAX_IMAGES
    {
      "rulePriority": 1000,
      "description": "Only keep last ${var.max_image_count} images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
MAX_IMAGES

  rule_max_age = <<MAX_AGE
    {
      "rulePriority": 30,
      "description": "Remove all images older than ${var.max_image_age}",
      "selection": {
        "tagPrefixList": [${join(",", formatlist("\"%s\"", var.max_image_age_tag_prefix))}],
        "tagStatus": "tagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.max_image_age}
      },
      "action": {
        "type": "expire"
      }
    }
MAX_AGE
}

/**/

module "enabled" {
  source  = "devops-workflow/boolean/local"
  version = "0.1.2"
  value   = "${var.enabled}"
}

module "label" {
  source        = "git::https://github.com/appzen-oss/terraform-local-label.git?ref=master"
  attributes    = "${var.attributes}"
  component     = "${var.component}"
  delimiter     = "${var.delimiter}"
  environment   = "${var.environment}"
  monitor       = "${var.monitor}"
  name          = "${var.name}"
  namespace-env = "${var.namespace-env}"
  namespace-org = "${var.namespace-org}"
  organization  = "${var.organization}"
  owner         = "${var.owner}"
  product       = "${var.product}"
  service       = "${var.service}"
  tags          = "${var.tags}"
  team          = "${var.team}"
}

resource "aws_ecr_repository" "self" {
  count                = "${module.enabled.value}"
  name                 = "${var.use_fullname == "true" ? module.label.id : module.label.name}"
  image_tag_mutability = "${var.image_tag_mutability}"
  tags                 = "${module.label.tags}"

  image_scanning_configuration {
    scan_on_push = "${var.scan_on_push}"
  }
}

resource "aws_ecr_lifecycle_policy" "aged" {
  count      = "${(module.enabled.value && var.max_image_age > 0) ? 1 : 0}"
  repository = "${aws_ecr_repository.self.name}"

  policy = <<POLICY
{
  "rules": [
    ${local.rule_untagged},
    ${local.rule_max_images},
    ${local.rule_max_age}
  ]
}
POLICY
}

resource "aws_ecr_lifecycle_policy" "basic" {
  count      = "${(module.enabled.value && var.max_image_age == 0) ? 1 : 0}"
  repository = "${aws_ecr_repository.self.name}"

  policy = <<POLICY
{
  "rules": [
    ${local.rule_untagged},
    ${local.rule_max_images}
  ]
}
POLICY
}

data "aws_iam_policy_document" "empty" {}

data "aws_iam_policy_document" "ecr_ro" {
  statement {
    sid    = "ReadOnlyAccess"
    effect = "Allow"

    principals = {
      type = "AWS"

      identifiers = [
        "${local.accounts_ro_arns}",
      ]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]
  }
}

data "aws_iam_policy_document" "ecr_rw" {
  statement {
    sid    = "ReadWriteAccess"
    effect = "Allow"

    principals = {
      type = "AWS"

      identifiers = [
        "${local.accounts_rw_arns}",
      ]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }
}

data "aws_iam_policy_document" "ecr" {
  source_json   = "${local.accounts_ro_non_empty ? data.aws_iam_policy_document.ecr_ro.json : data.aws_iam_policy_document.empty.json}"
  override_json = "${local.accounts_rw_non_empty ? data.aws_iam_policy_document.ecr_rw.json : data.aws_iam_policy_document.empty.json}"
  "statement"   = []
}

resource "aws_ecr_repository_policy" "self" {
  count      = "${(module.enabled.value && local.ecr_need_policy) ? 1 : 0}"
  repository = "${aws_ecr_repository.self.name}"
  policy     = "${data.aws_iam_policy_document.ecr.json}"
}
