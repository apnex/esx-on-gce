#!/bin/bash

source ./get-tfvars.sh
PROJECT_ID=$(gcloud projects list --name:${HOST_PROJECT_NAME} --format="value(projectId)")

gcloud config set project ${PROJECT_ID}
gcloud config set compute/region ${REGION}

gcloud compute project-info add-metadata \
	--metadata google-compute-default-region=${REGION},google-compute-default-zone=${ZONE}

gcloud compute project-info describe | grep default
