#!/bin/bash
set -x
awslocal s3 mb s3://deprecated
awslocal s3 mb s3://testing-public
awslocal s3 mb s3://dp-frontend-florence-file-uploads
awslocal s3 mb s3://uploaded
awslocal s3 mb s3://testing
awslocal s3 mb s3://ingest-datasets
awslocal s3api put-object --bucket testing --key index.html --body /root/index.html

# dataset-exporter dataset-exporter-xlsx
awslocal s3 mb s3://csv-exported

# dp-image-importer
awslocal s3 mb s3://private
awslocal s3 mb s3://public

set +x
