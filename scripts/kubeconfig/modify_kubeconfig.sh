# Disable pager for aws commands
export AWS_PAGER=''

# Check if user is signed into aws cli
set -e
aws sts get-caller-identity --output text --query Account > /dev/null
set +e

export INSTANCE_IP=$(\
aws ec2 describe-instances --output text \
--query 'Reservations[].Instances[?Tags[?Value == `pan-for-gold`]].NetworkInterfaces[0].Association.PublicIp'\
)

sed -ri "s/127.0.0.1/$INSTANCE_IP/g" ~/.kube/pan-for-gold

sed -ri "s/: default/: pan-for-gold/g" ~/.kube/pan-for-gold

sed -ri "s/namespace: pan-for-gold/namespace: default/g" ~/.kube/pan-for-gold
