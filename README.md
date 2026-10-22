# Space Quiz

A single-file space trivia quiz: open `index.html` in a browser and play ten questions. No build step, no dependencies.

## How this project was made

1. **Built with GitHub Copilot.** The quiz was created from an empty folder by following the
   [GitHub Copilot app tour](https://github-samples.github.io/copilot-workshops/first-steps/copilot-app/)
   workshop: build and polish the quiz, add project instructions (`.github/copilot-instructions.md`),
   publish the repo, and work through issues and pull requests.
2. **Extended with Devin and HashiCorp Terraform.** Devin then followed [`DEVIN_TASK.md`](DEVIN_TASK.md)
   and opened three pull requests:

   | PR | Branch | What it adds |
   | --- | --- | --- |
   | 1 | `devin/setup` | Devin PR template, `AGENTS.md`, `devin.sh` API helper, `.gitignore`, this README |
   | 2 | `devin/issue-2-timer` | A 30-second countdown for every question |
   | 3 | `devin/terraform-s3` | `terraform/` to host the quiz on an S3 static website, plus a CI workflow |

## Final outcome

With all three PRs merged, the repo contains:

- **`index.html`**: the complete quiz. It has ten shuffled questions, light and dark themes, keyboard
  play (Tab/Enter or `1`-`4`), and `prefers-reduced-motion` support. Each question has a
  30-second timer. When it runs out, the answers lock, the correct answer is revealed, and
  "Time's up" is shown.
- **`terraform/`**: AWS provider v6 configuration that creates an S3 bucket, website config,
  public-read policy and uploads `index.html`. It defines 6 resources and outputs `website_url`.
- **`.github/workflows/terraform.yml`**: runs `fmt -check`, `validate` and, only when AWS secrets
  exist, `plan` on every PR touching `terraform/**`. It never applies or destroys.
- **`AGENTS.md`**, **`.github/PULL_REQUEST_TEMPLATE/devin_pr_template.md`** and **`devin.sh`**:
  the rules, PR template and API helper Devin works with.

## How to run

### Play the quiz locally

Open `index.html` directly in a browser (double-click it, or use a `file://` URL). No server or
network is needed. To serve it instead:

```bash
python -m http.server 8000   # then open http://localhost:8000
```

### Deploy to AWS S3 (optional)

Requires Terraform >= 1.6 and AWS credentials. See [`terraform/README.md`](terraform/README.md) for
the full guide and PowerShell equivalents.

```bash
cd terraform
terraform init
terraform plan -out tfplan         # expect: Plan: 6 to add
terraform apply tfplan             # prints website_url
terraform output -raw website_url  # open it in a browser
terraform destroy                  # remove everything when done
```

Never commit `.tfstate` files, `tfplan` or keys; `.gitignore` already excludes them.

## Devin

`devin.sh` is a small helper for calling the Devin API. `jq` and `curl` are required.

Export your credentials first:

```bash
export DEVIN_API_KEY=cog_...
export DEVIN_ORG_ID=...
```

Then run one of:

```bash
./devin.sh create "prompt"              # start a new Devin session
./devin.sh list                         # list sessions
./devin.sh msg SESSION_ID "message"     # send a message to a session
./devin.sh note                         # create the Space Quiz knowledge note
```
