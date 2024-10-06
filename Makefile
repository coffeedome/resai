SHELL := /bin/bash

.PHONY: build_resumes_api all

build_resumes_api:
	# Group commands together so `cd` works across all of them
	cd lambdas/resumes_api && \
	pip install -r requirements.txt && \
	cd .. && \
	zip -qr resumes_api.zip resumes_api && \
	cd resumes_api/.env/lib/python3.12/site-packages && \
	zip -qr ../../../../../resumes_api.zip . && \
	cd ../../../../../ && \
	cp resumes_api.zip ../api/