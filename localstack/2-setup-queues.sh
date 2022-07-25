#!/bin/bash
set -euo

export AWS_ACCESS_KEY_ID=UNSET
export AWS_SECRET_ACCESS_KEY=UNSET
export AWS_DEFAULT_REGION=eu-west-2

## make sure that localstack is running in the pipeline
until curl http://localstack:4566/health --silent | grep -q "\"sqs\": \"available\""; do
   sleep 5
   echo "Waiting for LocalStack to be ready..."
done

## Audit
awslocal sqs create-queue --queue-name audit-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name audit-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\": \"arn:aws:sqs:eu-west-2:000000000000:audit-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Extract
awslocal sqs create-queue --queue-name extracts-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name extracts-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\": \"arn:aws:sqs:eu-west-2:000000000000:extracts-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Search
awslocal sqs create-queue --queue-name search-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name search-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:search-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Docs
awslocal sqs create-queue --queue-name document-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name document-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:document-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Case Creator
awslocal sqs create-queue --queue-name ukvi-complaint-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name ukvi-complaint-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:ukvi-complaint-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Notify
awslocal sqs create-queue --queue-name notify-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name notify-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:notify-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

## Migration
awslocal sqs create-queue --queue-name migration-queue-dlq --attributes '{"VisibilityTimeout": "3"}'
awslocal sqs create-queue --queue-name migration-queue --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:migration-queue-dlq\", \"maxReceiveCount\":1}", "VisibilityTimeout": "10"}'

awslocal sqs list-queues

## SNS Subscriptions
awslocal sns create-topic --name hocs-audit-topic
awslocal sns subscribe --topic-arn arn:aws:sns:eu-west-2:000000000000:hocs-audit-topic --attributes RawMessageDelivery=true --protocol sqs --notification-endpoint arn:aws:sns:eu-west-2:000000000000:audit-queue
awslocal sns subscribe --topic-arn arn:aws:sns:eu-west-2:000000000000:hocs-audit-topic --attributes RawMessageDelivery=true --protocol sqs --notification-endpoint arn:aws:sns:eu-west-2:000000000000:search-queue
awslocal sns set-subscription-attributes --subscription-arn $(aws --endpoint-url=http://localstack:4566 sns list-subscriptions-by-topic --topic-arn arn:aws:sns:eu-west-2:000000000000:hocs-audit-topic --output json | jq --raw-output '.Subscriptions[0].SubscriptionArn') --attribute-name RawMessageDelivery --attribute-value true
awslocal sns set-subscription-attributes --subscription-arn $(aws --endpoint-url=http://localstack:4566 sns list-subscriptions-by-topic --topic-arn arn:aws:sns:eu-west-2:000000000000:hocs-audit-topic --output json | jq --raw-output '.Subscriptions[1].SubscriptionArn') --attribute-name RawMessageDelivery --attribute-value true
awslocal sns list-subscriptions
