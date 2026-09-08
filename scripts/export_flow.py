# scripts/export_flow.py
import boto3
import json
import sys


def export_flow(instance_id: str, flow_id: str, out_path: str, region: str = "us-west-2") -> None:
    client = boto3.client("connect", region_name=region)
    resp = client.describe_contact_flow(InstanceId=instance_id, ContactFlowId=flow_id)
    content = json.loads(resp["ContactFlow"]["Content"])

    lint_errors = lint_flow(content)
    if lint_errors:
        print(f"Lint found {len(lint_errors)} issue(s):", file=sys.stderr)
        for err in lint_errors:
            print(f"  - {err}", file=sys.stderr)
    else:
        print("Lint: no issues found.")

    with open(out_path, "w") as f:
        json.dump(content, f, indent=2)
    print(f"Exported to {out_path}")


def lint_flow(content: dict) -> list[str]:
    """Basic structural checks: every branch target must reference a real block."""
    errors = []
    block_ids = {b["Identifier"] for b in content["Actions"]}

    for block in content["Actions"]:
        transitions = block.get("Transitions", {})

        # Named conditions (e.g. Success/Error/In Hours/Out of Hours)
        for cond in transitions.get("Conditions", []):
            target = cond.get("NextAction")
            if target and target not in block_ids:
                errors.append(
                    f"Block '{block['Identifier']}' condition targets unknown block '{target}'"
                )

        # Default/fallback transition
        default_target = transitions.get("NextAction")
        if default_target and default_target not in block_ids:
            errors.append(
                f"Block '{block['Identifier']}' default transition targets unknown block '{default_target}'"
            )

        # Errors branch
        for err_cond in transitions.get("Errors", []):
            target = err_cond.get("NextAction")
            if target and target not in block_ids:
                errors.append(
                    f"Block '{block['Identifier']}' error transition targets unknown block '{target}'"
                )

    return errors


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python export_flow.py INSTANCE_ID FLOW_ID OUTPUT_PATH", file=sys.stderr)
        sys.exit(1)
    export_flow(sys.argv[1], sys.argv[2], sys.argv[3])
