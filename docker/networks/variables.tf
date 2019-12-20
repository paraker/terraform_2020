variable "mysql_root_password" {
  description = "the root paassword for mysql"
  default = "P4$$w0rd"
}

variable "ghost_db_username" {
  description = "ghost blog  database username"
  default = "root"
}

variable "ghost_db_name" {
  description = "ghost blog db name"
  default = "ghost"
}

# To be able to refer to the db resource on the network I believe
variable "mysql_network_alias" {
  description = "the network alias for mysql"
  default = "db"
}

# This is not really necessary, but we set it anyway
variable "ghost_network_alias" {
  description = "the network alias for ghost"
  default = "ghost"
}

variable "ext_port" {
  description = "public port for ghost"
  default = "8080"
}