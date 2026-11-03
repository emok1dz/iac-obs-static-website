# OBS 静态网站：创建桶（单 AZ、public-read）→ 上传 site/ 下全部文件 → 开启静态网站托管

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  bucket_name = "${var.bucket_prefix}-${random_id.suffix.hex}"
  site_files  = fileset(var.site_dir, "**")

  mime_types = {
    html = "text/html; charset=utf-8"
    htm  = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    js   = "application/javascript; charset=utf-8"
    json = "application/json"
    svg  = "image/svg+xml"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    gif  = "image/gif"
    webp = "image/webp"
    ico  = "image/x-icon"
    txt  = "text/plain; charset=utf-8"
  }
}

resource "huaweicloud_obs_bucket" "site" {
  bucket        = local.bucket_name
  storage_class = "STANDARD"
  multi_az      = var.multi_az
  acl           = "public-read" # 访问控制：静态网站需要公共读
  force_destroy = true          # destroy 时连同对象一起删除，避免残留计费

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  lifecycle {
    precondition {
      condition     = contains(local.site_files, var.index_document) && contains(local.site_files, var.error_document)
      error_message = "site_dir 中必须同时包含 index_document 与 error_document。"
    }
  }
}

# 每个文件一个对象：内容变化（etag）时自动重新上传
resource "huaweicloud_obs_bucket_object" "files" {
  for_each = local.site_files

  bucket       = huaweicloud_obs_bucket.site.bucket
  key          = each.value
  source       = "${var.site_dir}/${each.value}"
  etag         = filemd5("${var.site_dir}/${each.value}")
  acl          = "public-read"
  content_type = lookup(local.mime_types, lower(element(split(".", each.value), length(split(".", each.value)) - 1)), "application/octet-stream")
}
