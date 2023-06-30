#!/bin/bash

HOST_PROJECT_NAME="esx-labops-01"
REGION="australia-southeast1"
ZONE="australia-southeast1-a"

BILLING_ACCOUNT=$(gcloud beta billing accounts list --format="value(name)")
ORGANIZATION_ID=$(gcloud organizations list --format="value(name)")

cat << EOF
billing_account		= "${BILLING_ACCOUNT}"
organization_id		= "${ORGANIZATION_ID}"
host_project_name	= "${HOST_PROJECT_NAME}"

## required for subnets and instances
region			= "${REGION}"

## required for nfs filestore location
zone			= "${ZONE}"
EOF

