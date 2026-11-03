output "bucket_name" {
  description = "OBS 桶名"
  value       = huaweicloud_obs_bucket.site.bucket
}

output "multi_az" {
  description = "是否多 AZ（预期 false，即单 AZ）"
  value       = huaweicloud_obs_bucket.site.multi_az
}

output "uploaded_files" {
  description = "已上传的文件"
  value       = sort(keys(huaweicloud_obs_bucket_object.files))
}

output "website_url" {
  description = "静态网站访问链接"
  value       = "http://${huaweicloud_obs_bucket.site.bucket}.obs-website.${var.region}.myhuaweicloud.com"
}

output "error_page_url" {
  description = "访问一个不存在的路径，验证错误页"
  value       = "http://${huaweicloud_obs_bucket.site.bucket}.obs-website.${var.region}.myhuaweicloud.com/not-exist"
}
