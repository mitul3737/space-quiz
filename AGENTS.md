# Space Quiz: agent instructions

- The whole app is one file: `index.html`. Keep HTML, CSS and JavaScript in it.
- No build step, no npm packages, no CDN scripts.
- Support light and dark themes with `prefers-color-scheme`.
- Respect `prefers-reduced-motion`: no shake, pulse or transitions when it is set.
- Every control must work with the keyboard and show a visible focus ring.
- See `.github/copilot-instructions.md` for the quiz's state model and conventions.
- Infrastructure lives in `terraform/`. Never commit `.tfstate` files or keys.
- Open PRs using `.github/PULL_REQUEST_TEMPLATE/devin_pr_template.md`.
