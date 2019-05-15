module "example" {
  source      = "../../"
  name        = "example"
  environment = "testy"
  accounts_ro = ["111111111111"]
  accounts_rw = ["222222222222"]
}
