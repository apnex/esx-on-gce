#!/bin/bash

gcloud compute images create ipxe-boot \
	--source-uri gs://iso.apnex.io/ipxe-gce.tar.gz \
	--guest-os-features=GVNIC,MULTI_IP_SUBNET \
	--licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
