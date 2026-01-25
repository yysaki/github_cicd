resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1234567890123456789012345678901234567890"]
}

resource "aws_iam_role" "terraform" {
  name               = "github-actions-terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "ecspresso" {
  name               = "github-actions-ecspresso"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_policy" "ecspresso_policy" {
  name   = "ecspresso-deploy"
  policy = data.aws_iam_policy_document.ecspresso.json
}

data "aws_iam_policy_document" "ecspresso" {
  statement {
    effect = "Allow"
    actions = [
      "application-autoscaling:Describe*",
      "application-autoscaling:Register*",
      "codedeploy:BatchGet*",
      "codedeploy:CreateDeployment",
      "codedeploy:List*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:ListImages",
      "ecs:*",
      "elasticloadbalancing:DescribeTargetGroups",
      "iam:GetRole",
      "iam:PassRole",
      "logs:GetLogEvents",
      "secretsmanager:GetSecretValue",
      "servicediscovery:GetNamespace",
      "ssm:GetParameters",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.tfstate.arn}/*"]
  }
}

data "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_s3_bucket
}

resource "aws_iam_role_policy_attachment" "ecspresso" {
  role       = aws_iam_role.ecspresso.name
  policy_arn = aws_iam_policy.ecspresso_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_read_only_access" {
  role       = aws_iam_role.ecspresso.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}
