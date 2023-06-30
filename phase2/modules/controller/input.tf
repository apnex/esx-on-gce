terraform {
	required_providers {
		vsphere = ">= 2.0.3"
		# 1.15.0 is required to workaround the "PolicyIDByVirtualMachine" error due to missing vCenter
		# Fix due to be rolled out in v2.0.3 (~Jan 2022)
		# https://github.com/hashicorp/terraform-provider-vsphere/issues/1033
	}
}

variable "name"			{}
variable "connect_ip"		{}
variable "datacenter"		{}
variable "resource_pool"	{}
variable "datastore"		{}
variable "network"		{}
variable "mac_address"		{}
variable "bootfile_path"	{}
variable "bootfile_name"	{}
variable "private_key"		{}
variable "public_key"		{}
