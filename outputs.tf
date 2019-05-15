output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = "${join("", aws_ecr_repository.self.*.registry_id)}"
}

output "repository_arn" {
  description = "Full ARN of repository"
  value       = "${join("", aws_ecr_repository.self.*.arn)}"
}

output "repository_name" {
  description = "Repository name"
  value       = "${join("", aws_ecr_repository.self.*.name)}"
}

output "repository_url" {
  description = "Repository URL"
  value       = "${join("", aws_ecr_repository.self.*.repository_url)}"
}
