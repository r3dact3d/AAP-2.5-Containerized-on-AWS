# Output values

output "public_ip" {
  value = aws_instance.aap_instance.public_ip
}

output "public_fqdn" {
  value = aws_instance.aap_instance.public_dns
}

output "instance_id" {
  value = aws_instance.aap_instance.id
}

output "private_key" {
  value     = tls_private_key.my_key.private_key_pem
  sensitive = false
}
