# Automating the deployment of Infrastructure

The is an example for deploying GCE ( Google Compute Engine ) instance on GCP using Github Actions.

- GCE instance is deployed using Github Actions
- Remote state handling using GCS (Google Cloud Storage) bucket

## Main Components

![alt text](assets/IaC_automation.png)

1. Terraform: IaC for creating cloud resources
2. GCP: Cloud provider
3. Github Actions: automated CI/CD pipeline for deploying applications and infrastructure

The workflow is triggered on push events to the `main` branch, pull requests, or manual workflow dispatches.

## Project Structure

The project structure should be like this:

```bash
IaC_automation
└── .github/workflows
    └── boostrap.yaml       # defines the workflow for creating remote backend bucket ( this is triggered manually )
    └── terraform.yaml      # defines the automated workflow, edit this file for your own use-case
└── environments
    └── dev
        ├── boostrap            # defines the main configuration for creating GCE instance
            ├── main.tf         # defines the main configuration for creating remote backend bucket
            ├── terraform.tfvars    # defines the arguments to be used for the variables
            ├── variables.tf        # defines input variables used in Terraform configuration 
            ├── versions.tf         # defines the required Terraform version
        ├── main.tf         # defines the main configuration for creating GCE instance
        ├── networking.tf   # defines the newtworking related things: VPC, Subnets, Firewalls, etc
        ├── outputs.tf      # defines the outputs to be shared from Terraform remote state
        ├── providers.tf    # defines the GCP as the provider
        ├── storage.tf      # defines cloud-buckets to be used: general cloud buckets
        ├── variables.tf    # defines input variables used in Terraform configuration
        └── versions.tf     # defines the required Terraform version
└── scripts
    └── create_gcp_service_account.sh # create a new GCP service account locally to be used by Terraform with Github-Actions
└── env.sample                        # sample ENV variables to be used
```

## Workflow

This workflow contains several jobs and steps to enforce code quality and deployment of the infrastructure.

1. **Checkout**: Retrieves the repository’s contents to the runner.

2. **Setup Terraform**: Configures the runner with a specific version of Terraform (1.4.2 in this case).

3. **Terraform Format**: Ensures your Terraform code adheres to the expected format and style.

4. **Terraform Init**: Initializes your Terraform working directory, setting up remote backend storage and downloading required provider plugins.

5. **Terraform Validate**: Validates the Terraform configuration for syntax and internal consistency.

6. **Terraform Plan**: Generates an execution plan detailing the changes that will be made to your infrastructure. This step is only executed on pull requests.

7. **Update Pull Request**: Adds a comment to the pull request with the outcomes of the format, initialization, validation, and plan steps, along with the detailed execution plan. This step is only executed on pull requests.

8. **Terraform Plan Status**: Exits the workflow with an error if the plan step fails.

9. **Terraform Apply**: Applies the Terraform plan to create, update, or delete infrastructure resources. This step is executed only when pushing to the main branch or triggering a manual workflow dispatch.

## How to run

1. Setup the environment

    1. GCP account: [Check](https://cloud.google.com/?hl=en)
    2. Active GCP account with billling enabled
    3. Install [Terraform](https://developer.hashicorp.com/terraform)
    4. Install Google Cloud SDK: [Check](https://cloud.google.com/sdk?hl=en)
    5. Github Repository

    ```bash
    # Check Google Cloud SDK
    gcloud --version
    gcloud init 
    gcloud auth login # login using your default account

    # Verify Terraform
    terraform --version

    # Check your active project
    gcloud config get-value project
    ```

2. Create a GCP service account

    1. Update the `.env` file
    2. Run the below commandss

    ```bash
    cd scripts/
    cp .env.sample .env
    # remove existing ENV variables
    sed -i '/^project_id=/d' .env
    # Append new value for ENV variables
    echo "project_id=<your_project_id>" >> .env

    # Create a service-account for automation
    bash create_gcp_service_account.sh
    ```

    - This creates a service account to be used during CI/CD pipeline (Github Action): `scripts/terraform-sa-key.json`

3. Create the basic projcet structure like `Iac_automation` or copy the files to your github repository

    1. Create a github repository and add or copy the project structure
    2. Update the `project_id`in both `environments/dev/boostrap/terraform.tfvars` and `environments/dev/terraform.tfvars`

4. Set the `ENV` variables in Github to trigger the workflow:
    - This can be found in `https://github.com/<your_github_username>/<your_repo_name>/settings/secrets/actions`
        - `TF_VAR_GCP_CREDENTIALS`: GCP service account JSON key
        - `STATE_BUCKET`: GCS bucket name for remote-backend of terraform, this is the `bucket_name` you have set in `environments/dev/boostrap/terraform.tfvars` 
        - `GITHUB_TOKEN`: Your Github account's access token

5. Manually trigger the **boostrap-workflow** to create the GCS bucket for the remote backend
    - This has to be created manually as terraform itself can not hanlde this during the automation
    - To trigger this, go to the Github and trigger Github Actions tab button

6. Trigger the automated workflow by performing following actions

    1. Make some changes in the repository: 
        - add, change or remove cloud resources from terraform files

    2. Create a pull request to the `main` branch:
        - this triggers the github actions workflow to run on your pull request

    3. Monitor the deployment process:
        - Watch the "Actions" tab of the Github

    4. Review the pull request:
        - this will summarize the outcomes of the workflow and provides the detailed execution plan
        - review this plan

    5. Merge the pull request:
        - if everything is okay, merge the pull request to trigger the workflow agian
        - at this moment, **Terraform Apply** step is executed to deploy the infrastructure changes

    6. Verify the deployment on GCP:
        - Login to your GCP account and see the console for specific resources.