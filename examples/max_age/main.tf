module "example" {
  source                   = "../../"
  name                     = "example"
  environment              = "testy"
  accounts_ro              = ["111111111111"]
  accounts_rw              = ["222222222222"]
  max_image_age            = 30
  max_image_age_tag_prefix = ["v"]
}
