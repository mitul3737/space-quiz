# Terraform: Space Quiz on S3

Hosts `index.html` as a static website on AWS S3. Never commit `.tfstate` files or AWS keys.

## Bash

```bash
cd terraform
terraform init                     # download aws + random providers
terraform fmt                      # format files
terraform validate                 # syntax check, no AWS calls
terraform plan -out tfplan         # expect: Plan: 6 to add, 0 to change, 0 to destroy
terraform apply tfplan             # creates bucket, prints website_url
terraform output -raw website_url  # open it in a browser
terraform state list               # the 6 tracked resources
terraform destroy                  # deletes everything
```

## PowerShell

```powershell
cd terraform
$env:AWS_PROFILE = "workshop"
terraform init                     # download aws + random providers
terraform fmt                      # format files
terraform validate                 # syntax check, no AWS calls
terraform plan -out tfplan         # expect: Plan: 6 to add, 0 to change, 0 to destroy
terraform apply tfplan             # creates bucket, prints website_url
$URL = terraform output -raw website_url
curl.exe -I $URL                   # expect HTTP/1.1 200 OK
terraform state list               # the 6 tracked resources
terraform destroy                  # deletes everything
```
