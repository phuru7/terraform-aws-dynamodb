# ── DynamoDB Table ────────────────────────────────────────
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  table_class  = var.table_class

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # ── Key Schema ────────────────────────────────────────────
  hash_key  = var.hash_key
  range_key = var.range_key != null ? var.range_key : null

  # ── Attributes ────────────────────────────────────────────
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # ── TTL ───────────────────────────────────────────────────
  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [var.ttl_attribute] : []
    iterator = ttl_cfg
    content {
      attribute_name = ttl_cfg.value
      enabled        = true
    }
  }

  # ── Global Secondary Indexes ──────────────────────────────
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    iterator = gsi
    content {
      name               = gsi.value.name
      projection_type    = gsi.value.projection_type
      non_key_attributes = gsi.value.projection_type == "INCLUDE" ? gsi.value.non_key_attributes : null
      hash_key           = gsi.value.hash_key
      range_key          = gsi.value.range_key != null ? gsi.value.range_key : null
      read_capacity      = var.billing_mode == "PROVISIONED" ? gsi.value.read_capacity : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? gsi.value.write_capacity : null
    }
  }

  # ── Local Secondary Indexes ───────────────────────────────
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    iterator = lsi
    content {
      name               = lsi.value.name
      range_key          = lsi.value.range_key
      projection_type    = lsi.value.projection_type
      non_key_attributes = lsi.value.projection_type == "INCLUDE" ? lsi.value.non_key_attributes : null
    }
  }

  # ── Point-in-Time Recovery ────────────────────────────────
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # ── Server Side Encryption ────────────────────────────────
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  # ── Streams ───────────────────────────────────────────────
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # ── Deletion Protection ───────────────────────────────────
  deletion_protection_enabled = var.deletion_protection_enabled

  # ── Lifecycle Guards ──────────────────────────────────────
  lifecycle {
    precondition {
      condition     = var.env == "prod" ? var.deletion_protection_enabled == true : true
      error_message = "deletion_protection_enabled must be true in prod environment."
    }

    precondition {
      condition     = var.billing_mode == "PROVISIONED" ? (var.read_capacity > 0 && var.write_capacity > 0) : true
      error_message = "read_capacity and write_capacity must be > 0 when billing_mode is PROVISIONED."
    }

    precondition {
      condition     = var.stream_enabled ? var.stream_view_type != null : true
      error_message = "stream_view_type must be set when stream_enabled is true."
    }
  }

  tags = {
    Name = var.table_name
  }
}