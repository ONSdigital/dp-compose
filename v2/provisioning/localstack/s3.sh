#!/bin/bash
set -x
awslocal s3 mb s3://deprecated
awslocal s3 mb s3://testing
awslocal s3 mb s3://testing-public
awslocal s3 mb s3://dp-frontend-florence-file-uploads
awslocal s3api put-object --bucket testing --key index.html --body /root/index.html
set +x
