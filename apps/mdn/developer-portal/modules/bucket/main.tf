locals {
  bucket_name = "${var.bucket_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"

  # All other things reference this
  identifier = "${var.bucket_name}-${var.environment}"
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.bucket_name}"
  acl    = "${var.bucket_acl}"
  policy = "${data.aws_iam_policy_document.bucket_public_policy.json}"

  #cors_rule {
  #  allowed_headers = ["*"]
  #  allowed_methods = ["GET"]
  #  allowed_origins = ["*"]
  #  max_age_seconds = 3000
  #}

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags {
    Name      = "${local.bucket_name}"
    Region    = "${var.region}"
    Project   = "developer-portal"
    Terraform = "true"
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.identifier}-${var.region}-role"
  assume_role_policy = "${data.aws_iam_policy_document.bucket_role.json}"
}

resource "aws_iam_role_policy" "this" {
  name   = "${local.identifier}-${var.region}-policy"
  role   = "${aws_iam_role.this.id}"
  policy = "${data.aws_iam_policy_document.bucket_policy.json}"
}

data "aws_iam_policy_document" "bucket_public_policy" {
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    sid    = "AllowIndexHTML"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "bucket_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    # We assume you are using kube2iam here
    principals {
      type        = "AWS"
      identifiers = ["${var.eks_worker_role_arn}"]
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowUserToListBuckets"
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = ["arn:aws:s3:::*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = ["arn:aws:s3:::${local.bucket_name}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["arn:aws:s3:::${local.bucket_name}/*"]
  }
}
