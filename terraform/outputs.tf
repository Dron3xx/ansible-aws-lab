output "control_public_ip" {
  description = "The public IP address of the control EC2 instance"
  value       = module.ec2_instance["control"].public_ip
}
output "control_private_ip" {
  description = "The private IP address of the control EC2 instance"
  value       = module.ec2_instance["control"].private_ip
}
output "node1_private_ip" {
  description = "The private IP address of the node1 EC2 instance"
  value       = module.ec2_instance["node1"].private_ip
}
output "node2_private_ip" {
  description = "The private IP address of the node2 EC2 instance"
  value       = module.ec2_instance["node2"].private_ip
}