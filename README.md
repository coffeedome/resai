# Requirements:

1. Trace calls to Amazon Bedrock.
2. Forward calls to Presidio for PII checks and negate prompts.
3. Save prompts that are historically valid and cache the responses to preven double calls.
4. Use Bedrock Guardrails features.
5. Estimate average cost of call using Orb or average cost of call based on Bedrock pricing and number of tokens.

# Steps:

1. Start up a proxy to forward calls to Bedrock.
2. Redirect api call to Presidio first for Analysis and Redaction/Anonymization.
3. From Presidio forward redacted call to Bedrock but include Tracer for Phoenix.
4. Get evaluations from another Bedrock model in async mode but after call is sent to Phoenix.

# Presidio

## Reference: https://microsoft.github.io/presidio/samples/docker/

### Analyzer call:

curl -X POST http://localhost:5002/analyze -H "Content-type: application/json" --data "{ \"text\": \"John Smith drivers license is AC432223\", \"language\" : \"en\"}"

### Anonymizer call:

curl -X POST http://localhost:5001/anonymize -H "Content-type: application/json" --data "{\"text\": \"hello world, my name is Jane Doe. My number is: 034453334\", \"analyzer_results\": [{\"start\": 24, \"end\": 32, \"score\": 0.8, \"entity_type\": \"NAME\"}, { \"start\": 48, \"end\": 57, \"score\": 0.95,\"entity_type\": \"PHONE_NUMBER\" }], \"anonymizers\": {\"DEFAULT\": { \"type\": \"replace\", \"new_value\": \"ANONYMIZED\" },\"PHONE_NUMBER\": { \"type\": \"mask\", \"masking_char\": \"\*\", \"chars_to_mask\": 4, \"from_end\": true }}}"

# Arize

Reference: https://docs.arize.com/phoenix/deployment/docker
