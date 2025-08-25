# Secure Compute Engine Instance with VPC, Subnets, Cloud NAT and IAP

![alt text](/MLOps/Cloud/GCP/private_compute_instance/assets/private_VM_with_VPC.png)

Below is a production-ready Terraform setup that:

- Creates a custom VPC
- Adds two subnets (public + private)
- Sets up a Cloud Router + Cloud NAT (egress from private subnet without public IPs)
- Provisions a hardened Compute Engine VM without an external IP in the private subnet
- Uses OS Login, Shielded VM, minimal IAM for the VM’s service account
- Locks down firewall to just what’s needed (IAP-only SSH), with logging enabled


# Overview

Here is a breif analysis about the components being used.

- Custom VPC & Subnets: enforce network segementation
- Cloud NAT: provides outbound access when needed (updates & APIs)
- Firewall + IAP: controls exactly who/what gets in, *no open ports to the world*

## 1. Custom VPC

*👉 Think of the VPC as your company’s private data center in the cloud.*

- What it does:
    - Creates a Virtual Private Cloud (VPC), which is your own private network in GCP.
        By default, GCP gives you an auto mode VPC, but in production you use custom mode for fine-grained control.

- Why:
    - Segregates your workloads from GCP’s default network.
    - Lets you define regions, IP ranges, and subnets explicitly.
    - Provides isolation for environments (e.g., dev, stage, prod).

## 2. Public & Private Subnets

*👉 Think of subnets like separate office floors inside your building (VPC), each floor has its own rules.*

- What it does:
    - Defines subnets inside the VPC, typically:
    - Public subnets: Resources that need inbound internet access.
    - Private subnets: Resources that should never be exposed directly (e.g., GKE private nodes, databases).

- Why:
    - Increase the security by reducing the attack surface

## 3. Cloud NAT

*👉 NAT is like a reception desk: private employees (cloud resources) can make outbound calls, but outsiders can’t call them back directly.*

- What it does:
    - Configures a Cloud NAT (Network Address Translation) gateway.
    - This lets VMs or other cloud resources (GKE nodes) in private subnets reach the Internet without public IPs.

- Why:
    - Private cloud resources can still access the Internet: pull Docker images, apply security patches, or call external APIs.
    - No need to assign public IPs for every cloud resources which are meant to be hidden (reduce the attack surface).
    - Outbound traffic goes through a single controlled gateway.


## 4. Firewall

*👉 Firewalls are your security guards at the building entrances — they check ID badges (rules) before letting traffic in.*

- What it does:
    - Sets firewall rules on your VPC.
    - Example rules:
        - Allow SSH only via IAP (Identity Aware Proxy) -> no open port 22 to the world
        - Allow internal traffic within the VPC
        - Block everything by default

- Why:
    - Strong security perimeter — only traffic you explicitly allow gets in.
    - Using IAP for SSH removes need for VPN/bastion hosts.
    - Prevents misconfigurations from exposing workloads.

## 5. IAP (Identity Aware Proxy)

- What it does:
    - Instead of directly exposing cloud resources (apps, VMs, etc) to the Internet with traditional firewalls, IAP verifies the identity of the user

- Why:
    - No public IPs required: you can close external access to the VMs/apps and let IAP handle authentication
    - Zero trust: access is based on identity and IAM policies, not just based on network location
    - Auditing: logs every request (in Cloud Logging )

# Why this design: best practices and security rationale

- **Custom VPC, no auto subnets**
    - Prevents unintended exposure and noisy default rules. You decide every subnet and firewall rule.

- **Two subnets (public & private)**
    - We keep workloads (the VM) in the private subnet with no external IP. Outbound internet access for OS updates goes through Cloud NAT, so there’s no inbound exposure.

- **Cloud Router + Cloud NAT with logging**
    - Required for managing NAT at scale. NAT logs (errors-only here) help detect misconfig or egress anomalies without excessive cost.

- **Private Google access enabled on subnets**
Lets private VMs reach Google APIs/services via internal IPs—important when they don’t have public IPs.

- **Firewall: default deny, allow minimal**
    - In custom VPCs, ingress is denied unless allowed. We add:
        - Internal allow within VPC (you can restrict to just the ports you need).
        - SSH only via IAP (35.235.240.0/20) and only to instances with the specified service account — tight blast radius, no public SSH, works with gcloud compute ssh --tunnel-through-iap.
        - Firewall logging enabled to aid audits.

- **OS Login + block project SSH keys**
    - Centralizes SSH access with IAM. You give users `roles/compute.osLogin` or `roles/compute.osAdminLogin` at project/folder as needed. 

- **Shielded VM (and optional Confidential VM)**
    - Secure Boot, vTPM, integrity monitoring protect against boot-level tampering. Confidential VM (if supported) encrypts memory for stronger data-in-use protection.

- **No external IP on the VM**
    - Removes a huge attack surface. All admin goes through IAP and all egress goes through NAT.

- **Dedicated VM service account + least-privilege**
    - Only logWriter and metricWriter are given so the VM can publish telemetry. If the application needs other API access, grant narrowly scoped roles to this SA,not broad Owner/Editor access level.

- **Label everything**
    - Labels (env, app, etc.) help with cost allocation, search, policy.

- **APIs explicitly enabled**
    - Declarative google_project_service ensures the environment is reproducible.


# How to run:

1. Edit config files:
    - set the `project_id` and `region` in `/IaC/terraform.tfvars`
    - ```bash
        cp .env.sample .env
      ```
    - set the `PROJECT_ID` and `REGION` in `.env` file
    - Add the `USER_EMAIL` as the user in which is being used to access the VM

2. Create the required cloud resources

    ```bash
        cd /scripts
        bash create_resources.sh create
    ```

3. Grant the user required permissions to access the VM via IAP

    ```bash
        cd /scripts
        gcloud auth login # Login using an admin account
        bash add_user.sh  # Grant the permissions
    ```

4. Login to GCP using your added user email

5. Access the VM using the UI: use `ssh`

    ![alt text](/MLOps/Cloud/GCP/private_compute_instance/assets/private_vm_instance.png)

6. Clean-up the created cloud resources

    ```bash
        cd /scripts
        bash create_resources.sh destroy
    ```