openapi: 3.0.1
info:
  title: Resume and Analysis API
  description: API for uploading resumes, listing files, and managing analysis records.
  version: "1.0.0"

paths:
  /resumes:
    post:
      summary: Generate a presigned URL for uploading a file to S3
      operationId: generatePresignedUrl
      responses:
        "200":
          description: A presigned URL for S3 upload
          content:
            application/json:
              schema:
                type: object
                properties:
                  presigned_url:
                    type: string
                    description: Presigned URL for uploading a file to S3
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: POST
        uri: arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/arn:aws:lambda:{region}:{account_id}:function:{lambda_generate_presigned_url}/invocations
        credentials: arn:aws:iam::{account_id}:role/{execution_role}

    get:
      summary: Get the list of files and their metadata from the S3 bucket
      operationId: listFiles
      responses:
        "200":
          description: A list of files and their metadata
          content:
            application/json:
              schema:
                type: object
                properties:
                  files:
                    type: array
                    items:
                      type: object
                      properties:
                        file_name:
                          type: string
                          description: Name of the file
                        last_modified:
                          type: string
                          format: date-time
                          description: Last modified timestamp
                        size:
                          type: integer
                          description: Size of the file in bytes
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: GET
        uri: arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/arn:aws:lambda:{region}:{account_id}:function:{lambda_list_files}/invocations
        credentials: arn:aws:iam::{account_id}:role/{execution_role}

  /analysis:
    post:
      summary: Create an analysis record
      operationId: createAnalysis
      requestBody:
        description: Data for creating a new analysis
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                title:
                  type: string
                  description: Title of the analysis
                description:
                  type: string
                  description: Detailed description of the analysis
      responses:
        "201":
          description: Analysis record created
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                    description: Unique ID of the created analysis
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: POST
        uri: arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/arn:aws:lambda:{region}:{account_id}:function:{lambda_create_analysis}/invocations
        credentials: arn:aws:iam::{account_id}:role/{execution_role}

    get:
      summary: Get analysis records with optional filters
      operationId: getAnalysisRecords
      parameters:
        - name: id
          in: query
          required: false
          description: ID of the analysis
          schema:
            type: string
        - name: title
          in: query
          required: false
          description: Title of the analysis
          schema:
            type: string
        - name: age
          in: query
          required: false
          description: Age of the analysis record in hours
          schema:
            type: integer
      responses:
        "200":
          description: A list of analysis records
          content:
            application/json:
              schema:
                type: object
                properties:
                  analyses:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                          description: ID of the analysis
                        title:
                          type: string
                          description: Title of the analysis
                        description:
                          type: string
                          description: Detailed description of the analysis
                        created_at:
                          type: string
                          format: date-time
                          description: Timestamp when the analysis was created
                        age:
                          type: integer
                          description: Age of the analysis record in hours
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: GET
        uri: arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/arn:aws:lambda:{region}:{account_id}:function:{lambda_get_analysis}/invocations
        credentials: arn:aws:iam::{account_id}:role/{execution_role}

components:
  securitySchemes:
    api_key:
      type: apiKey
      name: x-api-key
      in: header

security:
  - api_key: []
