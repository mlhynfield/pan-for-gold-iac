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

# Create OIDC provider
aws iam create-open-id-connect-provider \
--url https://token.actions.githubusercontent.com \
--thumbprint-list "6938FD4D98BAB03FAADB97B34396831E3780AEA1" \
--client-id-list "sts.amazonaws.com"
