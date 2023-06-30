terraform {
	backend "local" {
		path = "./state/terraform.tfstate"
	}
	required_providers {
		vsphere = ">= 2.3.0"
	}
}

## define variables
variable "vcenter_ip"	{ default = null }

## input locals
locals {
	esx			= {
		address			= "34.x.x.x" # nic1 external ip
		username		= "root"
		password		= "VMware1!SDDC"
	}
	controller		= {
		connect_ip	= "35.x.x.x" # nic2 external ip
		datastore	= "ds-nfs"
		portgroup	= "vss-uplink"
		mac_address	= "42:01:0a:34:02:02"
		ip		= "10.52.2.2"
		netmask		= "255.255.255.0"
		gateway		= "10.52.2.1"
		dns		= "8.8.8.8"
	}
}

## providers
provider "vsphere" {
	vsphere_server		= local.esx.address
	user			= local.esx.username
	password		= local.esx.password
	allow_unverified_ssl	= true
}
