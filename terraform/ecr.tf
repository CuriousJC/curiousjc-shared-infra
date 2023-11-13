# Create an Amazon ECR repository
resource "aws_ecr_repository" "curiousjc_ecr_repository" {
  name = "curiousjc-container-registry"
}

resource "aws_ecr_lifecycle_policy" "curiousjc_ecr_repository_policy" {
  repository = aws_ecr_repository.curiousjc_ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.curiousjc_ecr_repository.repository_url
}
