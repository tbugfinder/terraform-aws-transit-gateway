# Create Resource Access Manager Share
resource "aws_ram_resource_share" "ramshare" {
  name                      = "test-tgw-share"
  allow_external_principals = false
  tags                      = "${local.tags}"
}

# Associate principals with share
resource "aws_ram_principal_association" "ram_principal_assoc" {
  principal          = "${data.aws_caller_identity.spoke.account_id}"
  resource_share_arn = "${aws_ram_resource_share.ramshare.id}"
}

# Associate resources with share
resource "aws_ram_resource_association" "ram_resource_assoc" {
  resource_arn       = "${aws_ec2_transit_gateway.test-tgw.arn}"
  resource_share_arn = "${aws_ram_resource_share.ramshare.id}"
}
