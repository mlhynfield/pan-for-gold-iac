# Panning for Gold - Infrastructure as Code

> Mathematicians since Euclid have studied the properties of the golden ratio, including its appearance in the dimensions of a regular pentagon and in a golden rectangle, which may be cut into a square and a smaller rectangle with the same aspect ratio. The golden ratio has also been used to analyze the proportions of natural objects as well as man-made systems such as financial markets, in some cases based on dubious fits to data. The golden ratio appears in some patterns in nature, including the spiral arrangement of leaves and other plant parts.

– [Golden Ratio – Wikipedia][1]

This repository contains all IaC automation to deploy the [pan-for-gold][2] application.

- [Assumptions](#assumptions)
- [Usage](#usage)
  - [Initial Setup](#initial-setup)
    - [Quickstart](#quickstart)
    - [Quick Teardown](#quick-teardown)
    - [Granular Setup & Destroy](#granular-setup--destroy)
  - [SSH node access](#ssh-node-access)
- [Features](#features)
- [Architecture](#architecture)

## Assumptions

- Existing AWS account
- Administrator access to AWS account
- [AWS CLI][3] installed
- Admin access to this GitHub repository or a fork
- Existing SSH key pair with no passphrase
  - Create SSH key pair with no passphrase

    ```bash
    ssh-keygen -t ed25519
    ```

  - Ensure SSH key is accessible by ssh-agent
- AWS_ACCOUNT_ID and SSH_PUBLIC_KEY [GitHub repository secrets][4] created

## Usage

### Initial Setup

Clone this repository or a fork

```bash
git clone https://github.com/mlhynfield/pan-for-gold-iac.git
```

#### Quickstart

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Log into AWS CLI with `aws configure` or `aws sso login`
- Execute `setup.sh`

  ```bash
  ./setup.sh
  ```

#### Quick teardown

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Log into AWS CLI with `aws configure` or `aws sso login`
- Execute `destroy.sh`

  ```bash
  ./destroy.sh
  ```

#### Granular setup & destroy

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Choose which scripts to execute
  - `granular_setup`
    - `setup-oidc.sh`: Enables GitHub OpenID Connect provider
    - `setup-iam.sh`: Creates IAM role and policy for GitHub OIDC
    - `setup-backend.sh`: Creates S3 bucket and DynamoDB table for Terraform backend
  - `granular_destroy`
    - `destroy-oidc.sh`: Removes GitHub OIDC
    - `destroy-iam.sh`: Destroys GitHub OIDC IAM role and policy
    - `destroy-backend.sh`: Destroys S3 bucket and DynamoDB table
- Log into AWS CLI with `aws configure` or `aws sso login`
- Execute desired script(s)
  - Setup Example:
  
    ```bash
    granular_setup/setup-backend.sh
    ```

  - Teardown Example:

    ```bash
    granular_destroy/destroy-backend.sh
    ```

### SSH node access

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Log into AWS CLI with `aws configure` or `aws sso login`
- Execute `sg_rules.sh`, retrieve EC2 public IP and SSH into instance

  ```bash
  ./sg_rules.sh

  export INSTANCE_IP=$(\
  aws ec2 describe-instances --output text --no-cli-pager \
  --query 'Reservations[].Instances[?Tags[?Value == `pan-for-gold`]].NetworkInterfaces[0].Association.PublicIp'\
  )

  ssh ec2-user@$INSTANCE_IP
  ```

## Features

### Setup and destroy scripts

- Automated setup and destroy of:
  - [GitHub OIDC][5] provider in target AWS account
  - Related IAM resources
  - Terraform S3 backend with DynamoDB Terraform lock

### GitHub Actions

- Automated Terraform format check and plan
  - Runs with every pull request to `master` branch
  - Only runs when `.tf` files are created or modified
  - Enforces `terraform fmt` formatting
  - Runs `terraform plan` to validate Terraform configuration
- Automated Terraform apply
  - Runs with every push to `master` branch
  - Only runs when `.tf` files are created or modified
  - Runs `terraform apply` to attempt infrastructure build in target AWS account

## Architecture

TODO

[1]: https://en.wikipedia.org/wiki/Golden_ratio
[2]: https://github.com/mlhynfield/pan-for-gold
[3]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[4]: https://docs.github.com/en/actions/security-guides/encrypted-secrets
[5]: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
