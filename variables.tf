# ── Identity ──────────────────────────────────────────────
variable "env" {
  description = "Environment: dev | qa | uat | prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.env)
    error_message = "Must be one of: dev, qa, prod."
  }
}

# ── Table ─────────────────────────────────────────────────
variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST | PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Must be 'PAY_PER_REQUEST' or 'PROVISIONED'."
  }
}

variable "table_class" {
  description = "Table class: STANDARD | STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Must be 'STANDARD' or 'STANDARD_INFREQUENT_ACCESS'."
  }
}

variable "read_capacity" {
  description = "Read capacity units. Required when billing_mode is PROVISIONED"
  type        = number
  default     = 0
}

variable "write_capacity" {
  description = "Write capacity units. Required when billing_mode is PROVISIONED"
  type        = number
  default     = 0
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection on the table"
  type        = bool
  default     = true
}

# ── Key Schema ────────────────────────────────────────────
variable "hash_key" {
  description = "Partition key (HASH) name. Must be declared in attributes"
  type        = string
}

variable "range_key" {
  description = "Sort key (RANGE) name. Must be declared in attributes. Null if not required"
  type        = string
  default     = null
}

# ── Attributes ────────────────────────────────────────────
variable "attributes" {
  description = "List of attributes used in PK, SK, GSI or LSI"
  type = list(object({
    name = string
    type = string # S = String | N = Number | B = Binary
  }))

  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "Attribute type must be 'S', 'N', or 'B'."
  }
}

# ── TTL ───────────────────────────────────────────────────
variable "ttl_attribute" {
  description = "Attribute name for TTL expiration (epoch timestamp). Null to disable"
  type        = string
  default     = null
}

# ── Global Secondary Indexes ──────────────────────────────
variable "global_secondary_indexes" {
  description = "List of Global Secondary Indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string, null)
    projection_type    = string # ALL | KEYS_ONLY | INCLUDE
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number, 0)
    write_capacity     = optional(number, 0)
  }))
  default = []

  validation {
    condition     = alltrue([for gsi in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)])
    error_message = "GSI projection_type must be 'ALL', 'KEYS_ONLY', or 'INCLUDE'."
  }
}

# ── Local Secondary Indexes ───────────────────────────────
variable "local_secondary_indexes" {
  description = "List of Local Secondary Indexes. Comparten el hash_key de la tabla"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string # ALL | KEYS_ONLY | INCLUDE
    non_key_attributes = optional(list(string), [])
  }))
  default = []

  validation {
    condition     = alltrue([for lsi in var.local_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)])
    error_message = "LSI projection_type must be 'ALL', 'KEYS_ONLY', or 'INCLUDE'."
  }
}

# ── Point-in-Time Recovery ────────────────────────────────
variable "point_in_time_recovery_enabled" {
  description = "Enable Point-in-Time Recovery (PITR)"
  type        = bool
  default     = false
}

# ── Encryption ────────────────────────────────────────────
variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption. Empty string uses AWS managed key (alias/aws/dynamodb)"
  type        = string
  default     = ""
}

# ── Streams ───────────────────────────────────────────────
variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type: KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES"
  type        = string
  default     = null

  validation {
    condition     = var.stream_view_type == null || contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Must be 'KEYS_ONLY', 'NEW_IMAGE', 'OLD_IMAGE', or 'NEW_AND_OLD_IMAGES'."
  }
}