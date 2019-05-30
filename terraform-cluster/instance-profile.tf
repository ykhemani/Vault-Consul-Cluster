data "aws_iam_policy_document" "assume_role_kms" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "ec2:DescribeInstances"
    ]
  }
  statement {
    sid       = "AllowSelfAssembly"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeTags",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]
  }

}

resource "aws_iam_role" "vault-kms-unseal" {
  name               = "vault-kms-role-${var.environment_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_kms.json}"
}

resource "aws_iam_role_policy" "vault-kms-unseal" {
  name   = "Vault-KMS-Unseal-${var.environment_name}"
  role   = "${aws_iam_role.vault-kms-unseal.id}"
  policy = "${data.aws_iam_policy_document.vault-kms-unseal.json}"
}

resource "aws_iam_instance_profile" "vault-kms-unseal" {
  name = "vault-kms-unseal-${var.environment_name}"
  role = "${aws_iam_role.vault-kms-unseal.name}"
}
