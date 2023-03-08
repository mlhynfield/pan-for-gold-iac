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

# Retrieve security group ID
security_group_id=$(\
aws ec2 describe-security-groups --output text \
--query 'SecurityGroups[?Tags[?Value == `pan-for-gold`]].GroupId'\
)

ip_address=$(curl -s https://checkip.amazonaws.com)

aws ec2 authorize-security-group-ingress \
--group-id "$security_group_id" \
--protocol tcp \
--port 22 \
--cidr "$ip_address/32"

aws ec2 authorize-security-group-ingress \
--group-id "$security_group_id" \
--protocol tcp \
--port 6443 \
--cidr "$ip_address/32"
