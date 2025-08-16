# Deploying APIs

In this section, deploying APIs to the cloud is demonstrated:

1. ## [GCP](/MLOps/Deploying_API/gcp/)

    - ### Features:

        - FastAPI for building the API
        - Containerization of the API using Docker
        - Artifact Registry for hosting docker images
        - Cloud Run for running the API in the cloud
        - Setting up the resources and deployment using Terraform

    - ### How to run

        0. Install `gcloud` cli and authenticate it:

            ```bash
                gcloud auth login
            ```

            set your GCP Project details in `.env` files

            ```bash
                cp .env.sample .env
                # set these ENV variables in .env file
                TF_VAR_project_id=
                TF_VAR_region=
                TF_VAR_terraform_tf_state_bucket=
            ```

        1. Create a google cloud service account for creating resources

            ```bash
                cd gcp/api/scripts
                bash create_service_account.sh
            ```

        2. Create a cloud storage bucket to store terraform states between modules

            ```bash
                cd gcp/api/IaC/remote_tf_state_bucket
                bash create_resources.sh create # for creating a gcp storage bucket
            ```

        3. Create base-set of cloud resources: artifact registry, service account, enabling required service apis

            ```bash
                cd gcp/api/IaC/base_resources
                bash create_resources.sh create # for creating base resources
            ```

        4. Build the docker image locally and push to the artifact-registry in the cloud

            ```bash
                cd gcp/api/scripts/
                bash create_docker_image.sh
            ```

        5. Build the docker image locally and push to the artifact-registry in the cloud

            ```bash
                cd gcp/api/IaC/cloud_run_service
                bash create_resources.sh create # for creating a cloud run service to run the api-endpoints
            ```

        6. Test the api-endpoints

            ```bash
                cd gcp/api/IaC/cloud_run_service
                bash test_api.sh
            ``` 

        7. Clean-up the resources

            ```bash
                cd gcp/api/scripts/
                bash clean_up_cloud_resources.sh
            ``` 


    - ### Note

        - Terraform is being used to create resources in the cloud:
            - Service Accounts
            - Setting up required APIs
            - Artifact Registry
            - Cloud Run
        - Currently the docker images are deployed manually using bash scripts, this can be delegated to a CI/CD pipeline for ease of use