#!/bin/bash

gcloud compute instances create esx-core \
	--image ipxe-boot \
	--machine-type n2-standard-16 \
	--enable-nested-virtualization \
	--can-ip-forward \
	--network-interface=nic-type=VIRTIO_NET,subnet=default,no-address \
	--network-interface=nic-type=GVNIC,subnet=sn-mgmt \
	--network-interface=nic-type=GVNIC,subnet=sn-uplink \
	--metadata serial-port-enable=true
