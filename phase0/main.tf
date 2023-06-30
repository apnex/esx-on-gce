## project creation
module "host-project" {
	source					= "terraform-google-modules/project-factory/google"
	random_project_id			= true
	name					= var.host_project_name
	org_id					= var.organization_id
	billing_account				= var.billing_account
	default_network_tier			= ""
	create_project_sa			= false
	default_service_account			= "keep"

	## apis
	activate_apis = [
		"cloudresourcemanager.googleapis.com",
		"compute.googleapis.com",
		"file.googleapis.com"
	]
}

## project org policies
module "policy-host-disableNestedVirtualization" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.disableNestedVirtualization"
	policy_type	= "boolean"
	enforce		= false
}
module "policy-host-disableSerialPortAccess" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.disableSerialPortAccess"
	policy_type	= "boolean"
	enforce		= false
}
module "policy-host-vmExternalIpAccess" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.vmExternalIpAccess"
	policy_type	= "list"
	enforce		= false
}
module "policy-host-requireOsLogin" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.requireOsLogin"
	policy_type	= "boolean"
	enforce		= false
}
module "policy-host-requireShieldedVm" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.requireShieldedVm"
	policy_type	= "boolean"
	enforce		= false
}
module "policy-host-vmCanIpForward" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.vmCanIpForward"
	policy_type	= "list"
	enforce		= false
}
module "policy-host-restrictVpcPeering" {
	source		= "terraform-google-modules/org-policy/google"
	policy_for	= "project"
	project_id	= module.host-project.project_id
	constraint	= "compute.restrictVpcPeering"
	policy_type	= "list"
	enforce		= false
}

# create default auto-network
resource "google_compute_network" "default" {
	name				= "default"
	auto_create_subnetworks		= true
	routing_mode			= "GLOBAL"
	project				= module.host-project.project_id
	delete_default_routes_on_create	= false
	mtu				= 8896
}

# create esx-mgmt
resource "google_compute_network" "net-mgmt" {
	name				= "net-mgmt"
	auto_create_subnetworks		= false
	routing_mode			= "REGIONAL"	
	project				= module.host-project.project_id
	delete_default_routes_on_create	= false
	mtu				= 8896
}
resource "google_compute_subnetwork" "sn-mgmt" {
	name		= "sn-mgmt"
	ip_cidr_range	= "10.52.1.0/24"
	region		= var.region
	network		= google_compute_network.net-mgmt.id
	project		= module.host-project.project_id
}

# create esx-uplink
resource "google_compute_network" "net-uplink" {
	project				= module.host-project.project_id
	name				= "net-uplink"
	auto_create_subnetworks		= false
	routing_mode			= "REGIONAL"	
	delete_default_routes_on_create	= false
	mtu				= 8896
}
resource "google_compute_subnetwork" "sn-uplink" {
	project		= module.host-project.project_id
	name		= "sn-uplink"
	ip_cidr_range	= "10.52.2.0/24"
	region		= var.region
	network		= google_compute_network.net-uplink.id
}

# create net-vmotion
resource "google_compute_network" "net-vmotion" {
	project				= module.host-project.project_id
	name				= "net-vmotion"
	auto_create_subnetworks		= false
	routing_mode			= "REGIONAL"	
	delete_default_routes_on_create	= false
	mtu				= 8896
}
resource "google_compute_subnetwork" "sn-vmotion" {
	project		= module.host-project.project_id
	name		= "sn-vmotion"
	ip_cidr_range	= "10.52.3.0/24"
	region		= var.region
	network		= google_compute_network.net-vmotion.id
}

## firewall policy for net-mgmt
resource "google_compute_firewall" "fw-mgmt" {
	project		= module.host-project.project_id
	name		= "mgmt-inbound"	
	network		= google_compute_network.net-mgmt.name
	direction	= "INGRESS"
	source_ranges	= ["0.0.0.0/0"]
	allow {
		protocol	= "icmp"
	}
	allow {
		protocol	= "tcp"
	}
}

## firewall policy for net-uplink
resource "google_compute_firewall" "fw-uplink" {
	project		= module.host-project.project_id
	name		= "uplink-inbound"	
	network		= google_compute_network.net-uplink.name
	direction	= "INGRESS"
	source_ranges	= ["0.0.0.0/0"]
	allow {
		protocol	= "icmp"
	}
	allow {
		protocol	= "tcp"
	}
}

## firewall policy for net-vmotion
resource "google_compute_firewall" "fw-uplink" {
	project		= module.host-project.project_id
	name		= "vmotion-inbound"	
	network		= google_compute_network.net-vmotion.name
	direction	= "INGRESS"
	source_ranges	= ["0.0.0.0/0"]
	allow {
		protocol	= "icmp"
	}
	allow {
		protocol	= "tcp"
	}
}

## setup outbound NAT for default
resource "google_compute_router" "router" {
	name    = "router-default"
	project	= module.host-project.project_id
	region  = var.region
	network = google_compute_network.default.id
	bgp {
		asn = 64514
	}
}
resource "google_compute_router_nat" "nat" {
	name                               = "nat-router-default"
	project				   = google_compute_router.router.project
	region                             = google_compute_router.router.region
	router                             = google_compute_router.router.name
	nat_ip_allocate_option             = "AUTO_ONLY"
	source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

## create filestore instance
resource "google_filestore_instance" "ds-vmdk" {
	project		= module.host-project.project_id
	name		= "ds-vmdk"
	location	= var.zone
	tier		= "BASIC_HDD"

	file_shares {
		capacity_gb	= 1024
		name		= "vmdk"
	}
	networks {
		network = google_compute_network.esx-mgmt.name
		modes   = ["MODE_IPV4"]
	}
}
