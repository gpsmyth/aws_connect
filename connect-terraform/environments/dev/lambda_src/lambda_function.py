import boto3
import json

bedrock = boto3.client('bedrock-runtime', region_name='us-west-2')


def lambda_handler(event, context):
    # First run: just log everything so you can see the real event shape
    print(json.dumps(event))

    contact_data = event['Details']['ContactData']
    channel = contact_data.get('Channel', 'UNKNOWN')

    priority_lambda = classify_priority(contact_data.get('CustomerMessage', ''))
    print(f"Priority classified as: {priority_lambda}")

    # TODO: replace hardcoded input once a "Store customer input" block
    # feeds real customer text into event['Details']['Parameters']
    result = {
        "greeting": "Hello from Lambda",
        "channelSeen": channel,
        "priority": priority_lambda
    }

    return result  # must be a flat dict - see "Verify the function response" below


def classify_priority(customer_message: str) -> str:
    response = bedrock.converse(
        modelId="us.amazon.nova-micro-v1:0",
        messages=[{
            "role": "user",
            "content": [{"text": (
                "Classify this customer request as 'standard' or 'vip' for Amazon Connect routing."
                f"Follow these rules exactly:"
                f"VIP if ANY of the following are true:"
                f" - The message expresses urgency (now, immediately, ASAP, urgent, critical, escalation)."
                f" - The issue affects multiple sites, multiple teams, or business operations."
                f" - The message indicates a major outage, service down, or critical failure."
                f" - The customer expresses frustration, escalation, or high stress."
                f" - The message mentions executives or high-impact stakeholders."

                f"STANDARD if ALL of the following are true:"
                f" - The issue is minor or localized."
                f" - The message does not express urgency."
                f" - The impact is limited."
                f" - The tone is neutral or routine."

                f"If the message does not clearly meet any VIP criteria, classify as 'standard'."

                f"Respond with one word only: 'vip' or 'standard'."
                f"Do not output synonyms."

                f"Customer message: {customer_message}"
            )}]
        }],
        inferenceConfig={"maxTokens": 5, "temperature": 0}
    )
    result = response["output"]["message"]["content"][0]["text"].strip().lower()
    return result if result in ("vip", "standard") else "standard"
