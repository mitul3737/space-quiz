# Space Quiz

A space trivia quiz that lives in **one file**: `index.html`. Open it in a browser and answer ten
questions about planets, astronauts and telescopes, each with a 30-second timer. No installs, no build
step, no internet needed.

This README explains, step by step, **how the project was made**, **how to test it** and **how to
put it on the internet with AWS**, so you can follow along even if this is your first project like this.

---

## 1. What is in this repository?

| File / folder | What it is |
| --- | --- |
| `index.html` | The whole quiz app. The HTML (page), CSS (looks) and JavaScript (logic) are all inside it. |
| `terraform/` | Code that creates an Amazon S3 website and uploads the quiz to it. |
| `.github/workflows/terraform.yml` | A GitHub Actions check that tests the Terraform code on every pull request. |
| `.github/copilot-instructions.md` | Notes for AI assistants describing how the quiz works and its rules. |
| `.github/PULL_REQUEST_TEMPLATE/devin_pr_template.md` | The template Devin uses when it opens pull requests. |
| `AGENTS.md` | Short rules every AI agent must follow in this repo. |
| `devin.sh` | A small script for talking to the Devin API from your terminal. |
| `DEVIN_TASK.md` | The task list given to Devin to extend the project. |
| `.gitignore` | Tells Git never to upload Terraform state, plans, `.env` files or keys. |

---

## 2. Step one: building the quiz with GitHub Copilot

The quiz was created from an **empty folder** by following this free workshop:

**[GitHub Copilot app tour](https://github-samples.github.io/copilot-workshops/first-steps/copilot-app/)**

In that workshop you:

1. Install the GitHub Copilot app and open an empty folder.
2. Ask Copilot to build a colorful space quiz in a single `index.html`.
3. Polish it in the built-in browser: light and dark themes, keyboard play, animations.
4. Add project instructions (`.github/copilot-instructions.md`) so the AI follows the same rules every time.
5. Publish the folder as a GitHub repository (this one).
6. Create GitHub issues (ideas for new features) and let Copilot implement them in pull requests.
   For example, PR #5 made the question order shuffle on every new game.

---

## 3. Step two: extending it with Devin and HashiCorp Terraform

Next, Devin was given [`DEVIN_TASK.md`](DEVIN_TASK.md) and asked to follow it. Devin opened **three
pull requests** (a pull request, or "PR", is a proposed change that a human reviews before it is
added to `main`). All three have been reviewed and **merged**:

| PR | What it added | Why |
| --- | --- | --- |
| [#6](https://github.com/mitul3737/space-quiz/pull/6) | `AGENTS.md`, a Devin PR template, `devin.sh`, `.gitignore` | Gives Devin the project rules and a script to talk to the Devin API |
| [#7](https://github.com/mitul3737/space-quiz/pull/7) | A **30-second timer** on every question | Makes the quiz more of a challenge |
| [#8](https://github.com/mitul3737/space-quiz/pull/8) | A `terraform/` folder and a CI check | Lets you put the quiz on the internet using Amazon S3 |

How Devin worked, in plain words:

1. **Read the rules first.** It read `DEVIN_TASK.md` and `.github/copilot-instructions.md`.
2. **Installed the tools it needed:** the GitHub CLI (`gh`) and Terraform.
3. **Made one branch per PR** so each change could be reviewed on its own.
4. **Tested everything before opening the PRs** (the same tests are in section 5 so you can repeat them).
5. **Opened the three PRs**, each describing exactly how it was tested.
6. **Did not merge anything itself.** A human reviewed and merged.
7. **Kept secrets safe.** No passwords, API keys or Terraform state files are in the repo.

---

## 4. Final outcome

- **The quiz** (`index.html`): ten shuffled questions, a score, a progress bar, explanations for every
  answer, light and dark themes, full keyboard support, and a **30-second countdown**. If time runs
  out, the answers lock, the correct one is shown, and you see "Time's up!".
- **Cloud hosting code** (`terraform/`): creates an Amazon S3 bucket, turns it into a public website
  and uploads `index.html`. That is 6 resources, and it prints the website address at the end.
- **An automatic check** (`.github/workflows/terraform.yml`): every PR that changes `terraform/` is
  checked by GitHub Actions. It never creates or deletes anything in AWS.
- **Devin setup** (`AGENTS.md`, `devin.sh`, PR template): rules and tools for future AI work.

---

## 5. How to test it

### 5.1 Get the code

Click the green **Code** button on GitHub, then **Download ZIP** and unzip it, or run:

```bash
git clone https://github.com/mitul3737/space-quiz.git
cd space-quiz
```

### 5.2 Play and test the quiz (no tools needed)

Double-click `index.html` to open it in your browser. (Or run `python -m http.server 8000` in the
folder and open <http://localhost:8000>.)

**How to play:** click an answer, or press `1`-`4`. Use **Tab** and **Enter** to play with only the
keyboard. Press **Next question** to continue. After 10 questions you see your score and rank.

Work through this checklist. Each line should behave exactly as described:

| # | What to do | What you should see |
| --- | --- | --- |
| 1 | Answer the first question correctly | Green check, score goes up by 1, the timer stops |
| 2 | On the next question, wait 30 seconds without answering | "Time's up! The answer was ...", the correct answer is shown in green, all answers are locked, score does not change, **Next** is enabled |
| 3 | After time is up, try clicking an answer or pressing `1` | Nothing happens |
| 4 | Answer wrongly on purpose | Red cross on your choice, the correct answer is shown, no point |
| 5 | When 10 seconds or less are left | The timer turns red and gently pulses |
| 6 | Switch to another browser tab for 35 seconds, then come back | The question has already timed out; you cannot answer it |
| 7 | Finish all 10 questions, then click **Launch another mission** | Score and progress reset, timer starts again at 30 |
| 8 | Play using only **Tab**, **Enter** and `1`-`4` | Everything works and the focused button has a visible outline |
| 9 | Switch your computer to dark mode | The quiz switches to dark colors and the timer is still easy to read |
| 10 | Turn on "reduce motion" in your OS settings | No shaking or pulsing, but the timer number still counts down |
| 11 | Open the browser console (F12 → Console) while playing | No red errors |

To change dark mode or reduced motion quickly in Chrome or Edge: press F12, then `Ctrl+Shift+P`, and
type **Rendering**. In the Rendering panel, change *Emulate CSS media feature prefers-color-scheme* or
*prefers-reduced-motion*.

### 5.3 Test the Terraform code (free, no AWS account needed)

Install [Terraform](https://developer.hashicorp.com/terraform/install) version 1.6 or newer
(Windows: `winget install Hashicorp.Terraform`, macOS: `brew install hashicorp/tap/terraform`), then:

```bash
cd terraform
terraform fmt -check -recursive   # no output = the files are formatted correctly
terraform init -backend=false     # downloads the AWS and random providers
terraform validate                # expect: Success! The configuration is valid.
```

These commands do not talk to AWS and cost nothing. GitHub Actions runs the same three commands on
every pull request that changes `terraform/`. You can see the results on the repo's **Actions** tab.

### 5.4 Test the Devin helper script (needs bash: Git Bash on Windows, Terminal on macOS/Linux)

```bash
bash -n devin.sh                               # no output = no syntax errors
DEVIN_API_KEY=x DEVIN_ORG_ID=x ./devin.sh      # prints the usage line
./devin.sh list                                # without keys: "Run: export DEVIN_API_KEY=cog_..."
```

None of these call the real Devin API.

---

## 6. How to run it on AWS (put the quiz on the internet)

This creates a real public website on Amazon S3. It costs only a few cents a month for a single
small page (and may be free on the AWS Free Tier), but **remember to delete it with
`terraform destroy` when you are done** (step 6.6).

### 6.1 What you need

- An [AWS account](https://aws.amazon.com/).
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.6 or newer (see 5.3).
- The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  (Windows: `winget install Amazon.AWSCLI`), used here only to store your credentials.

### 6.2 Create AWS credentials (one time)

1. Sign in to the AWS Console and open **IAM** → **Users** → **Create user** (for example `workshop`).
2. Attach the **AmazonS3FullAccess** policy. That is enough for this project.
3. Open the user → **Security credentials** → **Create access key** → choose *Command Line Interface*.
4. Save the **Access key ID** and **Secret access key** somewhere safe. **Never** put them in this
   repo, in a commit, or in an issue or PR comment.

Store them on your computer as a named profile:

```bash
aws configure --profile workshop
# AWS Access Key ID:     <paste>
# AWS Secret Access Key: <paste>
# Default region name:   ap-south-1
# Default output format: json
```

### 6.3 Choose your profile

```bash
export AWS_PROFILE=workshop          # macOS / Linux / Git Bash
```

```powershell
$env:AWS_PROFILE = "workshop"        # Windows PowerShell
```

Check it works with `aws sts get-caller-identity`. It should print your account and user.

### 6.4 Preview and create the website

```bash
cd terraform
terraform init                     # download the AWS and random providers
terraform plan -out tfplan         # preview: "Plan: 6 to add, 0 to change, 0 to destroy"
terraform apply tfplan             # creates the 6 resources and prints website_url
```

The 6 resources are: a random name suffix, the S3 bucket, its website settings, its public access
settings, a public-read policy, and the uploaded `index.html`.

The default region is `ap-south-1` (Mumbai). To use another region, add `-var region=us-east-1` to
the `plan` command.

### 6.5 Open and check the website

```bash
terraform output -raw website_url   # e.g. http://space-quiz-1a2b3c4d.s3-website.ap-south-1.amazonaws.com
curl -I "$(terraform output -raw website_url)"   # expect: HTTP/1.1 200 OK
terraform state list                 # shows the 6 resources Terraform is tracking
```

On Windows PowerShell:

```powershell
$URL = terraform output -raw website_url
curl.exe -I $URL                     # expect: HTTP/1.1 200 OK
start $URL                           # opens it in your browser
```

Open the URL in your browser and play the quiz from the internet. If you change `index.html`, run
`terraform plan -out tfplan` and `terraform apply tfplan` again to upload the new version.

### 6.6 Delete everything when you are done

```bash
terraform destroy                   # type "yes" when asked; expect: Destroy complete! Resources: 6 destroyed.
```

### 6.7 If something goes wrong

| Problem | Fix |
| --- | --- |
| `No valid credential sources found` | Run step 6.3 again in the same terminal and check `aws sts get-caller-identity` |
| `AccessDenied` when creating the bucket policy | Your AWS account has *Block Public Access* turned on for the whole account. Turn it off under **S3 → Block Public Access settings for this account**, or skip public hosting |
| `BucketAlreadyExists` | Very rare (names are random). Run `terraform apply` again |
| The URL shows `403 Forbidden` | Wait a minute and refresh; the public policy can take a moment to apply |

Terraform keeps its memory of what it created in `terraform/terraform.tfstate` on your computer.
Do not delete it until after `terraform destroy`, and never commit it (`.gitignore` already blocks it).

### 6.8 Optional: let GitHub Actions run `terraform plan`

In the repo on GitHub, go to **Settings → Secrets and variables → Actions → New repository secret**
and add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. The workflow will then also run
`terraform plan` on pull requests. It never runs `apply` or `destroy`, and the secrets are never
printed.

---

## 7. Use the Devin helper script (optional)

`devin.sh` needs `bash`, `curl` and `jq`. Export your Devin credentials first, and never commit them:

```bash
export DEVIN_API_KEY=cog_...
export DEVIN_ORG_ID=...

./devin.sh create "prompt"              # start a new Devin session
./devin.sh list                         # list sessions
./devin.sh msg SESSION_ID "message"     # send a message to a session
./devin.sh note                         # create the Space Quiz knowledge note
```

---

## 8. Credits

- Quiz built by following the [GitHub Copilot app tour](https://github-samples.github.io/copilot-workshops/first-steps/copilot-app/)
  workshop (by James Montemagno, MIT License).
- Extended by Devin following [`DEVIN_TASK.md`](DEVIN_TASK.md).
