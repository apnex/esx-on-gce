output "project_id" {
	value       = module.host-project.project_id
	description = "The ID of the created project"
}

output "host_project" {
	value       = module.host-project
	description = "The full project info"
}
