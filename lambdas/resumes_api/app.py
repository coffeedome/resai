import os
import base64
import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.logging import correlation_paths

logger = Logger(service="RESUME_API")

app = APIGatewayRestResolver()

s3_client = boto3.client("s3")

# Define your S3 bucket name
bucket_name = os.getenv("RESUMES_S3_BUCKET_NAME")


@app.post("/resumes/upload")
def upload_file():
    # Extract file data and filename from the request body
    body = app.current_event.json_body

    # Get the base64 encoded file content and the filename
    file_content = body.get("file_content")
    file_name = body.get("file_name")

    if not file_content or not file_name:
        return {"message": "file_content and file_name are required"}, 400

    try:
        # Decode the base64 file content
        file_data = base64.b64decode(file_content)

        # Upload the file to S3
        s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_data)

        return {"message": f"File {file_name} uploaded successfully"}

    except Exception as e:
        return {"message": f"File upload failed: {str(e)}"}, 500


@app.get("/resumes")
def get_resumes():
    # Sample query: GET /resumes?name=bobby.tables
    name = app.current_event.get_query_string_value(name="name", default_value=None)

    if name:
        return {"message": f"Looking for resumes for {name}"}
    else:
        return {"message": "No name provided in query string"}


@app.get("/resumes")
def hello():
    logger.info("Request for all resumes received")
    return {"message": "get list of resumes here!"}


@logger.inject_lambda_context(
    correlation_id_path=correlation_paths.API_GATEWAY_REST, log_event=True
)
def lambda_handler(event, context):
    if bucket_name is None:
        raise ValueError("Env var RESUMES_S3_BUCKET_NAME cannot be empty")
    return app.resolve(event, context)
