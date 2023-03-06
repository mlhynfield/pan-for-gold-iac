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
- [Features](#features)
- [Architecture](#architecture)

## Assumptions

- Existing AWS account
- Administrator access to AWS account
- [AWS CLI][3] installed
- Admin access to this GitHub repository or a fork

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

- Execute `setup.sh`
  - Log into AWS CLI with `aws configure` or `aws sso login`

  ```bash
  ./setup.sh
  ```

#### Quick teardown

- Change directory to `scripts`

  ```bash
  cd scripts
  ```

- Execute `destroy.sh`
  - Log into AWS CLI with `aws configure` or `aws sso login`

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
- Execute desired script(s)
  - Log into AWS CLI with `aws configure` or `aws sso login`

  - Setup Example:
  
    ```bash
    granular_setup/setup-backend.sh
    ```

  - Teardown Example:

    ```bash
    granular_destroy/destroy-backend.sh
    ```

## Features

TODO

## Architecture

TODO

[1]: https://en.wikipedia.org/wiki/Golden_ratio
[2]: https://github.com/mlhynfield/pan-for-gold
[3]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
