import os
import json
import base64
import boto3
from datetime import date
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.data_classes import (
    event_source,
    APIGatewayProxyEvent,
)
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.logging import correlation_paths

logger = Logger(service="RESUME_API")
tracer = Tracer()
app = APIGatewayRestResolver(enable_validation=True)

s3_client = boto3.client("s3")
bucket_name = os.getenv("RESUMES_S3_BUCKET_NAME")
if bucket_name is None:
    raise ValueError("Env var RESUMES_S3_BUCKET_NAME cannot be empty")


@app.post("/resumes/upload")
def upload_file():

    try:
        bucket_name = os.environ["RESUMES_S3_BUCKET_NAME"]
        logger.info(f"Event printout: {app.current_event}")
        body = app.current_event.json_body
        files = body.get("files", [])
        if not files:
            return format_response(400, "No file information provided")

        for file in files:
            file_name = file["name"]
            file_type = file["type"]
            key = f"resume_uploads_{date.today()}/{file_name}"

        presigned_url = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": bucket_name,
                "Key": key,
                "ContentType": file_type,
                "ACL": "public-read",
            },
            ExpiresIn=300,
        )

        return format_response(200, json.dumps({"presignedUrl": presigned_url}))

    except Exception as e:
        return format_response(500, json.dumps({"error": str(e)}))


@app.get("/resumes")
def get_resumes():
    try:
        # Sample query: GET /resumes?name=bobby.tables
        name = app.current_event.get_query_string_value(name="name", default_value=None)

        return format_response(
            200,
        )
    except Exception as e:
        return format_response(
            400,
        )


@app.get("/resumes")
def hello():
    logger.info("Request for all resumes received")
    return {"message": "get list of resumes here!"}


@tracer.capture_lambda_handler
@logger.inject_lambda_context(
    correlation_id_path=correlation_paths.API_GATEWAY_REST, log_event=True
)
@event_source(data_class=APIGatewayProxyEvent)
def lambda_handler(event: APIGatewayProxyEvent, context: LambdaContext):
    return app.resolve(event, context)


def format_response(status_code: int, res: dict):
    """format_response adds CORS headers and formats response in way that API Gateway
    AWS_PROXY integration can interpret

    Args:
        status_code (int): http status code. E.g. 2XX, 4XX, 5XX
        res (dict): response body

    Returns:
        _type_: _description_
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
            "Access-Control-Allow-Methods": "OPTIONS, POST, GET, PUT, DELETE",
        },
        "body": json.dumps(res),
    }
