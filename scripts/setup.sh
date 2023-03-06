usage="$(basename "$0") [-h] [-r <aws-region>] [-p <aws-profile>] [-g <git-repo>] [-b <git-branch>]

Flags:
    -h  show this help text
    -r  set the AWS region
    -p  set the AWS profile
    -g  set alternate GitHub repository (default: mlhynfield/pan-for-gold-iac)
    -b  set specific authorized GitHub branch (default: * [all branches])"

export GIT_REPO="mlhynfield/pan-for-gold-iac"
export GIT_BRANCH="*"
while getopts ":hr:p:g:b:" opt; do
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
        g) # set alternative GitHub repository
        export GIT_REPO=$OPTARG
        ;;
        b) # set specific authorized GitHub repository branch
        export GIT_BRANCH=$OPTARG
        ;;
   esac
done

# Disable pager for aws commands
export AWS_PAGER=''

# Check if user is signed into aws cli and retrieve account ID
set -e
export ACCOUNT_ID="`aws sts get-caller-identity --output text --query Account`"
set +e

# Create OIDC provider
aws iam create-open-id-connect-provider \
--url https://token.actions.githubusercontent.com \
--thumbprint-list "6938FD4D98BAB03FAADB97B34396831E3780AEA1" \
--client-id-list "sts.amazonaws.com"

# Configure IAM role trust policy with variable values
trust_policy=`cat policies/trust-policy.json \
| sed "s#ACCOUNT_ID#$ACCOUNT_ID#; s#GIT_REPO#$GIT_REPO#; s#GIT_BRANCH#$GIT_BRANCH#"`

# Configure IAM role policy with variable values
role_policy=`cat policies/role-policy.json \
| sed "s#ACCOUNT_ID#$ACCOUNT_ID#"`

# Create and tag IAM role for GitHub Actions with trust policy
aws iam create-role \
--role-name GitHubActions-Pan-For-Gold \
--assume-role-policy-document "$trust_policy" \
--tags "Key=app,Value=pan-for-gold"

# Create and tag IAM role policy and retrieve ARN
policy_arn=$(\
aws iam create-policy \
--policy-name GitHubActions-Pan-For-Gold \
--policy-document "$role_policy" \
--tags "Key=app,Value=pan-for-gold" \
--output text \
--query Policy.Arn\
)

# Attach IAM role policy to role
aws iam attach-role-policy \
--role-name GitHubActions-Pan-For-Gold \
--policy-arn "$policy_arn"

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