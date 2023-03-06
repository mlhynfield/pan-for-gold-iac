usage="./$(basename "$0") [-h] [-r <aws-region>] [-p <aws-profile>]

flags:
    -h  show this help text
    -r  set the AWS region
    -p  set the AWS profile"

while getopts ":hr:p:" opt; do
    case $opt in
        h) # display help text with -h
        echo "\n$usage"
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

aws dynamodb delete-table --table-name GitHubActions-Pan-For-Gold-Terraform-Lock

aws s3 rm s3://pan-for-gold-tf-backend-$ACCOUNT_ID --recursive
aws s3api delete-bucket --bucket pan-for-gold-tf-backend-$ACCOUNT_ID

aws iam detach-role-policy \
--role-name GitHubActions-Pan-For-Gold \
--policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/GitHubActions-Pan-For-Gold"

aws iam delete-policy --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/GitHubActions-Pan-For-Gold"

aws iam delete-role --role-name GitHubActions-Pan-For-Gold

aws iam delete-open-id-connect-provider \
--open-id-connect-provider-arn "arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"