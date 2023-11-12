# Create an Amazon ECR repository
resource "aws_ecr_repository" "my_ecr_repository" {
  name = "curiousjc-container-registry"
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.my_ecr_repository.repository_url
}
