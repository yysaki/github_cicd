resource "aws_ecr_repository" "example" {
  name         = "${var.env}-nginx-test"
  force_delete = true
}
