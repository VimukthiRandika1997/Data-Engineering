#!/bin/bash

# SSH into an instance
INSTANCE_NAME=$(gcloud compute instances list --format="value(name)" --filter="name~web-server")
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE


# Test database connection from instance
mysql -h [DB_IP] -u webapp_user -p webapp_db