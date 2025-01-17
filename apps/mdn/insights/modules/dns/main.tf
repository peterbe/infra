resource "aws_route53_record" "main" {
  zone_id = "${var.domain-zone-id}"
  name    = "${var.domain-name}"

  type = "A"

  alias {
    name                   = "${var.domain-name-alias}"
    zone_id                = "${var.alias-zone-id}"
    evaluate_target_health = "${var.evaluate-target-health}"
  }
}
