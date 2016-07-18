#!/bin/bash
echo "Destroying Routes"
cd terraform-routes
terraform destroy --force
echo "Destroying Infrastructure"
cd ../terraform/
terraform destroy --force
echo "Clearing SSL Certs"
cd ../ssl/
rm -rf *pem
rm -rf kubernetes-csr.json
rm -rf *.csr
echo "Removing ansible vars"
rm -rf ansible/group_vars/all
rm -rf ansible/gcehosts
rm -rf ansible/roles/common/files/*.pem
