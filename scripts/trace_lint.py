# scripts/trace_lint.py
import json
import sys
from export_flow import lint_flow  # reuse the function you already have


def trace_lint(filename: str) -> None:
    """Load a flow JSON file and run lint checks on it."""
    with open(filename) as f:
        content = json.load(f)

    block_ids = {b["Identifier"] for b in content["Actions"]}
    print(f"Found {len(block_ids)} blocks:")
    for bid in block_ids:
        print(f"  - {bid}")

    print("\nRunning lint...")
    errors = lint_flow(content)

    if errors:
        print(f"\n{len(errors)} issue(s) found:")
        for e in errors:
            print(f"  - {e}")
    else:
        print("\nNo issues found.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python trace_lint.py <flow.json>", file=sys.stderr)
        sys.exit(1)
    trace_lint(sys.argv[1])
