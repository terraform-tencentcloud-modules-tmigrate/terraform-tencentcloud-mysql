variable "create_mysql_instance" {
  description = "Whether to create mysql instance."
  type        = bool
  default     = true
}

variable "instance_name" {
  description = "The name of a mysql instance."
  type        = string
  default     = ""
}

variable "mem_size" {
  description = "Memory size (in MB)."
  type = number
  default     = 1000
}

variable "volume_size" {
  description = "Disk size (in GB)."
  type = number
  default     = 200
}

variable "cpu" {
  description = "Cpu cores."
  type = number
  default     = 2
}

variable "device_type" {
  description = "Device type."
  type = string
  default     = "UNIVERSAL"
}

variable "disk_type" {
  description = "Disk type. Only valid for BASIC_V2 (single-node cloud disk) or CLOUD_NATIVE_CLUSTER* instances. Valid values: CLOUD_SSD, CLOUD_HSSD (enhanced SSD), CLOUD_PREMIUM (high-performance). ForceNew."
  type = string
  default     = null
}

# ---------------------------------------------------------------------------
# KMS TDE storage encryption (tencentcloud_mysql_instance_encryption_operation)
# Independent resource, attached after instance creation.
# ---------------------------------------------------------------------------

variable "set_mysql_encryption" {
  description = "Set to true to create a tencentcloud_mysql_instance_encryption_operation resource on the instance (enables KMS TDE storage encryption)."
  type        = bool
  default     = false
}

variable "encryption_key_id" {
  description = "Custom KMS CMK ID for TDE encryption. If empty, Tencent Cloud auto-generates a key with name 'KMS-CDB'."
  type        = string
  default     = null
}

variable "encryption_key_region" {
  description = "KMS region for the encryption key (e.g. ap-shanghai). Required when encryption_key_id is not null. Even when key_id is null (auto-generated KMS-CDB), this field is recommended."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# SSL network transit encryption (tencentcloud_mysql_ssl)
# Independent resource, managed separately from instance.
# ---------------------------------------------------------------------------

variable "set_mysql_ssl" {
  description = "Set to true to enable SSL on the instance (creates tencentcloud_mysql_ssl resource with status=ON). When the resource is destroyed, SSL is automatically disabled."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Instance tags."
  type        = map(string)
  default     = {}
}

variable "engine_version" {
  description = "The version number of the database engine to use. Supported versions include 5.5/5.6/5.7, and default is 5.7."
  type = string
  default     = "5.7"
}

variable "root_password" {
  description = "Password of root account. This parameter can be specified when you purchase master instances, but it should be ignored when you purchase read-only instances or disaster recovery instances."
  type = string
  default     = ""
}

variable "availability_zone" {
  description = "Indicates which availability zone will be used."
  type = string
  default     = "ap-guangzhou-2"
}

variable "project_id" {
  description = "Project ID, default value is 0."
  type = number
  default     = 0
}

variable "security_groups" {
  description = "Security groups to use."
  type        = list(string)
  default     = []
}

variable "parameters" {
  description = "List of parameters to use."
  type        = map(string)
  default     = {}
}

# MySQL instance net configuration
variable "internet_service" {
  description = "Indicates whether to enable the access to an instance from public network: 0 - No, 1 - Yes."
  type = number
  default     = 0
}

variable "intranet_port" {
  description = "Public access port, rang form 1024 to 65535 and default value is 3306."
  type = number
  default     = 3306
}

variable "vpc_id" {
  description = "ID of VPC, which can be modified once every 24 hours and can't be removed."
  type = string
  default     = ""
}

variable "subnet_id" {
  description = "Private network ID. If vpc_id is set, this value is required."
  type = string
  default     = ""
}

# MySQL instance payment configuration
variable "charge_type" {
  description = "Pay type of instance, valid values are PREPAID, POSTPAID. Default is POSTPAID."
  type = string
  default     = "POSTPAID"
}

variable "prepaid_period" {
  description = "Period of instance. NOTES: Only supported prepaid instance."
  default     = 1
}

variable "auto_renew_flag" {
  description = "Auto renew flag. NOTES: Only supported prepaid instance."
  type = number
  default     = 0
}

variable "force_delete" {
  description = "Indicate whether to delete instance directly or not. Default is false. If set true, the instance will be deleted instead of staying recycle bin. Note: only works for PREPAID instance. When the main mysql instance set true, this para of the readonly mysql instance will not take effect."
  type = bool
  default     = false
}

# MySQL instance slave configuration
variable "first_slave_zone" {
  description = "Zone information about first slave instance."
  type        = string
  default     = ""
}

variable "second_slave_zone" {
  description = "Zone information about second slave instance."
  type        = string
  default     = ""
}

variable "slave_deploy_mode" {
  description = "Availability zone deployment method. Available values: 0 - Single availability zone; 1 - Multiple availability zones."
  type        = number
  default     = 0
}

variable "slave_sync_mode" {
  description = "Data replication mode. 0 - Async replication; 1 - Semisync replication; 2 - Strongsync replication."
  type        = number
  default     = 0
}
