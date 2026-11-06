# 运行记录

- 时间：2026-11-06T01:53Z（UTC）
- 环境：Terraform v1.9.8，huaweicloud provider v1.100.0，random v3.9.1；区域 cn-north-4
- 凭证：环境变量 HW_ACCESS_KEY / HW_SECRET_KEY（本文件和仓库中都不含凭证）

## 1. 验证链

```text
$ terraform fmt -recursive
$ terraform init
$ terraform validate
Success! The configuration is valid.

$ terraform plan -out tfplan
  # huaweicloud_obs_bucket.site will be created
  # huaweicloud_obs_bucket_object.files["error.html"] will be created
  # huaweicloud_obs_bucket_object.files["index.html"] will be created
  # huaweicloud_obs_bucket_object.files["style.css"] will be created
  # random_id.suffix will be created

Plan: 5 to add, 0 to change, 0 to destroy.
```

## 2. terraform apply

```text
random_id.suffix: Creation complete after 0s [id=wPD4]
huaweicloud_obs_bucket.site: Creation complete after 9s [id=iac-static-site-c0f0f8]
huaweicloud_obs_bucket_object.files["style.css"]: Creation complete after 2s [id=style.css]
huaweicloud_obs_bucket_object.files["index.html"]: Creation complete after 2s [id=index.html]
huaweicloud_obs_bucket_object.files["error.html"]: Creation complete after 2s [id=error.html]
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
bucket_name = "iac-static-site-c0f0f8"
error_page_url = "http://iac-static-site-c0f0f8.obs-website.cn-north-4.myhuaweicloud.com/not-exist"
multi_az = false
uploaded_files = tolist([
  "error.html",
  "index.html",
  "style.css",
])
website_url = "http://iac-static-site-c0f0f8.obs-website.cn-north-4.myhuaweicloud.com"
```

## 3. 访问验证

```text
$ curl -s -D - http://iac-static-site-c0f0f8.obs-website.cn-north-4.myhuaweicloud.com
HTTP/1.1 200 OK
server: OBS
content-type: text/html; charset=utf-8
... 页面内容包含：<h1>Hello IaC!</h1>

$ curl -s http://iac-static-site-c0f0f8.obs-website.cn-north-4.myhuaweicloud.com/not-exist
HTTP 404，页面内容包含：<h1>页面未找到</h1>
```

首页与错误页都按配置返回。由于华为云中国大陆区域对 OBS 默认域名的合规要求，响应带有 `content-disposition: attachment`，浏览器打开时会下载而不是直接显示（见 README 说明），部署本身正确。

## 4. 资源状态

`terraform.tfstate` 已提交到仓库，记录了 OBS 桶 `iac-static-site-c0f0f8` 和 3 个对象的真实 ID。

## 5. 清理

判题通过后执行 `terraform destroy`（`force_destroy = true` 会先删除桶内对象）。
