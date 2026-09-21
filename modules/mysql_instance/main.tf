locals {
  random_root_password = var.root_password == null || var.root_password == "" ? true: false
  root_password  = local.random_root_password ? random_password.root.result : var.root_password
}

resource "random_password" "root" {
  length           = 32
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  min_lower        = 2
  # 腾讯云 mysql root_password 只接受 _+-&=!@#$%^*() 这 8 种特殊字符, 不能用其他
  override_special = "_+-&=!@#$%^*()"
}

resource "tencentcloud_mysql_instance" "this" {
  count = var.create_mysql_instance ? 1 : 0
  
  instance_name     = var.instance_name
  mem_size          = var.mem_size
  volume_size       = var.volume_size
  availability_zone = var.availability_zone
  cpu  = var.cpu
  engine_version    = var.engine_version
  device_type       = var.device_type
  disk_type         = var.disk_type
  project_id        = var.project_id
  root_password     = local.root_password
  security_groups   = var.security_groups
  parameters        = var.parameters
  tags              = var.tags

  # payment configuration

  charge_type     = var.charge_type
  prepaid_period  = var.prepaid_period
  auto_renew_flag = var.auto_renew_flag
  force_delete    = var.force_delete

  # network configuration

  internet_service = var.internet_service
  intranet_port    = var.intranet_port
  subnet_id        = var.subnet_id
  vpc_id           = var.vpc_id

  # slave configuration (for BASIC_V2 / UNIVERSAL / EXCLUSIVE multi-AZ, NOT for CLOUD_NATIVE_CLUSTER)

  first_slave_zone  = var.first_slave_zone
  second_slave_zone = var.second_slave_zone
  slave_deploy_mode = var.slave_deploy_mode
  slave_sync_mode   = var.slave_sync_mode

  # cluster topology (for CLOUD_NATIVE_CLUSTER / CLOUD_NATIVE_CLUSTER_EXCLUSIVE, 新形态云盘版单节点/集群)
  # 单节点形态: 只传 read_write_node, read_only_nodes 不传 (空数组)
  dynamic "cluster_topology" {
    for_each = startswith(var.device_type, "CLOUD_NATIVE_CLUSTER") ? [1] : []
    content {
      read_write_node {
        zone = var.availability_zone
      }
      read_only_nodes {
        # is_random_zone=false + zone=availability_zone 跟 API 实际行为一致
        # 避免每次 plan 触发 RO 节点 destroy/create (state 里 is_random_zone 写 false, zone 写主 zone)
        is_random_zone = false
        zone           = var.availability_zone
      }
    }
  }
}

# KMS TDE storage encryption (independent resource, attached after instance creation)
resource "tencentcloud_mysql_instance_encryption_operation" "encryption" {
  count = var.set_mysql_encryption && var.create_mysql_instance ? 1 : 0

  instance_id = tencentcloud_mysql_instance.this[0].id
  key_id      = var.encryption_key_id
  key_region  = var.encryption_key_region

  depends_on = [tencentcloud_mysql_instance.this]
}

# SSL network transit encryption (separate resource, managed independently)
# When this resource is destroyed, SSL is automatically disabled on the instance.
resource "tencentcloud_mysql_ssl" "ssl" {
  count = var.set_mysql_ssl && var.create_mysql_instance ? 1 : 0

  instance_id = tencentcloud_mysql_instance.this[0].id
  status      = "ON"

  depends_on = [tencentcloud_mysql_instance.this]
}

