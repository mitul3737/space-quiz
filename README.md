# Space Quiz

A space trivia quiz that lives in **one file**: `index.html`. Open it in a browser and answer ten
questions about planets, astronauts and telescopes. No installs, no build step, no internet needed.

This README explains, step by step, **how the project was made** and **how you can run it**, so
you can follow along even if this is your first project like this.

---

## 1. What is in this repository?

| File / folder | What it is |
| --- | --- |
| `index.html` | The whole quiz app. The HTML (page), CSS (looks) and JavaScript (logic) are all inside it. |
| `.github/copilot-instructions.md` | Notes for AI coding assistants describing how the quiz works and its rules. |
| `DEVIN_TASK.md` | The task list given to Devin (an AI software engineer) to extend the project. |
| `README.md` | This guide. |

After the open pull requests are merged (see section 3), you will also find `AGENTS.md`,
`devin.sh`, `.gitignore`, a `terraform/` folder and a GitHub Actions workflow.

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

Next, Devin was given [`DEVIN_TASK.md`](DEVIN_TASK.md) and asked to follow it. The task asked for
**three pull requests** (a pull request, or "PR", is a proposed change that a human reviews before
it is added to `main`):

| PR | What it adds | Why |
| --- | --- | --- |
| [#6](https://github.com/mitul3737/space-quiz/pull/6) | `AGENTS.md`, a Devin PR template, `devin.sh`, `.gitignore` | Gives Devin the project rules and a script to talk to the Devin API |
| [#7](https://github.com/mitul3737/space-quiz/pull/7) | A **30-second timer** on every question | Makes the quiz more of a challenge |
| [#8](https://github.com/mitul3737/space-quiz/pull/8) | A `terraform/` folder and a CI check | Lets you put the quiz on the internet using Amazon S3 |

How Devin worked, in plain words:

1. **Read the rules first.** It read `DEVIN_TASK.md` and `.github/copilot-instructions.md`.
2. **Installed the tools it needed:** the GitHub CLI (`gh`) and Terraform.
3. **Made one branch per PR** so each change can be reviewed on its own.
4. **Tested everything before opening the PRs:**
   - Ran the `devin.sh` script's syntax and error checks.
   - Played the quiz automatically in a real browser (Playwright): correct answers, timeouts,
     clicking at the last millisecond, leaving the tab, restarting, dark mode, reduced motion,
     keyboard only. 15 out of 15 checks passed with no errors.
   - Ran `terraform fmt` and `terraform validate`: "Success! The configuration is valid."
5. **Opened the three PRs** with a description of exactly how each one was tested.
6. **Did not merge anything.** A human reviews and merges.
7. **Kept secrets safe.** No passwords, API keys or Terraform state files are in the repo.

---

## 4. Final outcome

When PRs #6, #7 and #8 are merged into `main`, the project has:

- **The quiz** (`index.html`): ten shuffled questions, a score, a progress bar, explanations for every
  answer, light and dark themes, full keyboard support, and a **30-second countdown**. If time runs
  out, the answers lock, the correct one is shown, and you see "Time's up!".
- **Cloud hosting code** (`terraform/`): creates an Amazon S3 bucket, turns it into a website and
  uploads `index.html`. It defines 6 resources and prints the public website address.
- **An automatic check** (`.github/workflows/terraform.yml`): every PR that changes `terraform/` is
  checked by GitHub Actions. It never creates or deletes anything in AWS.
- **Devin setup** (`AGENTS.md`, `devin.sh`, PR template): rules and tools for future AI work.

---

## 5. How to run it

### Play the quiz on your computer (easiest)

1. Click the green **Code** button on GitHub, then **Download ZIP**, and unzip it
   (or run `git clone https://github.com/mitul3737/space-quiz.git`).
2. Double-click `index.html`. It opens in your browser. That's it.

**How to play:** click an answer, or press `1`-`4`. Use **Tab** and **Enter** to play with only
the keyboard. Press **Next question** to continue. After 10 questions you see your score and rank.

Optional: serve it from a tiny local web server instead:

```bash
python -m http.server 8000
# then open http://localhost:8000 in your browser
```

### Put the quiz on the internet with AWS S3 (optional, after PR #8 is merged)

You need [Terraform](https://developer.hashicorp.com/terraform/install) (version 1.6 or newer) and
an AWS account with credentials set up on your computer.

```bash
cd terraform
terraform init                     # download the AWS and random providers
terraform plan -out tfplan         # preview: "Plan: 6 to add"
terraform apply tfplan             # create the bucket and upload the quiz
terraform output -raw website_url  # copy this address into your browser
terraform destroy                  # delete everything when you are done (avoids costs)
```

On Windows PowerShell, pick your AWS profile first with `$env:AWS_PROFILE = "workshop"`.
More detail is in `terraform/README.md`.

### Use the Devin helper script (optional, after PR #6 is merged)

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

## 6. Credits

- Quiz built by following the [GitHub Copilot app tour](https://github-samples.github.io/copilot-workshops/first-steps/copilot-app/)
  workshop (by James Montemagno, MIT License).
- Extended by Devin following [`DEVIN_TASK.md`](DEVIN_TASK.md).
