# Project Decisions Log

This document records the major architectural, design, and technical decisions made for this project.

## Summary Log

| ID | Date | Decision | Status |
| :--- | :--- | :--- | :--- |
| 001 | 2026-09-28 | [Terraform exclusions](#001-terraform-exclusions) | Accepted |

---

## 001: Terraform exclusions

### Context
If you wanted to Terraform pre-chat form and customer widget, you'd be fighting the provider, not just adding boilerplate.

### Decision
We will exclude **Pre-chat form and customer widget** from Terraform.

### Consequences
How to to keep some IaC discipline without a native resource:

- **Pros** Treat contact flows, queues, routing profiles, Lambda associations, hours of operation — the stuff with real Terraform resources — as your actual IaC boundary. That's the right line to draw.
- **Cons** For the View and widget config, export the View JSON (aws connect describe-view or the console export) after every meaningful change and commit it to the repo alongside your Terraform code — not as something Terraform applies, but as a version-controlled record so changes are diffable and reviewable in git history.
- **Cons** If you want actual repeatability beyond click-ops (e.g., recreating this in a new environment), a lightweight boto3/CLI script that calls CreateView / UpdateViewContent / CreateViewVersion is a reasonable middle ground — not "real" Terraform, but scripted and reviewable, which is most of what you actually want out of IaC for something this small and low-churn.
- **Pros** Document the manual steps as a short runbook (which Contact Flow ID the Connect Action should point to, which View is live, what the widget's Communication options should show) so it's reproducible by someone else even though it lives outside Terraform state.

### Summary
This is a pretty common and accepted split in real Connect deployments — flows/queues/routing get Terraformed because they're API-native and change often; Views and widget snippets tend to stay console-managed with JSON exports as the audit trail, because the tooling genuinely isn't there yet.
