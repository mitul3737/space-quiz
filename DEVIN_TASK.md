# Devin task: add the Devin and HashiCorp Terraform parts to the Space Quiz repo

**Repository:** `mitul3737/space-quiz` (if you were given a different repo, use that one instead)
**Default branch:** `main`
**Your job:** open **three pull requests**, in this order, then report back. Do not merge anything; a human reviews and merges.

| PR | Branch | What it delivers |
| --- | --- | --- |
| 1 | `devin/setup` | Devin PR template, `AGENTS.md`, `devin.sh` API helper, `.gitignore` |
| 2 | `devin/issue-2-timer` | Implements GitHub issue #2 (30-second timer per question) |
| 3 | `devin/terraform-s3` | `terraform/` folder that hosts `index.html` on an S3 static website, plus a CI workflow that runs `fmt`, `validate` and `plan` |

---

## Ground rules (read first)

1. **The app is one file: `index.html`.** HTML, CSS and JavaScript stay inline. No build step, no npm packages, no CDN scripts, no new files for the app.
2. **Do not rewrite or restyle `index.html`** beyond what issue #2 needs. The quiz already exists and works; keep its look, questions and structure.
3. Keep light and dark themes (`prefers-color-scheme`), keyboard play, visible focus rings, and `prefers-reduced-motion` support.
4. Read `.github/copilot-instructions.md` before editing; it describes the quiz's state model (`current`, `score`, `answered`, `renderQuestion()`, `chooseAnswer()`). Follow it.
5. **Never commit secrets.** No AWS keys, no Devin API keys, no `.tfstate` files.
6. **Do not run `terraform apply` or `terraform destroy`** unless the "Optional: live deploy" section below says the secrets exist. Plan only.
7. Each PR description must use the template from PR 1 and say exactly how you tested it.

---

## PR 1: Devin setup files (`devin/setup`)

Create these files exactly. If a file already exists, merge the content in rather than replacing what is there.

### `.github/PULL_REQUEST_TEMPLATE/devin_pr_template.md`

Devin uses this for its own PRs; humans keep the default template.

```markdown
## What changed

## Linked issue
Closes #

## How to test
1. Open index.html in a browser
2. Play all 10 questions in light and dark mode
3. Play once using only the keyboard (Tab, Enter)

## Checklist
- [ ] Still a single index.html with no dependencies
- [ ] Keyboard-only play works
- [ ] prefers-reduced-motion respected
- [ ] No secrets or .tfstate files committed
```

### `AGENTS.md`

```markdown
# Space Quiz: agent instructions

- The whole app is one file: `index.html`. Keep HTML, CSS and JavaScript in it.
- No build step, no npm packages, no CDN scripts.
- Support light and dark themes with `prefers-color-scheme`.
- Respect `prefers-reduced-motion`: no shake, pulse or transitions when it is set.
- Every control must work with the keyboard and show a visible focus ring.
- See `.github/copilot-instructions.md` for the quiz's state model and conventions.
- Infrastructure lives in `terraform/`. Never commit `.tfstate` files or keys.
- Open PRs using `.github/PULL_REQUEST_TEMPLATE/devin_pr_template.md`.
```

### `devin.sh` (repo root, make it executable: `chmod +x devin.sh`)

```bash
#!/usr/bin/env bash
# Devin API helper for the Space Quiz workshop.
# Usage:
#   ./devin.sh create "prompt"
#   ./devin.sh list
#   ./devin.sh msg SESSION_ID "message"
#   ./devin.sh note
set -euo pipefail
: "${DEVIN_API_KEY:?Run: export DEVIN_API_KEY=cog_...}"
: "${DEVIN_ORG_ID:?Run: export DEVIN_ORG_ID=...}"

API="https://api.devin.ai/v3/organizations/$DEVIN_ORG_ID"
AUTH=(-H "Authorization: Bearer $DEVIN_API_KEY" -H "Content-Type: application/json")

case "${1:-}" in
  create)
    curl -s -X POST "$API/sessions" "${AUTH[@]}" \
      -d "$(jq -n --arg p "$2" '{prompt: $p}')" | jq .
    ;;
  list)
    curl -s "$API/sessions" "${AUTH[@]}" | jq .
    ;;
  msg)
    curl -s -X POST "$API/sessions/$2/messages" "${AUTH[@]}" \
      -d "$(jq -n --arg m "$3" '{message: $m}')" | jq .
    ;;
  note)
    curl -s -X POST "$API/knowledge/notes" "${AUTH[@]}" \
      -d '{"name":"Space Quiz rules","trigger":"When working on space-quiz","body":"Single index.html, no dependencies, keep light and dark themes, respect prefers-reduced-motion, keyboard accessible."}' | jq .
    ;;
  *)
    echo "usage: $0 create \"prompt\" | list | msg SESSION_ID \"message\" | note"
    exit 1
    ;;
esac
```

### `.gitignore` (create or append; do not duplicate lines)

```text
# Terraform
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.*
terraform/tfplan
terraform/crash.log

# Secrets
.env
*.pem

# OS
.DS_Store
```

### README

Add a short **Devin** section to `README.md` (create the file if missing) explaining `./devin.sh` usage and that `DEVIN_API_KEY` / `DEVIN_ORG_ID` must be exported first.

### Acceptance criteria

- [ ] `bash -n devin.sh` passes and `./devin.sh` with no args prints the usage line and exits 1
- [ ] `./devin.sh list` without env vars fails with the "Run: export DEVIN_API_KEY" message (do not call the real API)
- [ ] The template, `AGENTS.md` and `.gitignore` match the content above
- [ ] `index.html` is untouched in this PR

---

## PR 2: Implement issue #2, 30-second timer (`devin/issue-2-timer`)

Read issue #2 in full (`gh issue view 2`) and meet **all** of its acceptance criteria. If a Copilot plan for this issue was posted, use it as a starting point. Summary of what is expected:

- A fresh 30-second countdown starts when each question is shown, including the first question and after restart.
- Remaining time is clearly visible in both themes, with an accessible label. Do **not** announce every second through a live region; announce only the timeout.
- The countdown stops immediately when an answer is chosen.
- At zero: lock all answer choices, count the question as answered incorrectly (score unchanged, answered progress +1), reveal the correct answer and explanation, show an explicit "Time's up" message, and enable Next (or the results action on the last question).
- No double events: a late click, a keyboard selection and a timeout racing each other must score or complete the question exactly once.
- Use elapsed time (`performance.now()` or a stored deadline), so switching tabs or delayed timer callbacks cannot give extra time. An expired question must reject answers when the player returns.
- Clear the previous countdown when advancing, restarting or showing results, so old callbacks cannot affect another question.
- With `prefers-reduced-motion: reduce`, no pulsing or animated countdown visuals; the number still updates.
- Everything stays inside `index.html`.

### How to test (put the results in the PR description)

Serve the folder (`python3 -m http.server 8000`) and use Playwright or a real browser:

1. Answer question 1 correctly before the timer ends: score +1, timer stops.
2. Let question 2 run out: "Time's up", correct answer revealed, score unchanged, choices locked, Next enabled.
3. Click an answer in the same tick as the timeout (simulate by stubbing time): scored exactly once.
4. Hide the tab for 35 seconds, return: the question is expired and rejects answers.
5. Finish all 10 questions, restart: timer restarts at 30 for question 1.
6. Repeat 1-2 in dark mode and with reduced motion emulated.
7. Keyboard only: Tab to an answer, Enter, Enter for Next.
8. No console errors at any point.

---

## PR 3: Terraform on AWS S3 (`devin/terraform-s3`)

Create a `terraform/` folder with exactly these four files. They use the HashiCorp AWS provider v6.

### `terraform/versions.tf`

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "space-quiz"
      ManagedBy = "terraform"
    }
  }
}
```

### `terraform/variables.tf`

```hcl
variable "region" {
  description = "AWS region for the bucket"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Prefix for resource names"
  type        = string
  default     = "space-quiz"
}

variable "site_file" {
  description = "Path to the quiz page to upload"
  type        = string
  default     = "../index.html"
}
```

### `terraform/main.tf`

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "site" {
  bucket        = "${var.project}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.site.id
  depends_on = [aws_s3_bucket_public_access_block.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = var.site_file
  etag         = filemd5(var.site_file)
  content_type = "text/html"
}
```

### `terraform/outputs.tf`

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.site.id
}

output "website_url" {
  description = "Public URL of the Space Quiz"
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
```

### `terraform/README.md`

Write a short guide with the command sequence the workshop uses, one line each:

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

Include PowerShell equivalents for Windows (`$env:AWS_PROFILE = "workshop"`, `$URL = terraform output -raw website_url`, `curl.exe -I $URL`).

### `.github/workflows/terraform.yml`

A CI workflow that checks the Terraform on every PR that touches `terraform/**`:

- Triggers: `pull_request` with `paths: ["terraform/**"]`, plus `workflow_dispatch`.
- Uses `hashicorp/setup-terraform@v3`.
- Runs `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`.
- Runs `terraform plan` **only if** the repo secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exist (check with an `if:` on an env flag). Pass them as env vars from `secrets`; never echo them.
- Never runs `apply` or `destroy`.
- `permissions: contents: read`.

### Acceptance criteria

- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform init -backend=false && terraform validate` prints `Success! The configuration is valid.`
- [ ] Without AWS credentials, the workflow still goes green (fmt + validate only)
- [ ] `.gitignore` covers `.terraform/`, `*.tfstate*` and `tfplan`, so none of them appear in the diff
- [ ] No hard-coded bucket names, account IDs, keys or ARNs

### Optional: live deploy (only if secrets exist)

Only if `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are available to you as Devin secrets:

1. `terraform init && terraform plan -out tfplan`: confirm `6 to add`.
2. `terraform apply tfplan`, then `curl -I "$(terraform output -raw website_url)"`: expect `HTTP/1.1 200 OK`.
3. Put the URL and the curl status line in the PR description.
4. **Immediately** run `terraform destroy -auto-approve` and confirm `Resources: 6 destroyed.` Add that line to the PR description too.

If the secrets are not available, skip this section and say so in the PR description. Do not ask for credentials in a PR comment or commit them anywhere.

---

## When you finish, reply with

- The three PR links
- For each PR: the test results (pass/fail per acceptance criterion)
- Anything you could not do and why (for example, missing AWS secrets)
- Anything in issue #2 you interpreted, with your reasoning

## Not your job

- Do not merge any PR.
- Do not change repository settings, branch protection, GitHub Pages or Actions permissions.
- Do not create AWS IAM users, keys or any resources outside the six in `main.tf`.
- Do not implement issue #3 (keyboard shortcuts 1-4); it is reserved for a live `/devin` PR-comment demo.
