usage="$(basename "$0") [-h] [-r <aws-region>] [-p <aws-profile>]

Flags:
    -h  show this help text
    -r  set the AWS region
    -p  set the AWS profile"

while getopts ":hr:p:" opt; do
    case $opt in
        h) # display help text with -h
        echo "\nUsage:\n    $usage"
        exit
        ;;
        r) # set AWS region with -r
        export AWS_REGION=$OPTARG
        ;;
        p) # set AWS profile with -p
        export AWS_PROFILE=$OPTARG
        ;;
   esac
done

# Disable pager for aws commands
export AWS_PAGER=''

# Check if user is signed into aws cli and retrieve account ID
set -e
export ACCOUNT_ID="`aws sts get-caller-identity --output text --query Account`"
set +e

# Create and tag S3 bucket
aws s3api create-bucket --bucket pan-for-gold-tf-backend-$ACCOUNT_ID
aws s3api put-bucket-tagging \
--bucket pan-for-gold-tf-backend-$ACCOUNT_ID \
--acl private \
--tagging "TagSet=[{Key=app,Value=pan-for-gold}]"

# Create and tag DynamoDB table
aws dynamodb create-table \
--table-name GitHubActions-Pan-For-Gold-Terraform-Lock \
--attribute-definitions AttributeName=LockID,AttributeType=S \
--key-schema AttributeName=LockID,KeyType=HASH \
--billing-mode PAY_PER_REQUEST \
--tags "Key=app,Value=pan-for-gold"