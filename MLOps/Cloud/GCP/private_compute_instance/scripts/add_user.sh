# Export ENV variables
source ../.env

# 0. Login using a service-account which has a Editor access
# As a admin, you grant the access for the VM, then the user can access the cloud resource (in this case, it's a VM)
# gcloud auth login

# 1. Enable OS Login at project level
gcloud compute project-info add-metadata \
    --metadata enable-oslogin=TRUE



# 2. Grant human-user the IAM roles for the VM
# Needed for SSH login
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$USER_EMAIL" \
    --role="roles/compute.osLogin"

# If you need sudo/root access
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$USER_EMAIL" \
    --role="roles/compute.osAdminLogin"

# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="user:$USER_EMAIL" \
#     --role="roles/serviceusage.serviceUsageConsumer"

# # Allow your human user to "use" instances
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --member="user:$USER_EMAIL" \
#   --role="roles/compute.instanceAdmin.v1"

# # Allow your human user to act as the VM service account
# gcloud iam service-accounts add-iam-policy-binding \
#   vm-runtime-sa@$PROJECT_ID.iam.gserviceaccount.com \
#   --member="user:$USER_EMAIL" \
#   --role="roles/iam.serviceAccountUser"



# 3. Grant IAP tunnel access
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$USER_EMAIL" \
    --role="roles/iap.tunnelResourceAccessor"