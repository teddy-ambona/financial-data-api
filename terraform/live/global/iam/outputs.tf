output "secret" {
  value     = aws_iam_access_key.demo_user.encrypted_secret
  sensitive = true
}
