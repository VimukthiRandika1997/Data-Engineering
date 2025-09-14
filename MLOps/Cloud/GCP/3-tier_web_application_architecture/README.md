# 3 Tier Web Application Infrastructure with GCP

## 👀 What is called 3-tier web application architecture ?

This separates an application into 3 logical layers:

1. Presentation Tier: 

    - Role: This is the user-interface that users interact with directly
    - Functionality: It displays the data and handles user input through web pages, forms, widgets
    - Technologies: HTML, CSS, React, Angular

2. Logic Tier (Application Tier):

    - Role: This is the core of the application known as backend
    - Functionality: It processes user requests, implements business logics, performs data manipulation and coordinates communication between presentation and data tiers
    - Technologies: Python, Go, Node.js, C#, etc

3. Data Tier:

    - Role: This is for storing and managing the application state
    - Functionality: It stores data, handles data retrieval, and interacts with logic tier
    - Technologies: Databases like MySQL, PostgreSQL or MongoDB, Cloud based ones (Cloud SQL, AWS DynamoDB, etc)

## 🤔 Why do we need 3-tiers ?

This solves lot of problems:

- It makes the system modular
- Each tier can scale independently without affecting the other ones:

    - If user-interface changes, the backend can stay the same
    - If database grows, the frontend doesn't have to care

## ✨ Overview

This is a complete 3-tier web-application infrastructure implemented using Infrastructure as Code in which contains:

- **Load Balancer**: *Presentation Tier*
- **Compute Engine Instance**: *Logic Tier*
- **Cloud SQL Database**: *Data Tier*

This project implementes scalable, secure architecture demonstrating enterprise-grade DevOps practices and Infrastructure as Code principles.

```bash
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Presentation   │    │      Logic      │    │     Data        │
│     Tier        │    │      Tier       │    │     Tier        │
│                 │    │                 │    │                 │
│ Load Balancer   │───▶│ Compute Engine  │───▶│   Cloud SQL     │
│ (Global HTTP)   │    │   Instances     │    │    (MySQL)      │
│                 │    │ (Auto-scaling)  │    │   (Private)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```bash
3-tier_web_application_architecture/
├── main.tf                     # Root configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── terraform.tfvars            # Variable values
├── modules/
│   ├── network/                # VPC, subnets, firewall rules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                # Instances, load balancer, auto-scaling
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/               # Cloud SQL configuration
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
│   └── startup-script.sh       # Instance initialization script
└── README.md
```

## Features

- Modular Architecture:  separate modules for network, compute and database
- Security: Private databasae, firewall rules
- Scalability: Auto-scaling, load-balancing, health-checks

## How to run

Under 🚧 ...

Here are the steps to deploy the infrastructure:

update the ENVs in `terraform.tfvars`

```bash
# initialize terraform
terraform init
# validate terraform
terraform validate
# format the code-base
terraform fmt -recursive
# play the deployment
terraform plan 
# apply configurations
terraform apply
```

Verify the deployment:

```bash
# verify deployment
terraform output
curl http://$(terraform output -raw load_balancer_ip)
```

Destroy the deployment:

```bash
terraform destroy

# verify the cleanup
gcloud compute instances list
gcloud sql instances list
```

