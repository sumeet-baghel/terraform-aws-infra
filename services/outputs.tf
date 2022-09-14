output "public_service_endpoint" {
  value = aws_lb.app_lb.dns_name
}
