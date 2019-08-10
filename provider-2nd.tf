provider "aws" {
  version    = "~> 2"
  region     = "${var.region}"
  profile    = "secondaryprofile"
  alias      = "spoke"
  access_key = "${var.spokeAK}"
  secret_key = "${var.spokeSK}"
}
