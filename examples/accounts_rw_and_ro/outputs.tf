output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = "${module.example.registry_id}"
}

output "repository_arn" {
  description = "Full ARN of repository"
  value       = "${module.example.repository_arn}"
}

output "repository_name" {
  description = "Repository name"
  value       = "${module.example.repository_name}"
}

output "repository_url" {
  description = "Repository URL"
  value       = "${module.example.repository_url}"
}
