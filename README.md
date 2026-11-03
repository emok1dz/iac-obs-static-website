# IaC部署OBS静态网站

ICT 大赛实践赛题 **1.19「基于 IaC 的静态网站自动化部署与访问控制」** 作品。

用 Terraform 在华为云 OBS 上完成静态网站部署，**一条 `terraform apply` 完成全部操作**：

| 步骤 | Terraform 资源 | 说明 |
| --- | --- | --- |
| 1. 创建桶 | `huaweicloud_obs_bucket` | 单 AZ（`multi_az = false`），标准存储，桶名自动加随机后缀保证全局唯一 |
| 2. 访问控制 | 桶 ACL + 对象 ACL | `public-read`：所有人可读、仅所有者可写，这是静态网站托管的前提 |
| 3. 上传文件 | `huaweicloud_obs_bucket_object`（for_each） | 自动上传 `site/` 下的全部文件，按扩展名设置 Content-Type；文件内容变化（MD5）时自动重新上传 |
| 4. 静态网站托管 | 桶的 `website` 配置 | 首页 `index.html`，错误页 `error.html` |
| 5. 输出访问链接 | `outputs.tf` | `website_url`、`error_page_url` |

> 与“Terraform 建桶 + obsutil 上传”的混合方案相比，本作品把文件上传也纳入了 Terraform 管理：不需要安装 obsutil，文件变更可以在 plan 中预览，`destroy` 时也能连同对象一起清理（`force_destroy = true`）。

## 文件

```
versions.tf               Provider 版本（凭证走环境变量 HW_ACCESS_KEY / HW_SECRET_KEY）
variables.tf              变量（带校验）
main.tf                   桶、ACL、对象上传、静态网站托管
outputs.tf                桶名、单AZ、已上传文件、访问链接
terraform.tfvars.example  参数示例
site/                     网站文件：index.html、error.html、style.css
terraform.tfstate         apply 后生成并提交，是资源真实创建的证明
docs/run-log.md           真实运行记录
```

## 使用

```bash
export HW_ACCESS_KEY="你的AK"          # PowerShell: $env:HW_ACCESS_KEY="..."
export HW_SECRET_KEY="你的SK"
cp terraform.tfvars.example terraform.tfvars

terraform fmt -recursive
terraform init
terraform validate
terraform plan        # 预期新建 5 个资源：random_id、obs_bucket、3 个 bucket_object
terraform apply
terraform output website_url

# 判题通过后清理（force_destroy 会先删除桶内对象）
terraform destroy
```

## 验证

```bash
curl -s "$(terraform output -raw website_url)"          # 返回首页 HTML（含 Hello IaC!）
curl -s "$(terraform output -raw error_page_url)"       # 返回错误页 HTML（含 404）
```

> **关于浏览器打开时变成下载**：出于安全合规要求，华为云中国大陆区域禁止通过 OBS **默认域名**在浏览器中在线预览网页，访问时会以附件形式下载。这不影响部署结果：用 `curl` 能看到正确内容，控制台中桶、对象、静态网站托管的配置也都正确。如果需要在浏览器中直接展示，可以为桶绑定自定义域名，或把 `region` 改为中国香港等区域（如 `ap-southeast-1`）。

费用：存储量不到 10KB，费用约为 0 元。
