# ── Table ─────────────────────────────────────────────────
output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_id" {
  value = aws_dynamodb_table.this.id
}

# ── Key Schema ────────────────────────────────────────────
output "hash_key" {
  value = aws_dynamodb_table.this.hash_key
}

output "range_key" {
  value = aws_dynamodb_table.this.range_key
}

# ── Streams ───────────────────────────────────────────────
output "stream_arn" {
  value = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  value = aws_dynamodb_table.this.stream_label
}