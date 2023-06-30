## additional locals
locals {
	master_ip	= local.controller.ip
	dns_key		= "dnsctl."
	dns_key_secret	= "Vk13YXJlMSE="
	#echo -n 'VMware1!' | base64
}

## obtain default local ESX ids
data "vsphere_datacenter" "datacenter" {}
data "vsphere_resource_pool" "pool" {}
data "vsphere_host" "esx" {
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

## obtaiN portgroup data
data "vsphere_network" "uplink" {
	name		= local.controller.portgroup
	datacenter_id	= data.vsphere_datacenter.datacenter.id
}

# render ipxe script
resource "local_file" "script" {
	filename = "./state/centos.ipxe"
	content = templatefile("./tpl/centos.ipxe.tpl", {
		static_ip	= local.controller.ip
		static_netmask	= local.controller.netmask
		static_gateway	= local.controller.gateway
		static_dns	= local.controller.dns
	})
}

# create bootiso
module "bootiso" {
	source = "./modules/bootiso"
	depends_on	= [
		local_file.script
	]

	## inputs
	target_file	= "boot.iso"
	target_path	= "./state"
	script_file	= "centos.ipxe"
	script_path	= "./state"
}

# create controller vm
module "controller" {
	source = "./modules/controller"
	depends_on = [
		data.vsphere_network.uplink,
		module.bootiso
	]

	## inputs
	name		= "router"
	connect_ip	= local.controller.connect_ip
	mac_address	= local.controller.mac_address
	datacenter	= data.vsphere_datacenter.datacenter.id
	resource_pool	= data.vsphere_resource_pool.pool.id
	datastore	= local.controller.datastore
	network		= local.controller.portgroup
	bootfile_path	= "./state/boot.iso"
	bootfile_name	= "labops.centos.stage2.iso"
	private_key	= "controller.key"
	public_key	= "controller.key.pub"
}
