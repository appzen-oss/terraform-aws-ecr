# terraform-aws-ecr: accounts_rw_and_ro

Configuration in this directory tests both read only and read/write policies
used at same time

The module should create nothing and not error on any of the outputs

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Outputs

| Name | Description |
|------|-------------|
| registry\_id | The registry ID where the repository was created |
| repository\_arn | Full ARN of repository |
| repository\_name | Repository name |
| repository\_url | Repository URL |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
