# Output values

output "public_ip" {
  value = aws_instance.php_instance.public_ip
}