module "example" {
  source      = "../../"
  name        = "example"
  environment = "testy"
  accounts_rw = ["111111111111", "222222222222"]
}
