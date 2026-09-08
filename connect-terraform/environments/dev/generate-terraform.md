# Generating terraform 

## Purpose and Steps needed

- Our purpose is to terraform as IaC a lambda created from clickops
- Use an `import` block lkie

```hcl
# imports.tf
import {
  to = aws_lambda_function.demo_connect_lambda
  id = "<LambdaName>"
}
```

The `import` block in `imports.tf` only tells Terraform what to *import*; it doesn't create the resource block itself.
If errors from `terraform plan` have occurred that came from running `generate-config-out` — I'd need to do that again, now, for the role in my case.

Then run
1. setup your directory structure
1. Files like `versions.tf`, `providers.tf` setup, `backend.tf` for remote setup
1. `terraform init`
1. `terraform plan -generate-config-out=generated_lambda.tf`
1. Review generated file - you'll probably want to also import or recreate as a proper `aws_iam_role` resource rather than leaving it as a bare string
1. `terraform plan` again — should show **0 to add, 0 to change** once the generated config accurately matches reality (this is the real acceptance criterion for a clean import).
1. `terraform apply` to commit it into state.
1. **Delete the `import` block** afterward — it's only needed for the one-time import, not ongoing config.
1. Add into GitHub.

## How to actually check for changes between Terraform versions

Don't rely on the version constraint alone as your safety net — use it alongside:

- **HashiCorp's Upgrade Guides** (`developer.hashicorp.com/terraform/language/upgrade-guides`) — published per release, calls out behavior changes explicitly.
- **The CHANGELOG** on the `hashicorp/terraform` GitHub repo — more granular, every release.
- **The real practical check:** after upgrading your CLI, run `terraform plan` before ever touching `apply`. If a version genuinely changed something relevant to your config, this is where it surfaces — an unexpected diff on resources you didn't touch. That's a more reliable signal than trying to pre-read every changelog line for relevance to your specific setup.

## Errors that may appear

- one of `filename,image_uri,s3_bucket` must be specified

`filename` / `image_uri` / `s3_bucket` describe **where Terraform should source the deployment package from** — they're not attributes of the *deployed* function that AWS can hand back to you on inspection. When I created the function via console paste, AWS stored the compiled artifact, but there's no "original source location" for Terraform to read back and reconstruct one of these three fields. Config generation faithfully reflects everything else about my function (runtime, handler, timeout, role, etc.), but leaves this one un-fillable — hence three nulls and three validation errors, since the provider requires exactly one of them.

This is the right IaC instinct anyway: **Terraform should own and version my Lambda's source code, not scrape whatever's currently deployed.**

So the fix is also an improvement 

- bring my actual Python file into the repo as the source of truth going forward - added via file `lambda_function.py`
- I added the `archive` provider (zips my source at plan/apply time — standard companion to `aws_lambda_function`): see `versions.tf`
- **Add a zip data source (again in versions.tf), and edit the generated block to use it**
  - `filename = data.archive_file.lambda_zip.output_path`
    - In addition:
    - `source_code_hash = data.archive_file.lambda_zip.output_base64sha256`

- **Remove the two other null lines** (`image_uri = null`, `s3_bucket = null`, and their related `s3_key/s3_object_version` if generated) — only `filename` should remain among that trio.
- then `terraform plan`

**Why source_code_hash wasn't in the generated file:** `source_code_hash` is tied to how you're sourcing the code (`filename`/`s3_bucket`/`image_uri`), and since none of those three could be filled in automatically, the generator had nothing to compute a hash against — so it just left it out entirely rather than guessing. Same root cause as the three null errors, just manifesting as an omission instead.

## Why the hashes will basically never match

- Why won't `source_code_hash` match `code_sha256`

`code_sha256` (AWS's value) is the SHA256 of the **actual deployed ZIP archive** — the literal bytes AWS is storing, including zip-format metadata like file timestamps, compression method, and internal file permissions/mode bits. `source_code_hash` is computed the same way, but from a ZIP that Terraform's `archive_file` **data source builds itself,** right now, on my machine.

Even with byte-identical Python source, two independently-created ZIPs of that same file will almost never hash identically — the zip container format bakes in things like the modification timestamp of the file at zip-creation time, which differs between "whenever the console originally packaged it" and "the moment I ran `terraform plan` today." This is a well-known, essentially unavoidable characteristic of comparing a hand/console-deployed Lambda against `archive_file`

- The `first apply` will **redeploy the function** using Terraform's freshly-built zip (functionally identical code, just re-packaged). From that point forward, **Terraform becomes the single source of truth for the zip** — every subsequent `terraform plan` will compare against Terraform's own consistently-built archive,

## Gitleaks and Account-id

Why `gitleaks detect` did not report account-ids in `imports.tf`

- `gitleaks detect` did not report my `imports.tf` file because Gitleaks does not scan files that are excluded by `.gitignore` *unless you explicitly tell it to.*
So my ignored file was **never scanned,** which is why the ARN containing my AWS account ID didn’t trigger a finding.

This is one of the most misunderstood behaviours of Gitleaks.
**Gitleaks respects** `.gitignore` **unless you override it.**

### Why your AWS account ID inside an ARN didn’t trigger

Even if the file was scanned, Gitleaks does not treat AWS account IDs as secrets.

```hcl
arn:aws:iam::<account-id>>:role/my-role
```

The `<account-id>>` portion is **not considered sensitive** by Gitleaks because:
- It is not a credential
- It is not a token
- It is not a password
- It is not a private key
- It is not a secret value

AWS account IDs are intentionally not secret, as confirmed via [aws docs](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-identifiers.html?utm_source=copilot.com), although mentions thar aacounts ids should be used and shared carefully,

### How to make Gitleaks flag AWS account IDs

The file `.gitleaks.toml` file has been added to flag any 12-digit number

- run `gitleaks detect --no-git` to provide feedback or
- append with -v as per `gitleaks detect --no-git -v` for more verbose information

## Git pre-commit hooks

- My pre-commit config is located on the root directory and is named `.pre-commit-config.yaml`

### One ordering consideration worth deciding now

`terraform_validate` needs a working directory with providers initialized (it effectively runs `terraform validate`, which needs `.terraform/`) — if you ever clone this repo fresh on another machine, the hook can fail with "provider not initialized" rather than a real validation error. Not a problem today since I'm working in a live already - `init`'d directory, but worth remembering if you ever hit a confusing failure after a fresh clone: run `terraform init` before the first `pre-commit run` in a new checkout, not something the hook does for you.

### Testing pre-commmit hook locally

- Assuming installed
- Running `pre-commit run --all-files` is what is required
- If `git add .` isn't performed...

**re-commit only operates on files that git already knows about** — it builds its file list from `git ls-files`, not from a raw directory scan. Even `--all-files` means "all files git is tracking," not "all files that exist on disk."  I need to run `git add ,` presently, none of my `.tf` files are tracked, so every Terraform-aware hook would correctly find nothing to check.

### Results of running pre-commit

```bash
pre-commit run --all-files
Terraform fmt............................................................Passed
Terraform validate.......................................................Passed
Terraform validate with tflint...........................................Passed
Checkov..................................................................Passed
Detect hardcoded secrets.................................................Passed
```

## The Lambda code_sha256 mystery

- When performing a `terraform plan`, the Lambda `code_sha256` shows a change, which implies the lamba code has been changed
- To verify if a diff has occurred on the lambda code, perform:
```bash
curl -s "$(aws --region us-west-2 lambda get-function --function-name DemoCnnectLambda --query 'Code.Location' --output text)" -o deployed_lambda.zip
unzip -p deployed_lambda.zip lambda_function.py > deployed_lambda_function.py
diff deployed_lambda_function.py lambda_src/lambda_function.py
```

The diff came back with **no output**, so the Python source is genuinely identical

`archive_file` rebuilds the zip fresh on every `plan/apply`, and the zip container format bakes in file metadata (notably modification timestamps) that can differ between builds even with byte-identical source — e.g. if `lambda_function.py`'s mtime changed from a git checkout, an editor re-save, or similar, without its content changing at all. That would make this expected noise, not drift

## Targetted terraform plan and apply on connect instance

```bash
terraform plan -target=aws_connect_instance.this -out=tfplan
terraform apply tfplan
```

Here, `-out=tfplan` serializes the exact scoped plan to a file, and `apply tfplan` **applies precisely that file** — no re-planning, no risk of drift between the two steps (e.g. someone else changing infrastructure in the gap between your review and your apply). This is genuinely the more production-appropriate pattern generally, and worth adopting as your default now that you know it exists — it's strictly safer than either of the two-step sequences you proposed, and safer even than the single `apply -target`, since it removes the tiny window where a second implicit plan could differ from what you actually reviewed.

### What Atlantis actually does

Atlantis doesn't invent new Terraform behavior — it's an orchestration layer that **wraps the exact** `plan -out=tfplan` → `apply tfplan` **sequence just adopted above**, triggered by PR comments (`atlantis plan`, `atlantis apply`) instead of you typing commands locally. 
When someone comments `atlantis plan`, it runs `terraform plan -out=tfplan` on its server, posts the output as a PR comment for review, and **stores that exact plan file** tied to that PR/commit. When someone then comments `atlantis apply`, it runs `terraform apply` against **that saved file** — not a fresh plan — which is precisely the guarantee `-out=tfplan` gives you locally: what got reviewed is what gets applied, no drift in between.

Atlantis's whole value proposition is this exact plan-file discipline, just automated and tied to git/PR review instead of your terminal. You'd essentially be hand-running what Atlantis does for a team.

### Multiple targetted plans

```bash
terraform plan \
  -target=aws_connect_hours_of_operation.nine_to_five_nz \
  -target=aws_connect_queue.gerrys_queue \
  -target=aws_connect_queue.priority_queue \
  -out=tfplan
```

Multiple `-target` flags are **additive** — this scopes the plan to exactly these three resources, as I presently want to exclude the Lambda entirely from consideration.

## Generating terraform for the aws connect flows

The following steps are required

1. Export flow with python script `export_flow.py` to produce an outputted json file
1. Template the arns of the json and save as a template `.tftpl` extension file
1. Create resources as noted via file `demo_flow.tf`
1. Create your import
  1. The `to` parameter will take the `instance_id:flow_id` compound format
1. Perform `terraform plan`
  1. You shoud get
  ```hcl
  Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.
  ```
1. If you get `1 to import, 1 to change`, the diff went well as change reflects `tags`
