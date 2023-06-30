## controller outputs
output "controller_ip" {
	value = module.controller.ip
}
output "controller_connect_ip" {
	value = local.controller.connect_ip
}
output "controller_ssh_key" {
	value = module.controller.ssh_key
}
output "ssh_cmd" {
	value = "ssh -o StrictHostKeyChecking=no -i ${module.controller.ssh_key} root@${local.controller.connect_ip}"
}
