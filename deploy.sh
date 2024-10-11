#!/bin/bash

echo "Building and deploying lambda"


cd lambdas/resumes_api || exit
if [ ! -d ".env" ];then
    python3 -m venv .env
fi
source .env/bin/activate 
pip install -r requirements.txt

cd ..

zip -qr resumes_api.zip resumes_api

cd resumes_api/.env/lib/python3.12/site-packages || exit

zip -qr ../../../../../resumes_api.zip .

cd ../../../../../

cp resumes_api.zip ../terraform/
cd ../terraform || exit
terraform init
terraform apply -auto-approve