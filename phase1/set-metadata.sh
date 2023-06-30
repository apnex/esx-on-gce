#!/bin/bash

# obtain ipxe boot script
curl -fsSL http://esx.apnex.io/7.0-gce/esx.ipxe > esx.ipxe

# Configure per-instance boot script
gcloud compute instances add-metadata esx-core \
       --metadata-from-file ipxeboot=esx.ipxe
