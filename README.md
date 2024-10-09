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

# Steps:

1. Deploy terraform

```
cd terraform
terraform init
terraform apply
```

2. Grab the api_url terraform output. For example:

```
api_url = "https://jr4ql74nok.execute-api.us-west-2.amazonaws.com/prod"
```

Now call the resumes endpoint with GET:
https://jr4ql74nok.execute-api.us-west-2.amazonaws.com/prod/resumes

curl -X OPTIONS "https://vuf0b77cp2.execute-api.us-west-2.amazonaws.com/prod/resumes" \
-H "Origin: http://localhost:3000" \
-H "Access-Control-Request-Method: POST" \
-H "Access-Control-Request-Headers: Content-Type, Authorization"

1. Upload a resume or set of resumes to S3

```
https://jr4ql74nok.execute-api.us-west-2.amazonaws.com
```

Errors List:
(142e1846-c13e-4829-825f-d9750f52869a) Execution failed due to configuration error: Invalid permissions on Lambda function
The API with ID d3mcwv9k17 doesn’t include a resource with path /resumes having an integration arn:aws:lambda:us-west-2:767398066659:function:resumes-api on the ANY method.

(5717985c-437f-4fee-bfd9-f7a4211c8e87) Lambda execution failed with status 200 due to customer function error: Expecting value: line 1 column 1 (char 0). Lambda request id: 72e00b91-4e96-4ef9-a66f-d9a7bc34acaf

uploading files to s3 via apigw:
https://repost.aws/knowledge-center/api-gateway-upload-image-s3
