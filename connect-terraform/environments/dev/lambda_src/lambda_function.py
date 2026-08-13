import json
import random

def lambda_handler(event, context):
    # First run: just log everything so you can see the real event shape
    print(json.dumps(event))

    contact_data = event['Details']['ContactData']
    channel = contact_data.get('Channel', 'UNKNOWN')
     # Randomly choose between standard and vip
    priority_lambda = random.choice(["standard", "vip"])

    # Simple self-contained logic - no external API/DB calls, so $0 beyond
    # the Lambda invocation itself (which is inside the always-free tier)
    result = {
        "greeting": "Hello from Lambda",
        "channelSeen": channel,
        "priority": priority_lambda
    }

    return result  # must be a flat dict - see "Verify the function response" below
