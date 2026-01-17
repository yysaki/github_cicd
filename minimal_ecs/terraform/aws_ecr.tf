resource "aws_ecr_repository" "example" {
  name = "nginx-test"
  force_delete = true
}
