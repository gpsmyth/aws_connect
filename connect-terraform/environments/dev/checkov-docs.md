# Checkov warnings
- Use `checkov -d .` to identify warnings
- installation and setup of checov is mentioned elsewhere on my account

## Suppression of warnings

- Error suppressions are added just inside the resource
- Takes the format of

```hcl
resource "aws_lambda_function" "demo_connect_lambda" {
  #checkov:skip=CKV_AWS_117:No VPC required - this Lambda makes no calls to VPC-only resources (no RDS/ElastiCache), learning project
  #checkov:skip=CKV_AWS_116:No DLQ needed - invoked synchronously by Connect, not async/event-driven, so there's nothing to redrive
  #checkov:skip=CKV_AWS_272:Code signing is an enterprise control not applicable to a single-developer learning account
  ...
```

`CKV_AWS_117` and `CKV_AWS_272` — are genuinely not applicable here. `CKV_AWS_116` (DLQ) can be skipped also, given the same logic: DLQs matter for asynchronous invocations where a failed event needs somewhere to land for retry — my lambda is synchronous, invoked directly by Connect, so there's no queue of unprocessed events to lose.

## Incorporating CKV_AWS_173

`CKV_AWS_173` **(env var encryption) is worth actually fixing rather than skipping,** since it's nearly free: I don't have any environment variables today, but if I ever add one (e.g. a feature flag, a region string) it'd be unencrypted by default. Adding a KMS key costs nothing to configure now and removes the finding permanently rather than requiring a suppression comment you'd have to keep justifying:

```hcl
resource "aws_kms_key" "lambda_env" {
  description         = "Encrypts DemoCnnectLambda environment variables"
  enable_key_rotation = true
}
```

then `kms_key_arn = aws_kms_key.lambda_env.arn` on the function. (KMS has a small per-key monthly cost — ~$1/month — worth knowing given your cost-consciousness; if you'd rather skip this too for now since you have no env vars at all, that's a reasonable call too — just note it as "revisit if env vars are added" rather than skip it silently.)

**For repo-wide skips** (once you're confident a check will never apply to this project), a `.checkov.yaml` at the repo root is cleaner than repeating inline comments everywhere:

```yaml
skip-check:
  - CKV_AWS_117
```

- I have used inline for obvious suppressions and used `.checkov.yaml` to suppress because of costings