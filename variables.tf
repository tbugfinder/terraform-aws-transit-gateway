variable "region" {
  default = "eu-central-1"
}

variable "az1" {
  default = "eu-central-1a"
}

variable "az2" {
  default = "eu-central-1b"
}

variable "scenario" {
  default = "testing-tgw"
}

variable "spokeAK" {
  default = "accesskey"
}

variable "spokeSK" {
  default = "secretaccesskey"
}

variable "public_key" {
  default = "ssh-rsa aaaasomekeyofyourslefnotmineJv testkey"
}
