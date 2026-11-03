variable "region" {
  description = "OBS 桶所在区域"
  type        = string
  default     = "cn-north-4"
}

variable "bucket_prefix" {
  description = "桶名前缀（桶名全局唯一，会自动追加随机后缀）；只能包含小写字母、数字、中划线"
  type        = string
  default     = "iac-static-site"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,40}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix 只能包含小写字母、数字、中划线，长度 3~42，且不能以中划线开头或结尾。"
  }
}

variable "multi_az" {
  description = "是否多 AZ 存储；本实验要求单 AZ"
  type        = bool
  default     = false
}

variable "site_dir" {
  description = "静态网站文件目录，必须包含 index.html 与 error.html"
  type        = string
  default     = "./site"
}

variable "index_document" {
  description = "首页"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "错误页"
  type        = string
  default     = "error.html"
}
