config {
terraform_version = "0.11.13"
deep_check = true
ignore_module = {
"devops-workflow/boolean/local" = true
"git::https://github.com/appzen-oss/terraform-local-labels.git?ref=master" = true
}
}

