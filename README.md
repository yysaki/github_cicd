# GitHub CI/CD

GitHub Actions と AWS ECS を使用した CI/CD パイプラインの検証リポジトリ。

## 概要

OIDC を使用して GitHub Actions から AWS へ認証し、コンテナイメージを ECR にプッシュ、ECS Fargate へデプロイする。

## 環境構成

| ディレクトリ | 説明 | デプロイ方式 |
|-------------|------|-------------|
| `aws_copilot/` | AWS Copilot を使用した ECS 環境 | Copilot CLI |
| `minimal_ecs/` | 最小限の ECS 環境 | カスタムアクション |
| `ecspresso/` | ecspresso を使用した ECS 環境 | ecspresso |
| `moduled/` | モジュール化された複数環境構成 (stg/prod) | ecspresso |

## 必要条件

- Terraform 1.14.3
- AWS CLI
- Docker
- [ecspresso](https://github.com/kayac/ecspresso) (ecspresso/moduled 環境用)
- [direnv](https://direnv.net/) (環境変数管理)

## セットアップ

### 1. 環境変数の設定

`.envrc.example` を参考に `.envrc` を作成:

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=ap-northeast-1
export AWS_ID=123456789012
export TFSTATE_S3_BUCKET=your-tfstate-bucket
```

### 2. Terraform の初期化と適用

```bash
cd <environment>/terraform
terraform init -backend-config="bucket=${TFSTATE_S3_BUCKET}"
terraform plan
terraform apply
```

### 3. デプロイ

GitHub Actions の `workflow_dispatch` から手動実行、または CLI で直接デプロイ:

```bash
# ecspresso を使用する場合
ecspresso deploy --config ecspresso/ecspresso/ecspresso.yml
```

## アーキテクチャ

```
GitHub Actions
    │
    ▼ OIDC
AWS STS (AssumeRoleWithWebIdentity)
    │
    ▼
IAM Role (github-actions)
    │
    ├──▶ ECR (コンテナイメージ)
    │
    └──▶ ECS Fargate
            │
            ▼
         ALB ◀── Route53
```

### インフラ構成

- VPC: 10.0.0.0/16
- Subnets: Public/Private (2 AZ)
- ALB → ECS Fargate (nginx)
- ACM 証明書 (HTTPS)

## GitHub Actions ワークフロー

| ワークフロー | 説明 |
|-------------|------|
| `aws_copilot_deploy.yml` | AWS Copilot 環境へのデプロイ |
| `minimal_ecs_deploy.yml` | minimal_ecs 環境へのデプロイ |
| `ecspresso_deploy.yml` | ecspresso 環境へのデプロイ |
| `moduled_deploy.yml` | moduled 環境へのデプロイ |
| `moduled_terraform_apply.yml` | moduled の Terraform apply |
| `moduled_terraform_destroy.yml` | moduled の Terraform destroy |

## 前提条件

- Route53 Hosted Zone は事前に作成が必要
- GitHub リポジトリの Secrets に以下を設定:
  - `AWS_ID`: AWS アカウント ID
  - `TF_VAR_TFSTATE_S3_BUCKET`: Terraform state 用 S3 バケット
  - `DOMAIN_NAME`: ドメイン名

## ライセンス

MIT
