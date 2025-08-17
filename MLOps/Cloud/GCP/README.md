# Basic Terraform Project Structure For Google Cloud


## Setting up the Environment

1. GCP account: [Check](https://cloud.google.com/?hl=en)
2. Active GCP account with billling enabled
3. Install [Terraform](https://developer.hashicorp.com/terraform)
4. Install Google Cloud SDK: [Check](https://cloud.google.com/sdk?hl=en)

### Verify Installation:

```bash
# Check Google Cloud SDK
gcloud --version
gcloud init 

# Verify Terraform
terraform --version

# Check your active project
gcloud config get-value project
```

### Google Cloud Authentication Setup

1. Create a Service Account:

```bash
cp .env.sample .env
# remove existing ENV variables
sed -i '/^TF_VAR_project_id=/d' .env
sed -i '/^TF_VAR_region=/d' .env
sed -i '/^TF_VAR_zone=/d' .env

# Append new value for ENV variables
echo "TF_VAR_project_id=<your_project_id>" >> .env
echo "TF_VAR_region=<your_project_region>" >> .env
echo "TF_VAR_zone=<your_project_zone>" >> .env

# Create a service-account for automation
bash create_gcp_service_account.sh

# Verify authentication
gcloud auth application-default print-access-token
```

## Project Structure

Let's create a clean, maintainable project structure by adding these files

```bash
mkdir terraform-gcp && cd terraform-gcp

# Create core Terraform files: for basic workflow
touch main.tf variables.tf outputs.tf providers.tf terraform.tfvars

# Create resource-specific files: for resource creation
touch networking.tf storage.tf

# Create backend configuration: for terraform state management
touch backend.tf

# Initialize git for version control
git init
echo "*.tfvars" >> .gitignore
echo "terraform-sa-key.json" >> .gitignore
echo ".terraform/" >> .gitignore
echo "*.tfstate*" >> .gitignore
```

## How to run

```bash
cd terraform-gcp/
# For creating cloud resources
bash deploy_infra.sh create
# For destroying cloud resources
bash deploy_infra.sh destroy
```

## Note

### Terraform State Management

Terraform state is the crucial component that tracks your infrastructure:

- 📊 Resource Metadata: Current state, IDs, and configurations
- 🔗 Dependencies: Relationships and creation order between resources
- 📝 Performance: Caches resource attributes for faster operations
- 🎯 Drift Detection: Identifies manual changes made outside Terraform

#### State Storage Options

Local State (Development):

- Stored on your local machine
- Simple for learning and testing
- Not suitable for team collaboration

Remote State (Production):

- Google Cloud Storage (recommended for GCP)
- Terraform Cloud (HashiCorp’s managed solution)
- Amazon S3 (for multi-cloud scenarios)

Usually state is managed using a cloud-storage bucket!

## Production-Ready Best Practices

### 🔧 Code Organization & Standards

- Modularize configurations for reusability across environments
- Use consistent naming conventions with environment prefixes
- Implement proper file structure with clear separation of concerns
- Version pin providers and modules to avoid breaking changes

### 🔒 Security & Access Management

- Never commit sensitive data or credentials to version control
- Use remote state backend with proper access controls and encryption
- Implement state locking to prevent concurrent modifications
- Follow least privilege principle for service account permissions