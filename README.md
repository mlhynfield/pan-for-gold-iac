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
  - [Build and Deploy](#build-and-deploy)
    - [SSH node access](#ssh-node-access)
    - [`kubectl` cluster access](#kubectl-cluster-access)
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

- Clone this repository or a fork

  ```bash
  git clone https://github.com/mlhynfield/pan-for-gold-iac.git
  ```

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Log into AWS CLI with `aws configure` or `aws sso login`

#### Quickstart

- Execute `setup.sh`

  ```bash
  ./setup.sh
  ```

#### Quick teardown

- Execute `destroy.sh`

  ```bash
  ./destroy.sh
  ```

#### Granular setup & destroy

- Choose which scripts to execute
  - `granular_setup`
    - `setup-oidc.sh`: Enables GitHub OpenID Connect provider
    - `setup-iam.sh`: Creates IAM role and policy for GitHub OIDC
    - `setup-backend.sh`: Creates S3 bucket and DynamoDB table for Terraform backend
  - `granular_destroy`
    - `destroy-oidc.sh`: Removes GitHub OIDC
    - `destroy-iam.sh`: Destroys GitHub OIDC IAM role and policy
    - `destroy-backend.sh`: Destroys S3 bucket and DynamoDB table
- Execute desired script(s)
  - Setup Example:
  
    ```bash
    granular_setup/setup-backend.sh
    ```

  - Teardown Example:

    ```bash
    granular_destroy/destroy-backend.sh
    ```

### Build and deploy

- Execute the Terraform Apply GitHub Actions workflow by either
  - Pushing a commit modifying any `.tf` Terraform file to `master` branch
  - Running the workflow from the **Actions** tab in GitHub by choosing **Run workflow**
- Retrieve the public EC2 instance IP and copy to clipboard

  ```bash
  aws ec2 describe-instances --output text --no-cli-pager \
  --query 'Reservations[].Instances[?Tags[?Value == `pan-for-gold`]].NetworkInterfaces[0].Association.PublicIp'
  ```

- Navigate to the copied IP address in your browser

### Cluster Access

#### Initial configuration

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Log into AWS CLI with `aws configure` or `aws sso login`
- Execute `sg_rules.sh` and retrieve EC2 public IP

  ```bash
  ./sg_rules.sh

  export INSTANCE_IP=$(\
  aws ec2 describe-instances --output text --no-cli-pager \
  --query 'Reservations[].Instances[?Tags[?Value == `pan-for-gold`]].NetworkInterfaces[0].Association.PublicIp'\
  )
  ```

#### SSH node access

- SSH into instance

  ```bash
  ssh ec2-user@$INSTANCE_IP
  ```

#### `kubectl` cluster access

- Use `scp` to copy remote kubeconfig to local directory

  ```bash
  scp ec2-user@$INSTANCE_IP:/etc/rancher/k3s/k3s.yaml $HOME/.kube/pan-for-gold
  ```

- Execute `modify_kubeconfig.sh`

  ```bash
  kubeconfig/modify_kubeconfig
  ```

- Then either
  - Set the downloaded file as the kubeconfig for your current shell

    ```bash
    export KUBECONFIG=$HOME/.kube/pan-for-gold
    ```

  - Or execute `merge_kubeconfig.sh` to merge into existing kubeconfig file

    ```bash
    kubeconfig/merge_kubeconfig
    ```

- Validate connectivity

  ```bash
  kubectl get nodes
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
- Automated deployment
  - K3s cluster and ArgoCD installed from EC2 user data
  - Panning for Gold app deployed with ArgoCD

## Architecture

- AWS EC2 instance on Virtual Private Cloud
  - 3 public subnets
  - 1 security group
  - 1 EC2 instance with public IP
  - 1 SSH key pair for direct node access
- K3s on EC2
  - K3s cluster configured and installed at EC2 startup
  - ArgoCD core installation installed and configured
  - ArgoCD GitOps deployment synced to [Panning for Gold repository][2]
  - Application served over EC2 public IP via Traefik ingress

[1]: https://en.wikipedia.org/wiki/Golden_ratio
[2]: https://github.com/mlhynfield/pan-for-gold
[3]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[4]: https://docs.github.com/en/actions/security-guides/encrypted-secrets
[5]: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
