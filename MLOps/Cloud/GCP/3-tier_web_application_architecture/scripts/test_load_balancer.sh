#!/bin/bash

# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test multiple requests to see load balancing
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://$LB_IP | grep "Instance:"
  echo ""
done